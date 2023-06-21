local screen = {}
local t
local errcode
local traceback

function screen.load(msg)
	error "lol"
	love.audio.stop()
	love.mouse.setVisible(false)
	t = -100
	
	if msg then
		errcode = msg
	else
		errcode = "[none available]"
	end
	
	traceback = debug.traceback()
end

function screen.update()
	if love.keyboard.isDown("r") then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			love.event.quit("restart")
		else
			switchScreen("screens/desktop.lua")
		end
	end
	
	if t < displayHeight then
		t = t + 6
	end
end

function screen.draw()
	love.graphics.setScissor(0, 0, displayWidth, t >= 0 and t or 0)
	rect(0, 0, displayWidth, displayHeight, {0, 0, 0.5})
	setFont("fonts/DejaVuSansMono.ttf")
	love.graphics.scale(2)
	text("Windows Poop Edition has suffered a horrible failiure and has crashed. Don't be alarmed; you knew this was going to happen.\n\nPress R to try to reload the desktop, or Shift+R to fully restart your computer.\n\nError description:\n" .. errcode .. "\n\n" .. traceback, 0, 0, {1, 1, 1}, displayWidth/2)
	love.graphics.origin()
	love.graphics.setScissor()
end

return screen
