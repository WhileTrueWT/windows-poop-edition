local utf8 = require "utf8"
local vurl = love.filesystem.load("lib/vurl.lua")()

local window = {}
window.title = "Vurl IDE"
window.icon = "images/icons/vurl.png"

local txt
local t
local t1
local f
local cursorPos
local preview
local dir = ""

local defaultText = [[define load
    # when program loads
end

define update
    # when program state updates
end

define draw
    # when program draws to the screen
    text "Hello world!" 5 5
end]]

local textAreaWidth = 400

local function drawPreview()
    vurl.setroot(dir)
    local ok = pcall(vurl.run, txt)
    if not ok then
        love.graphics.setCanvas()
        return false
    end
    
    love.graphics.setCanvas(preview)
    love.graphics.clear()
    
    ok = pcall(vurl.callFunc, "draw")
    if not ok then
        love.graphics.setCanvas()
        return false
    end
    
    love.graphics.setCanvas()
    return true
end

function window.load(file)
    txt = nil
    f = nil
    t = 0
    t1 = 1
    window.title = "Vurl IDE"
    
    love.keyboard.setKeyRepeat(true)
    
    preview = love.graphics.newCanvas(800, 600)
    
    if file then open(function(text, name)
        txt = text
        f = file
        dir = string.match(file, "^(.*/).*$") or "/"
        window.title = "Vurl IDE - " .. file
    end, file) else txt = defaultText end
    
    cursorPos = #txt
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
    
    if t1 >= 0.5 then
        t1 = 0
        local ok = drawPreview()
        if not ok then
            text("Error", 0, 0)
        end
    end
end

function window.draw()
    if not txt then return end
    setFont("fonts/DejaVuSans.ttf")
    
    rect(0, 0, textAreaWidth, windowHeight, {1, 1, 1})
    outline(0, 0, textAreaWidth, windowHeight)
    
    rect(0, 0, windowWidth, 30, {0.75, 0.75, 0.75})
    
    local ex = 0
    button("New", function() messageBox("Vurl IDE", "Save changes?", {{"Yes", function()
        save(f, txt, "vurl")
        closeMessageBox()
        window.load()
    end}, {"No", function()
        closeMessageBox()
        window.load()
    end}, {"Cancel", function() closeMessageBox() end}}) end, ex, 0, 60, 30)
    ex = ex + 60
    button("Open", function() open(function(content, name)
        txt = content
        f = name
        dir = string.match(name, "^(.*/).*$") or "/"
        window.title = "Vurl IDE - " .. f
    end) end, ex, 0, 60, 30)
    ex = ex + 60
    button("Save", function()
        save(f, txt, "vurl", function(name)
            f = name window.title = "Vurl IDE - " .. f
        end)
    end, ex, 0, 60, 30)
    ex = ex + 60
    button("Run", function()
        save(f, txt, "vurl", function(name)
            f = name window.title = "Vurl IDE - " .. f
            openWindow("windows/vurl.lua", f)
        end)
    end, ex, 0, 60, 30)
    ex = ex + 60
    button("Help", function()
        messageBox("Vurl IDE", "Under construction")
    end, ex, 0, 60, 30)
    
    setFont("fonts/DejaVuSansMono.ttf")
    
    local textCursor = " "
    if math.floor(t*3) % 2 == 0 then
        textCursor = "_"
    end
    
    local f = love.graphics.getFont()
    local _, lines = f:getWrap(string.sub(txt, 1, cursorPos), textAreaWidth)
    local pos = #lines <= math.floor((windowHeight - 30) / f:getHeight()) and 0 or 0 - #lines * f:getHeight() + (windowHeight - 30)
    
    love.graphics.setScissor(windowX, windowY + 30, textAreaWidth, windowHeight - 30)
    
    text((cursorPos >= 1 and string.sub(txt, 1, cursorPos) or "") .. textCursor .. string.sub(txt, cursorPos+1), 0, 30 + pos, nil, textAreaWidth)
    
    love.graphics.setScissor()
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setScissor(windowX + textAreaWidth, windowY + 30, windowWidth-textAreaWidth, windowHeight-30)
    love.graphics.draw(preview, textAreaWidth, 30)
end

function window.quit()
    love.keyboard.setKeyRepeat(false)
end

return window
