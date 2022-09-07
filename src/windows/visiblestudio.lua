local utf8 = require "utf8"
local vurl = love.filesystem.load("lib/vurl.lua")()

local window = {}
window.title = "Visible Studio"
window.icon = "images/icons/visible-studio.png"
window.windowWidth = 1280
window.windowHeight = 720

local headerFont = love.graphics.newFont("fonts/DejaVuSans.ttf", 24)

local txt
local t
local t1
local f
local cursorPos
local preview
local dir = ""
local curLang

local mode = "main"

local textAreaWidth = 500

local langs = {}

langs.vurl = {
    ext = "vurl",
    
    defaultText = [[define load
    # when program loads
end

define update
    # when program state updates
end

define draw
    # when program draws to the screen
    text "Hello world!" 5 5
end]],

    run = function(f)
        openWindow("windows/vurl.lua", f)
    end,
    
    drawPreview = function()
        vurl.setroot(dir or "/")
        local ok = pcall(vurl.run, txt)
        if not ok then
            return false
        end
        
        love.graphics.setCanvas(preview)
        love.graphics.clear()
        
        ok = pcall(vurl.callFunc, "draw")
        if not ok then
            return false
        end
        
        love.graphics.setCanvas()
        return true
    end
}

langs.lua = {
    ext = "lua",
    
    defaultText = [[local window = {}
window.title = "My Program"

function window.load()
    -- when program loads
end

function window.update()
    -- when program state updates
end

function window.draw()
    -- when program draws to the screen
    text("Hello world!", 5, 5)
end

return window]],
    
    run = function(f)
        openWindow(f)
    end,
    
    drawPreview = function()
        local ok, chunk = pcall(loadstring, txt)
        if not ok then
            return false
        end
        
        local ok, program = pcall(chunk)
        if not ok then
            return false
        end
        
        love.graphics.setCanvas(preview)
        love.graphics.clear()
        
        local ok = pcall(program.draw or function() end)
        if not ok then
            return false
        end
        
        love.graphics.setCanvas()
        return true
    end
}

local langSelections = {
    {name = "Lua", id = "lua"},
    {name = "Vurl", id = "vurl"},
}

local function drawPreview()
    
    local ok = curLang.drawPreview()
    if not ok then
        love.graphics.setCanvas()
        return false
    end
    
    love.graphics.setCanvas()
    return true
end

local function openProject(file)
    open(function(content, name)
        local ext = string.match(name, "%.(.+)$") or ""
        
        local foundLang = false
        for k, lang in pairs(langs) do
            if lang.ext == ext then
                curLang = langs[k]
                foundLang = true
                break
            end
        end
        
        if not foundLang then
            messageBox("Visible Studio", "Could not determine language for this file", nil, "critical")
            return
        end
        
        txt = content
        f = name
        dir = string.match(name, "^(.*/).*$") or "/"
        window.title = "Visible Studio - " .. f
        mode = "main"
    end, file)
end

function window.load(file)
    txt = nil
    f = nil
    t = 0
    t1 = 1
    window.title = "Visible Studio"
    
    love.keyboard.setKeyRepeat(true)
    
    preview = love.graphics.newCanvas(800, 600)
    
    if file then
        openProject(file)
    else
        mode = "menu"
    end
    
    cursorPos = 1
end

