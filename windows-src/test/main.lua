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
    
    local text1 = gui.Text{text = "wow another line. I probably should have tested this earlier.\nok it does work"}
    local image = gui.Image{file = "img.png", width = 200, height = 200}
    
    mainGui:put({text1, image}, {align = "center"})
    
    local text2 = gui.Text{text = "but does THIS work? turns out yeah."}
    local textBox = gui.TextBox{label = "test!", onEnterPressed = function(self)
        messageBox("Text has been entered", self.value)
    end}
    
    mainGui:put({text2, textBox}, {align = "left"})
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
