local utf8 = require "utf8"

local window = {}
window.title = "Command Prompt"
window.icon = "images/icons/cmd.png"

local t

local function command(text)
    local terms = {}
    for term in string.gmatch(text, "%S+") do
        term = string.gsub(term, "[^\\]_", " ")
        term = string.gsub(term, "\\_", "_")
        table.insert(terms, term)
    end
    
    local cmd = terms[1]
    local args = {}
    for i=2,#terms do
        args[i-1] = terms[i]
    end
    
    if cmd == "help" then
        print([[
List of commands:
open [program] (argument?): Opens a program.
crash: Crash your computer.
list: List available programs.
close: Close Command Prompt.

Note: To type a space as part of an argument, you must type an underscore (_) instead. If you wanna type an underscore, type \_ instead.]])
        return
    end
    
    if cmd == "open" then
        for i=1,1 do
            if not args[i] then
                print("ERROR: missing argument " .. i)
                return
            end
        end
        
        local err = openWindow("windows/" .. args[1] .. ".lua", args[2])
        if err then print(err) end
        return
    end
    
    if cmd == "crash" then
        switchScreen("screens/crash.lua", "INTENTIONAL CRASH VIA COMMAND PROMPT")
        return
    end
    
    if cmd == "list" then
        print("List of available programs:")
        for _, p in ipairs(love.filesystem.getDirectoryItems("windows")) do
            local m = string.match(p, "(.+)%.lua")
            if m then
                print(m)
            end
        end
        return
    end
    
    if cmd == "close" then
        closeWindow()
    end
    
    if not cmd then return end
    
    print("unknown command: " .. cmd)
end

function window.load()
    stdin = ""
    stdout = "CrapOS Windows Poop Edition 5 - " .. systemVersion .."\n\"\"©\"\"2017-2022\n"
    t = 0
end

function window.keypressed(key)
    if key == "backspace" then
        local byteoffset = utf8.offset(stdin, -1)
        if byteoffset then
            stdin = string.sub(stdin, 1, byteoffset - 1)
        end
    end
    
    if key == "return" then
        print("> " .. stdin)
        command(stdin)
        stdin = ""
    end
end

function window.textinput(text)
    stdin = stdin .. text
end

function window.update(dt)
    t = t + dt
end

function window.draw()
    setFont("fonts/DejaVuSansMono.ttf")
    
    rect(0, 0, windowWidth, windowHeight, {0, 0, 0})
    
    local textCursor = ""
    if math.floor(t*3) % 2 == 0 then
        textCursor = "_"
    end
    
    local f = love.graphics.getFont()
    local s = stdout .. "> " .. stdin
    local _, lines = f:getWrap(s, windowWidth)
    local pos = #lines <= math.floor(windowHeight / f:getHeight()) and 0 or 0 - #lines * f:getHeight() + windowHeight
    
    text(s .. textCursor, 0, pos, {1, 1, 1}, windowWidth)
end

return window
