local gui = require "lib.wpgui"

local mainGui

local window = {}

function window.load()
    mainGui = gui.Gui{width = windowWidth, height = windowHeight}
    
    local text = gui.Text{text = "hello"}
    local button = gui.Button{label = "click", action = function()
        sound("sounds/default.wav")
        text.text = "yeah"
    end}
    
    mainGui:put({
        text,
        button,
    }, {align = "center"})
end

function window.draw()
    mainGui:draw()
end

function window.mousepressed(...)
    mainGui:mousepressed(...)
end

return window