function window.keypressed(key)
    t1 = 0
    
    if key == "backspace" then
        if cursorPos > 0 then
            local byteoffset = utf8.offset(txt, -1, cursorPos+1)
            if byteoffset then
                txt = (byteoffset > 1 and string.sub(txt, 1, byteoffset - 1) or "") .. (byteoffset < #txt and string.sub(txt, byteoffset+1) or "")
                cursorPos = cursorPos - 1
            end
        end
    end
    
    if key == "return" then
        txt = (cursorPos >= 1 and string.sub(txt, 1, cursorPos) or "") .. "\n" .. (cursorPos < #txt and string.sub(txt, cursorPos+1) or "")
        cursorPos = cursorPos + 1
    end
    
    if key == "left" then
        if cursorPos > 0 then cursorPos = cursorPos - 1 end
    end
    
    if key == "right" then
        if cursorPos < #txt then cursorPos = cursorPos + 1 end
    end
    
    if key == "up" then
        repeat
            if cursorPos <= 1 then break end
            cursorPos = cursorPos - 1
        until string.sub(txt, cursorPos, cursorPos) == "\n"
        if cursorPos > 0 then cursorPos = cursorPos - 1 end
    end
    
    if key == "down" then
        for i=1,2 do
            repeat
                if cursorPos > #txt then break end
                cursorPos = cursorPos + 1
            until string.sub(txt, cursorPos, cursorPos) == "\n"
        end
        cursorPos = cursorPos - 1
    end
    
    if key == "tab" then
        for i=1,4 do
            window.textinput(" ")
        end
    end
end

function window.textinput(text)
    txt = (cursorPos >= 1 and string.sub(txt, 1, cursorPos) or "") .. text .. (cursorPos < #txt and string.sub(txt, cursorPos+1) or "")
    cursorPos = cursorPos + 1
end

function window.update(dt)
    t = t + dt
    t1 = t1 + dt
    
    if mode == "main" and t1 >= 0.5 then
        t1 = 0
        local ok = drawPreview()
        if not ok then
            text("Error", 0, 0)
        end
    end
end

function window.draw()
    setFont("fonts/DejaVuSans.ttf")
    
    if mode == "main" then
        rect(0, 0, textAreaWidth, windowHeight, {1, 1, 1})
        outline(0, 0, textAreaWidth, windowHeight)
        
        rect(0, 0, windowWidth, 30, {0.75, 0.75, 0.75})
        
        local ex = 0
        button("New", function() messageBox("Visible Studio", "Save changes?", {{"Yes", function()
            save(f, txt, curLang.ext, function(name)
                closeMessageBox()
                window.load()
            end)
        end}, {"No", function()
            closeMessageBox()
            window.load()
        end}, {"Cancel", function() closeMessageBox() end}}) end, ex, 0, 60, 30)
        ex = ex + 60
        button("Open", openProject, ex, 0, 60, 30)
        ex = ex + 60
        button("Save", function()
            save(f, txt, curLang.ext, function(name)
                f = name window.title = "Visible Studio - " .. f
            end)
        end, ex, 0, 60, 30)
        ex = ex + 60
        button("Run", function()
            save(f, txt, curLang.ext or "", function(name)
                f = name
                window.title = "Visible Studio - " .. f
                curLang.run(f)
            end)
        end, ex, 0, 60, 30)
        ex = ex + 60
        button("Help", function()
            messageBox("Visible Studio", "Under construction")
        end, ex, 0, 60, 30)
        
        setFont("fonts/DejaVuSansMono.ttf")
        
        local textCursor = " "
        if math.floor(t*3) % 2 == 0 then
            textCursor = "_"
        end
        
        local f = love.graphics.getFont()
        local _, lines = f:getWrap(string.sub(txt, 1, cursorPos), windowWidth)
        local pos = #lines <= math.floor((windowHeight/2 - 30) / f:getHeight()) and 0 or 0 - #lines * f:getHeight() + (windowHeight/2 - 30)
        
        love.graphics.setScissor(windowX, windowY + 30, textAreaWidth, windowHeight - 30)
        
        text((cursorPos >= 1 and string.sub(txt, 1, cursorPos) or "") .. textCursor .. string.sub(txt, cursorPos+1), 0, 30 + pos, nil, textAreaWidth)
        
        love.graphics.setScissor()
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setScissor(windowX + textAreaWidth, windowY + 30, windowWidth-textAreaWidth, windowHeight-30)
        love.graphics.draw(preview, textAreaWidth, 30)
    
    elseif mode == "menu" then
        
        love.graphics.setFont(headerFont)
        text("Welcome to Visible Studio", 5, 5)
        setFont("fonts/DejaVuSans.ttf")
        text("The barely-usable development environment for Windows Poop Edition applications", 5, 30)
        
        button("New Project", function()
            mode = "new"
        end, 5, 60, 180, 40)
        
        button("Open Existing Project", function()
            openProject()
        end, 5, 110, 180, 40)
    
    elseif mode == "new" then
        love.graphics.setFont(headerFont)
        text("Create a new project", 5, 5)
        setFont("fonts/DejaVuSans.ttf")
        
        text("Language:", 5, 35)
        local x, y = 5, 60
        for _, lang in ipairs(langSelections) do
            button(lang.name, function()
                curLang = langs[lang.id]
                txt = curLang.defaultText or ""
                mode = "main"
            end, x, y, 140, 40)
            x = x + 150
            if x+150 >= windowWidth then
                x = 5
                y = y + 50
            end
        end
    end
end

function window.close()
    if mode ~= "main" then return end
    
    messageBox("Visible Studio", "Save changes?", {
        {"Yes", function()
            closeMessageBox()
            save(f, txt, curLang.ext, function()
                love.keyboard.setKeyRepeat(false)
                closeWindow(nil, true)
            end)
        end},
        {"No", function()
            love.keyboard.setKeyRepeat(false)
            closeWindow(nil, true)
        end},
        {"Cancel", function()
            closeMessageBox()
        end},
    })
    return true
end

return window
