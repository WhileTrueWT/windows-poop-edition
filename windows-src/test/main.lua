local gui = require "lib.wpgui"

local mainGui

local doThing = true

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
	
	local text1 = gui.Text{text = "Humanity's present understanding of aviation dictates that bees should lack any ability to fly, given their small wings in contrast to their fat little bodies. And yet, bees still fly.", width = 450}
	frame:put({text1}, {align = "left"})
	
	local textBox = gui.TextBox{label = "test!", onEnterPressed = function(self)
		messageBox("Text has been entered", self.value)
	end}
	local dropdown = gui.Dropdown{options = {"Hello", "World", "Third Thing"}}
	frame:put({textBox, dropdown}, {align = "left"})
	
	local checkBox = gui.CheckBox{value = doThing, onToggle = function(value)
		doThing = value
	end}
	local checkBoxLabel = gui.Text{text = "do thing?"}
	frame:put({checkBox, checkBoxLabel}, {align = "left"})
	
	mainGui:put({image, frame}, {align = "left"})
	
	local canvas = gui.Canvas{width = 400, height = 200, draw = function()
		love.graphics.clear(0, 0, 0, 1)
		if doThing then
			love.graphics.setColor(1, 0, 0, 1)
			love.graphics.rectangle("fill", math.sin(love.timer.getTime())*100 + 150, math.cos(love.timer.getTime())*50 + 50, 100, 100)
		end
	end}
	
	local multiline = gui.TextBox{multiline = true, label = "Type stuff!", height = 160}
	
	mainGui:put({canvas, multiline}, {align = "center"})
	
	local freeButton = gui.Button{label = "I'm free!", x = 50, y = 35, action = function(self)
		self.x = self.x + 5
	end}
	mainGui:put{freeButton}
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
