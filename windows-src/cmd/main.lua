local utf8 = require "utf8"

local window = {}
window.title = "Command Prompt"

local t
local cdir
local scroll

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
clear: Clear all text from the screen.
cd [dir]: Change working directory.
ls (dir?): List all files and directories in the current directory or a specific directory.
cat [file]: Print contents of a file.
mv [src] [dest]: Move/rename a file.
cp [src] [dest]: Copy a file.
rm [file]: Delete a file or an empty directory.
lua [code]: Execute a line of Lua code.

Note: To type a space as part of an argument, you must type an underscore (_) instead. If you wanna type an underscore, type \_ instead.
(this is not required for the 'lua' command)]])
        return
    end
    
    if cmd == "open" then
        for i=1,1 do
            if not args[i] then
                print("ERROR: missing argument " .. i)
                return
            end
        end
        
        local err = openWindow("windows/" .. args[1] .. ".exe", args[2])
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
            local m = string.match(p, "(.+)%.exe")
            if m then
                print(m)
            end
        end
        return
    end
    
    if cmd == "close" then
        closeWindow()
        return
    end
    
    if cmd == "clear" then
        stdout = ""
        return
    end
    
    if cmd == "cd" then
        if not args[1] then
            print("ERROR: missing argument 1")
            return
        end
        
        local dir = args[1]
        if dir == ".." then
            if cdir ~= ""  then
                cdir = string.match(cdir, "/?(.+/).+/$") or ""
            end
        else
            cdir = dir .. "/"
        end
        return
    end
    
    if cmd == "ls" then
        local dir = args[1] or cdir
        if not string.match(dir, "/$") then dir = dir .. "/" end
        
        for _, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
            local info = love.filesystem.getInfo(dir .. item)
            if info.type == "directory" then
                item = item .. "/"
            end
            
            print(item)
        end
        return
    end
    
    if cmd == "cat" then
        if not args[1] then
            print("ERROR: missing argument 1")
            return
        end
        
        local file = args[1]
        local s, err = love.filesystem.read(cdir .. file)
        if not s and err then
            print("ERROR: " .. err)
            return
        end
        
        print(s)
        return
    end
    
    if cmd == "cp" then
        if not args[1] then
            print("ERROR: missing argument 1")
            return
        end
        if not args[2] then
            print("ERROR: missing argument 2")
            return
        end
        
        local src, dest = args[1], args[2]
        local content, err = love.filesystem.read(cdir .. src)
        if not content and err then
            print("ERROR: ".. err)
            return
        end
        
        local ok, err = love.filesystem.write(cdir .. dest, content)
        if not ok and err then
            print("ERROR: ".. err)
            return
        end
        return
    end
    
    if cmd == "rm" then
        if not args[1] then
            print("ERROR: missing argument 1")
            return
        end
        
        local file = args[1]
        local ok = love.filesystem.remove(cdir .. file)
        if not ok then
            print("ERROR: failed to delete " .. file)
            return
        end
        return
    end
    
    if cmd == "lua" then
        local s = ""
        for _, arg in ipairs(args) do
            s = s .. arg .. " "
        end
        
        local chunk, err = loadstring(s)
        if not chunk then
            print(err)
            return
        end
        
        local ok, ret = pcall(chunk)
        if not ok then
            print(ret)
            return
        end
        
        print(ret)
        return
    end
    
    if not cmd then return end
    
    print("unknown command: " .. cmd)
end

function window.load()
    cdir = ""
    stdin = ""
    stdout = "CrapOS Windows Poop Edition 5 - " .. systemVersion .."\n\"\"©\"\"2017-2022\n"
    scroll = 0
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
        scroll = 0
        print(cdir .. "> " .. stdin)
        command(stdin)
        stdin = ""
    end
end

function window.textinput(text)
    stdin = stdin .. text
end

function window.wheelmoved(dx, dy)
    scroll = scroll + dy
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
    local s = stdout .. cdir .. "> " .. stdin
    local _, lines = f:getWrap(s, windowWidth)
    local pos = #lines <= math.floor(windowHeight / f:getHeight()) and 0 or 0 - #lines * f:getHeight() + windowHeight
    
    love.graphics.push()
    love.graphics.translate(0, scroll * f:getHeight())
    
    text(s .. textCursor, 0, pos, {1, 1, 1}, windowWidth)
    
    love.graphics.pop()
end

return window
