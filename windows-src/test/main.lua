local gui = require "lib.wpgui"

local mainGui

local window = {}

function window.load()
    mainGui = gui.Gui{width = windowWidth, height = windowHeight}
    
    local image = gui.Image{file = "img.png", width = 200, height = 200}
    local frame = gui.Frame{}
    
    local text = gui.Text{text = "hello"}
    local button = gui.Button{label = "click", action = function()
        sound("sounds/default.wav")
        text.text = "yeah"
    end}
    frame:put({
        text,
        button,
    }, {align = "center"})
    
    local text1 = gui.Text{text = "I keep forgetting this test program is public. perhaps one day there will be Windows PE enthusiasts sifting through git history and coming across this. in which case, hi.", width = 450}
    frame:put({text1}, {align = "left"})
    
    local textBox = gui.TextBox{label = "test!", onEnterPressed = function(self)
        messageBox("Text has been entered", self.value)
    end}
    frame:put({textBox}, {align = "left"})
    
    mainGui:put({image, frame}, {align = "left"})
end

function window.draw()
    mainGui:draw()
end

function window.mousepressed(...)
    mainGui:mousepressed(...)
end

function window.keypressed(...)
    mainGui:keypressed(...)
end

function window.textinput(...)
    mainGui:textinput(...)
end

return window
