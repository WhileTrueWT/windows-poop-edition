local addr = "*:8798"

if love then love.window.close() end

local enet = require "enet"
local json = require "json"

local host
local commands = {}
local names = {}

local function getName(peer)
    local idx = peer:index()
    return (names[idx] ~= 0) and names[idx] or "User" .. tostring(idx)
end

local function checkNameDuplicate(s)
    for _, name in ipairs(names) do
        if name == s then
            return true
        end
    end
    return false
end

commands.msg_send = function(a, peer)
    local msg = a[1]
    local name = getName(peer)
    
    assert(#msg > 0)
    if #msg > 1000 then
        msg = string.sub(msg, 1, 1000)
    end
    
    host:broadcast(json.encode{
        "msg_receive",
        {msg, name}
    })
end

commands.set_name = function(a, peer)
    local name = a[1]
    local idx = peer:index()
    local oldName = getName(peer)
    
    assert(#name <= 32)
    assert(string.match(name, "[%w_]+"))
    assert(not checkNameDuplicate(name))
    
    names[idx] = name
    
    host:broadcast(json.encode{
        "server_msg",
        {"name_change", name, oldName}
    }) 
end

commands.user_list = function(a, peer)
    local list = {}
    for _, name in ipairs(names) do
        if name ~= 0 then
            table.insert(list, name)
        end
    end
    
    peer:send(json.encode{
        "user_list",
        {list}
    })
end

local function decode(s, peer)
    local data = json.decode(s)
    
    assert(data)
    assert(type(data) == "table")
    assert(data[1])
    assert(type(data[1]) == "string")
    assert(data[2])
    assert(type(data[2]) == "table")
    assert(peer)
    
    commands[data[1]](data[2], peer)
end

host = enet.host_create(addr)
print("server started.")

while true do
    
    local event = host:service(50)
    while event do
        
        if event.type == "receive" then
            
            pcall(decode, event.data, event.peer)
            
        elseif event.type == "connect" then
            
            host:broadcast(json.encode{
                "server_msg",
                {"connect", getName(event.peer)}
            })
            
        elseif event.type == "disconnect" then
            
            host:broadcast(json.encode{
                "server_msg",
                {"disconnect", getName(event.peer)}
            })
            names[event.peer:index()] = 0
            
        end
        
        event = host:service()
    end
    
end
