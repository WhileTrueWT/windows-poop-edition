local gui = require "lib.wpgui"

local mainGui
local textarea

local window = {}
window.title = "Notepad"
local f
local monofont = love.graphics.newFont("fonts/DejaVuSansMono.ttf", 14)

function window.load(file)
    f = nil
    window.title = "Notepad"
    
    mainGui = gui.Gui{
        width = windowWidth,
        height = windowHeight
    }
    
    toolbar = gui.Frame{
        width = windowWidth,
        marginX = 0,
        marginY = 0
    }
    
    toolbar:put({
        gui.Button{label = "New", action = function()
            messageBox("Notepad", "Save changes?", {{"Yes", function()
                save(f, textarea.value, "txt")
                closeMessageBox()
                window.load()
            end}, {"No", function()
                closeMessageBox()
                window.load()
            end}, {"Cancel", function() closeMessageBox() end}})
        end, marginX = 0, marginY = 0},
        
        gui.Button{label = "Open", action = function()
            open(function(content, name)
                textarea:setValue(content)
                f = name
                window.title = "Notepad - " .. f
            end) 
        end, marginX = 0, marginY = 0},
        
        gui.Button{label = "Save", action = function()
            save(f, textarea.value, "txt", function(name)
                f = name
                window.title = "Notepad - " .. f
            end)
        end, marginX = 0, marginY = 0},
    })
    
    textarea = gui.TextBox{
        multiline = true,
        width = windowWidth,
        height = windowHeight - toolbar.height,
        marginX = 0,
        marginY = 0,
        font = monofont
    }
    
    mainGui:put({toolbar}, {align = "center"})
    mainGui:put({textarea}, {align = "center"})
    
    if file then
        open(function(text, name)
            textarea:setValue(text)
            f = file
            window.title = "Notepad - " .. file
        end, file)
    else
        textarea:setValue("")
    end
end

function window.keypressed(key, ...)
    mainGui:keypressed(key, ...)
    
    if key == "tab" then
        for i=1,4 do
            window.textinput(" ")
        end
    end
end

function window.mousepressed(...)
    mainGui:mousepressed(...)
end

function window.textinput(...)
    mainGui:textinput(...)
end

function window.draw()
    mainGui:draw()
end

function window.wheelmoved(dx, dy)
    if dy > 0 then
        window.keypressed("up")
    elseif dy < 0 then
        window.keypressed("down")
    end
end

function window.close()
    messageBox("Notepad", "Save changes?", {
        {"Yes", function()
            closeMessageBox()
            save(f, textarea.value, "txt", function()
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

