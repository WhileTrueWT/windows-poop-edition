local screen = {}
local t
local restart

function screen.load(arg)
	restart = arg == "restart" and true or false
	love.mouse.setVisible(false)
	
	love.audio.stop()
	sound("sounds/shutdown.wav")
	t = 0
end

function screen.update(dt)
	t = t + dt
	if t >= 5 or love.keyboard.isDown("lshift") and love.keyboard.isDown("s") and love.keyboard.isDown("k") then
		if restart then
			love.event.quit("restart")
		else
			love.event.quit()
		end
	end
end

function screen.draw()
	local f = love.graphics.getFont()
	local txt = "Shutting down..."
	image("images/logo.png", displayWidth/2 - 50, displayHeight/2 - 50, 100, 100)
	text(txt, displayWidth/2 - f:getWidth(txt)/2, displayHeight/2 + 60, {1, 1, 1})
end

return screen
