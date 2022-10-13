local gui = require "lib.wpgui"

local mainGui

local window = {}

function window.load()
    mainGui = gui.Gui{}
    
    mainGui:put({
        gui.Text{text = "hello"},
    })
end

function window.draw()
    mainGui:draw()
end

return window
