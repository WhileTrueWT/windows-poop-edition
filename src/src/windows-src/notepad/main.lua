local utf8 = require "utf8"

local window = {}
window.title = "Notepad"
local txt
local t
local f
local cursorPos

local function moveUp()
    repeat
        if cursorPos <= 1 then break end
        cursorPos = cursorPos - 1
    until string.sub(txt, cursorPos, cursorPos) == "\n"
    if cursorPos > 0 then cursorPos = cursorPos - 1 end
end

local function moveDown()
    for i=1,2 do
        repeat
            if cursorPos > #txt then break end
            cursorPos = cursorPos + 1
        until string.sub(txt, cursorPos, cursorPos) == "\n"
    end
    cursorPos = cursorPos - 1
end

function window.load(file)
    txt = nil
    f = nil
    t = 0
    window.title = "Notepad"
    
    love.keyboard.setKeyRepeat(true)
    
    if file then open(function(text, name)
        txt = text
        f = file
        window.title = "Notepad - " .. file
    end, file) else txt = "" end
    
    cursorPos = 0
end

function window.keypressed(key)
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
        moveUp()
    end
    
    if key == "down" then
        moveDown()
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
end

function window.draw()
    if not txt then return end
    setFont("fonts/DejaVuSans.ttf")
    
    rect(0, 0, windowWidth, windowHeight, {1, 1, 1})
    
    rect(0, 0, windowWidth, 30, {0.75, 0.75, 0.75})
    
    local ex = 0
    button("New", function() messageBox("Notepad", "Save changes?", {{"Yes", function()
        save(f, txt, "txt")
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
        window.title = "Notepad - " .. f
        cursorPos = 0
    end) end, ex, 0, 60, 30)
    ex = ex + 60
    button("Save", function()
        save(f, txt, "txt", function(name) f = name window.title = "Notepad - " .. f end)
    end, ex, 0, 60, 30)
    
    setFont("fonts/DejaVuSansMono.ttf")
    
    local textCursor = " "
    if math.floor(t*3) % 2 == 0 then
        textCursor = "_"
    end
    
    local f = love.graphics.getFont()
    local _, lines = f:getWrap(string.sub(txt, 1, cursorPos), windowWidth)
    local pos = #lines <= math.floor((windowHeight/2 - 30) / f:getHeight()) and 0 or 0 - #lines * f:getHeight() + (windowHeight/2 - 30)
    
    love.graphics.setScissor(windowX, windowY + 30, windowWidth, windowHeight - 30)
    
    text((cursorPos >= 1 and string.sub(txt, 1, cursorPos) or "") .. textCursor .. string.sub(txt, cursorPos+1), 0, 30 + pos, nil, windowWidth)
    
    love.graphics.setScissor()
end

function window.wheelmoved(dx, dy)
    if dy > 0 then
        moveUp()
    elseif dy < 0 then
        moveDown()
    end
end

function window.close()
    messageBox("Notepad", "Save changes?", {
        {"Yes", function()
            closeMessageBox()
            save(f, txt, "txt", function()
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

