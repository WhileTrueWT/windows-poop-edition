local window = {}
window.title = "Brainflip"

local mem
local input
local output = ""
local code
local loopTable
local loopStack
local cp
local ip
local co
local scroll = 0

local function run()
    mem = {0}
    input = {}
    output = ""
    loopTable = {}
    loopStack = {}
    for i=1,#code do
        local cmd = string.sub(code, i, i)
        
        if cmd == "[" then
            table.insert(loopStack, i)
        elseif cmd == "]" then
            local bi = table.remove(loopStack)
            loopTable[bi] = i
            loopTable[i] = bi
        end
    end

    cp = 1
    ip = 1
    while ip <= #code do
        local cmd = string.sub(code, ip, ip)
        
        if cmd == "+" then
            mem[cp] = mem[cp] + 1
            if mem[cp] > 255 then
                mem[cp] = 0
            end
        end
        
        if cmd == "-" then
            mem[cp] = mem[cp] - 1
            if mem[cp] < 0 then
                mem[cp] = 255
            end
        end
        
        if cmd == ">" then
            cp = cp + 1
            if cp > #mem then
                table.insert(mem, 0)
            end
        end
        
        if cmd == "<" then
            cp = cp - 1
        end
        
        if cmd == "." then
            local c = string.char(mem[cp])
            output = output .. c
            stdout = stdout .. c
        end
        
        if cmd == "," then
            if #input == 0 then
                textInput("Program is requesting input", function(text) coroutine.resume(co, text) end)
                local inp = coroutine.yield()
                for i=1,#inp do
                    table.insert(input, string.byte(inp, i))
                end
                table.insert(input, 10)
            end
            mem[cp] = table.remove(input, 1)
        end
        
        if cmd == "[" then
            if mem[cp] == 0 then
                ip = loopTable[ip]
            end
        end
        
        if cmd == "]" then
            if mem[cp] ~= 0 then
                ip = loopTable[ip]
            end
        end
        
        ip = ip + 1
    end
end

function window.load(file)
    scroll = 0
    
    open(function(content)
        code = content
    
        co = coroutine.create(run)
        coroutine.resume(co)
    end, file)
end

function window.wheelmoved(x, y)
    scroll = scroll + y * 30
end

function window.draw()
    text(output, 0, scroll)
end

return window
