local mem = {}
local lines
local lp
local branches
local returnStack
local run
local co
local t = 0
local screen
local hasStarted = false
local color
local elements = {}
local commands = {}
local callFunc
local window = {}
local root = ""

commands = {
    set = function(a)
        if string.match(a[1], "^%.") then
            returnStack[#returnStack].locals[a[1]] = a[2]
        end
        mem[a[1]] = a[2]
    end,
    
    list = function(a)
        return a
    end,
    -- I upset myself
    insert = function(a)
        if string.match(a[1], "^%.") and #returnStack > 0 then
            table.insert(returnStack[#returnStack].locals[a[1]], a[2], a[3])
        else
            table.insert(mem[a[1]], a[2], a[3])
        end
    end,
    push = function(a)
        if string.match(a[1], "^%.") and #returnStack > 0 then
            table.insert(returnStack[#returnStack].locals[a[1]], a[2])
        else
            table.insert(mem[a[1]], a[2])
        end
    end,
    remove = function(a)
        if string.match(a[1], "^%.") and #returnStack > 0 then
            return table.remove(returnStack[#returnStack].locals[a[1]], a[2]) or ""
        else
            return table.remove(mem[a[1]], a[2]) or ""
        end
    end,
    pop = function(a)
        if string.match(a[1], "^%.") and #returnStack > 0 then
            return table.remove(returnStack[#returnStack].locals[a[1]]) or ""
        else
            return table.remove(mem[a[1]]) or ""
        end
    end,
    index = function(a)
        if string.match(a[1], "^%.") and #returnStack > 0 then
            return returnStack[#returnStack].locals[a[1]][tonumber(a[2])] or ""
        else
            return mem[a[1]][tonumber(a[2])] or ""
        end
    end,
    replace = function(a)
        if string.match(a[1], "^%.") and #returnStack > 0 then
            returnStack[#returnStack].locals[a[1]][tonumber(a[2])] = a[3]
        else
            mem[a[1]][tonumber(a[2])] = a[3]
        end
    end,
    
    add = function(a)
        return tostring(tonumber(a[1]) + tonumber(a[2]))
    end,
    sub = function(a)
        return tostring(tonumber(a[1]) - tonumber(a[2]))
    end,
    mul = function(a)
        return tostring(tonumber(a[1]) * tonumber(a[2]))
    end,
    div = function(a)
        return tostring(tonumber(a[1]) / tonumber(a[2]))
    end,
    mod = function(a)
        return tostring(tonumber(a[1]) % tonumber(a[2]))
    end,
    join = function(a)
        return a[1] .. a[2]
    end,
    len = function(a)
        return #a[1]
    end,
    substr = function(a)
        return string.sub(a[1], a[2], a[3])
    end,
    
    eq = function(a)
        return (a[1] == a[2]) and '1' or '0'
    end,
    
    gt = function(a)
        return (tonumber(a[1]) > tonumber(a[2])) and '1' or '0'
    end,
    
    lt = function(a)
        return (tonumber(a[1]) < tonumber(a[2])) and '1' or '0'
    end,
    
    gte = function(a)
        return (tonumber(a[1]) >= tonumber(a[2])) and '1' or '0'
    end,
    
    lte = function(a)
        return (tonumber(a[1]) <= tonumber(a[2])) and '1' or '0'
    end,
    
    ["and"] = function(a)
        return (a[1]=='1' and a[2]=='1') and '1' or '0'
    end,
    
    ["or"] = function(a)
        return (a[1]=='1' or a[2]=='1') and '1' or '0'
    end,
    
    ["not"] = function(a)
        return (a[1]=='0') and '1' or '0'
    end,
    
    ["if"] = function(a)
        if a[1]=='0' then
            lp = branches[lp]
        end
    end,
    
    ["while"] = function(a)
        if a[1]=='0' then
            lp = branches[lp]
        end
    end,
    
    frame = function(a)
        if a[1] and a[1]=='0' then
            lp = branches[lp]
        end
    end,
    
    define = function(a)
        mem[a[1]] = lp
        lp = branches[lp]
    end,
    
    call = function(a)
        local args = {}
        for i, arg in ipairs(a) do
            if i > 1 then table.insert(args, arg) end
        end
        
        local locals = {[".args"] = args}
        setmetatable(locals, {__index = mem})
        table.insert(returnStack, {lp=lp, locals=locals})
        
        lp = mem[a[1]]
    end,
    
    ["end"] = function(a)
        if branches[lp].type == "while" then
            lp = branches[lp].value - 1
        elseif branches[lp].type == "frame" then
            coroutine.yield()
            lp = branches[lp].value - 1
        elseif branches[lp].type == "define" then
            lp = table.remove(returnStack).lp
        end
    end,
    
    random = function(a)
        return tostring(love.math.random(tonumber(a[1]), tonumber(a[2])))
    end,
    
    clear = function(a)
        love.graphics.clear(0, 0, 0, 0)
    end,
    
    color = function(a)
        if #a == 0 then
            color = nil
            return
        end
        
        local alpha = a[4] and tonumber(a[4]) or 1
        color = {tonumber(a[1]), tonumber(a[2]), tonumber(a[3]), alpha}
    end,
    
    rect = function(a)
        rect(tonumber(a[1]), tonumber(a[2]), tonumber(a[3]), tonumber(a[4]), color)
    end,
    
    outline = function(a)
        outline(tonumber(a[1]), tonumber(a[2]), tonumber(a[3]), tonumber(a[4]), color)
    end,
    
    text = function(a)
        text(a[1], tonumber(a[2]), tonumber(a[3]), color, tonumber(a[4]))
    end,
    
    button = function(a)
        button(a[1], function() callFunc(a[2]) end, tonumber(a[3]), tonumber(a[4]), tonumber(a[5]), tonumber(a[6]))
    end,
    
    image = function(a)
        image(root .. a[1], tonumber(a[2]), tonumber(a[3]), tonumber(a[4]), tonumber(a[5]))
    end,
    
    sound = function(a)
        sound(root .. a[1])
    end,
    
    textinput = function(a)
        textInput(a[1], function(text)
            mem["_input"] = text
            callFunc(a[2])
        end)
    end,
    
    message = function(a)
        local buttons = a[3]
        for i, b in ipairs(buttons) do
            buttons[i][2] = function() callFunc(b[2]) closeMessageBox() end
        end
        messageBox(a[1], a[2], buttons, a[4])
    end,
    
    icon = function(a)
    end,
    
    title = function(a)
    end,
}

local function parseLine(line)
    local l = {}
    
    local command, argstring = string.match(line, "^%s*(%S+)%s?(.*)$")
    
    local isInQuotes = false
    local parensLevel = 0
    local args = {}
    local a = ""
    local c = 1
    while c <= #argstring do
        local char = string.sub(argstring, c, c)
        
        if char == '"' then
            isInQuotes = not isInQuotes
            a = a .. char
        elseif char == "(" then
            parensLevel = parensLevel + 1
            a = a .. char
        elseif char == ")" then
            parensLevel = parensLevel - 1
            a = a .. char
        elseif (not isInQuotes) and (parensLevel <= 0) and string.match(char, "%s") then
            table.insert(args, a)
            a = ""
        else
            a = a .. char
        end
        
        c = c + 1
    end
    if #a > 0 then
        table.insert(args, a)
    end
    
    local parsedArgs = {}
    for i, arg in ipairs(args) do
        if string.match(arg, "^%[.+%]$") then
            parsedArgs[i] = {type="var", value=string.sub(arg, 2, -2)}
        elseif string.match(arg, "^%(.+%)$") then
            parsedArgs[i] = {type="cmd", value=parseLine(string.sub(arg, 2, -2))}
        elseif string.match(arg, "^\"(.*)\"$") then
            parsedArgs[i] = {type="lit", value=string.sub(arg, 2, -2)}
        else
            parsedArgs[i] = {type="lit", value=arg}
        end
    end
    
    l.command = command
    l.args = parsedArgs

    return l
end

local function runLine(line)
    local args = {}
    for i, a in ipairs(line.args) do
        if a.type == "var" then
            if string.match(a.value, "^%.") then
                args[i] = returnStack[#returnStack].locals[a.value]
            else
                args[i] = mem[a.value]
            end
        elseif a.type == "cmd" then
            args[i] = runLine(a.value)
        elseif a.type == "lit" then
            args[i] = a.value
        end
    end
    assert(commands[line.command], "unknown command: " .. line.command)
    local ret = commands[line.command](args)
    return ret
end

function run(code)
    lines = {}
    branches = {}
    returnStack = {}
    local branchStack = {}
    
    local lineNumber = 1
    for line in string.gmatch(code, "[^\n]+") do
        if (not string.match(line, "^%s*#%s")) and (not string.match(line, "^%s+$")) then
            local pl = parseLine(line)
            table.insert(lines, pl)

            if pl.command == "if"
            or pl.command == "while"
            or pl.command == "frame"
            or pl.command == "define" then
                table.insert(branchStack, {type=pl.command, value=lineNumber})
            elseif pl.command == "end" then
                local b = table.remove(branchStack)
                branches[lineNumber] = b
                branches[b.value] = lineNumber
            end
            
            lineNumber = lineNumber + 1
        end
    end
    
    lp = 1
    
    while lp <= #lines do
        local line = lines[lp]
        
        runLine(line)
        
        lp = lp + 1
    end
end

function callFunc(name)
    if not mem[name] then return end
    
    lp = mem[name]+1
    table.insert(returnStack, {lp=#lines})
    
    while lp <= #lines do
        runLine(lines[lp])
        lp = lp + 1
    end
end

local m = {}

m.run = run
m.callFunc = callFunc

function m.setroot(dir)
    if not string.match(dir, "/$") then
        dir = dir .. "/"
    end
    root = dir
end

function m.setvar(var, val)
    mem[var] = val
end

function m.setcmd(name, func)
    commands[name] = func
end

return m
