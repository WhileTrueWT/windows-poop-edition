local enet = require "enet"
local utf8 = require "utf8"
local json = require "lib.json"

local window = {}
window.title = "PEChat"
window.icon = "images/icons/chat.png"

local client
local server
local messages
local line
local userlist
local textinput
local hasStarted
local isConnecting
local scroll
local commands = {}
local t
local t1
local name

local function Message(text, author, params)
    local t = {}
    params = params or {}
    
    t.text = text or ""
    t.author = author or "User"
    t.server = params.server or false
    t.time = os.time()
    
    return t
end

local function notif(s)
    if not window.isActive then
        notify(s, function() openWindow("windows/chat.lua") end)
    end
end

local function sendMessage(s)
    if not hasStarted then return end
    
    server:send(json.encode{
        "msg_send",
        {s}
    })
end

local function writeMessage(message)
    table.insert(messages, message)
    
    local s = ""
    if message.server then
        s = os.date("%X", message.time) .. "\t" .. message.text
    else
        s = os.date("%X", message.time) .. "\t" .. message.author .. ": " .. message.text
    end
    
    local f = love.graphics.getFont()
    local _, lines = f:getWrap(s, windowWidth-90)
    for _, l in ipairs(lines) do
        table.insert(line, l)
    end
end

local function getUserList()
    server:send(json.encode{
        "user_list",
        {}
    })
end



commands.msg_receive = function(a)
    local msg = a[1]
    local name = a[2]
    
    writeMessage(Message(msg, name))
    
    notif("PEChat: New message\n" .. name .. ": " .. msg)
end

commands.server_msg = function(a)
    local msg = a[1]
    local name = a[2]
    local s = ""
    
    if msg == "connect" then
        s = "[ " .. name .. " has connected! ]"
    end
    
    if msg == "disconnect" then
        s = "[ " .. name .. " has disconnected. ]"
    end
    
    if msg == "name_change" then
        s = "[ " .. a[3] .. " is now called " .. name .. " ]"
    end
    
    writeMessage(Message(s, nil, {server=true}))
    getUserList()
end

commands.user_list = function(a)
    local list = a[1]
    
    userlist = list
end


local function decode(s)
    local data = json.decode(s)
    
    assert(data)
    assert(type(data) == "table")
    assert(data[1])
    assert(type(data[1]) == "string")
    assert(data[2])
    assert(type(data[2]) == "table")
    
    commands[data[1]](data[2])
end

local connect = coroutine.create(function()
    t1 = 0
    while true do
        local event = client:service()
        if event and event.type == "connect" then
            server:send(json.encode{
                "set_name",
                {name}
            })
            client:flush()
            hasStarted = true
            isConnecting = false
            return
        elseif event and event.type == "disconnect" then
            isConnecting = false
            closeWindow()
            messageBox("PEChat", "Connection failed. (Disconnected)")
            return
        end
        
        if t1 >= 30 then
            isConnecting = false
            closeWindow()
            messageBox("PEChat", "Connection failed. (Timed out)")
            return
        end
        
        coroutine.yield()
    end
end)

local function start()
    client = enet.host_create()
    server = client:connect("localhost:8798")
    isConnecting = true
end

function window.load()
    hasStarted = false
    isConnecting = false
    scroll = 0
    messages = {}
    line = {}
    userlist = {}
    textinput = ""
    
    textInput("Choose a name! (a-zA-Z0-9_, max 32 chars)", function(text)
        name = text
        start()
    end)
    
    t = 0
    t1 = 0
end

function window.update(dt)
    t = t + dt
    t1 = t1 + dt
    
    if isConnecting then
        coroutine.resume(connect)
        return
    end
    
    if not hasStarted then
        return
    end
    
    local event = client:service()
    if event then
        
        if event.type == "receive" then
            pcall(decode, event.data)
        end
        
    end
end

function window.draw()
    local f = love.graphics.getFont()
    
    if isConnecting then
        text("Connecting...", 5, 5)
    end
    
    local y = scroll + windowHeight-60 - #line * 15
    for i, l in ipairs(line) do
        text(l, 5, y+i*15, nil, windowWidth-90)
    end
    
    rect(windowWidth-100, 0, 100, windowHeight-40, {0.8, 0.8, 0.8, 1})
    
    for i, user in ipairs(userlist) do
        text(user, windowWidth-90, i*15, nil, 90)
    end
    
    local textCursor = ""
    if math.floor(t*3) % 2 == 0 then
        textCursor = "_"
    end
    
    local pos = f:getWidth(textinput) <= windowWidth-20 and 0 or 0 - f:getWidth(textinput) + windowWidth-10
    
    love.graphics.setScissor(windowX+5, windowY+windowHeight-30, windowWidth-10, 20)
    rect(5, windowHeight-30, windowWidth-10, 20, {1, 1, 1})
    outline(5, windowHeight-30, windowWidth-10, 20)
    text(textinput .. textCursor, 10 + pos, windowHeight-30)
    love.graphics.setScissor()
end

function window.keypressed(key)

    if key == "backspace" then
        local byteoffset = utf8.offset(textinput, -1)
        if byteoffset then
            textinput = string.sub(textinput, 1, byteoffset - 1)
        end
    end
    
    if key == "return" then
        sendMessage(textinput)
        textinput = ""
    end
    
end

function window.textinput(text)
    textinput = textinput .. text
end

function window.wheelmoved(x, y)
    scroll = scroll + y*5
    
    if scroll < 0 or scroll > (#line * 15)-30 then
        scroll = scroll - y*5
    end
end

function window.close()
    if server and client then
        server:disconnect()
        client:flush()
    end
end

return window