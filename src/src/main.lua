local callbacks = {}
local err

local function drawErr(msg)
	if err then return else err = true end
	print(msg)
	love.audio.stop()
	love.mouse.setVisible(false)
	
	if switchScreen and currentScreen ~= crashScreen then
		switchScreen("screens/crash.lua", tostring(msg))
	else
		love.draw = nil
		love.draw = function()
			love.graphics.reset()
			love.graphics.scale(2)
			love.graphics.printf("CrapOS has failed.\n" .. tostring(msg), 0, 0, love.graphics.getWidth()/2)
		end
	end
end

function love.load()
	local ok, msg = pcall(callbacks.load)
	if not ok then drawErr(msg) end
end

function love.mousepressed(x, y, button)
	local ok, msg = pcall(callbacks.mousepressed, x, y, button)
	if not ok then drawErr(msg) end
end

function love.mousereleased(x, y, button)
	local ok, msg = pcall(callbacks.mousereleased, x, y, button)
	if not ok then drawErr(msg) end
end

function love.mousemoved(x, y, dx, dy)
	local ok, msg = pcall(callbacks.mousemoved, x, y, dx, dy)
	if not ok then drawErr(msg) end
end

function love.wheelmoved(x, y)
	local ok, msg = pcall(callbacks.wheelmoved, x, y)
	if not ok then drawErr(msg) end
end

function love.keypressed(key)
	local ok, msg = pcall(callbacks.keypressed, key)
	if not ok then drawErr(msg) end
end

function love.textinput(text)
	local ok, msg = pcall(callbacks.textinput, text)
	if not ok then drawErr(msg) end
end

function love.filedropped(file)
	local ok, msg = pcall(callbacks.filedropped, file)
	if not ok then drawErr(msg) end
end

function love.resize(width, height)
	local ok, msg = pcall(callbacks.resize, width, height)
	if not ok then drawErr(msg) end
end

function love.update(dt)
	local ok, msg = pcall(callbacks.update, dt)
	if not ok then drawErr(msg) end
end

function love.draw()
	local ok, msg = pcall(callbacks.draw)
	if not ok then drawErr(msg) end
end

function love.quit()
	local ok, msg = pcall(callbacks.quit)
	if not ok then drawErr(msg) end
end

function love.errorhandler(msg)
	love.audio.stop()
	love.mouse.setVisible(false)
	
	local traceback = debug.traceback()
	
	print(string.format("%s\n%s", msg, traceback))
	
	local buttonpressed
	
	local function showmsg(hasCopied)
		buttonpressed = love.window.showMessageBox(
			"Error",
			string.format("A very strange and unusual error has occured.\n\n%s\n\n%s", msg, traceback),
			{"OK", hasCopied and "Copied!" or "Copy Error", enterbutton = 1},
			"error"
		)
		
		if buttonpressed == 1 then
			return
		elseif buttonpressed == 2 then
			love.system.setClipboardText(string.format("%s\n%s", msg, traceback))
			showmsg(true)
		end
	end
	
	showmsg()
end

love.graphics.setNewFont(18)
love.graphics.setColor(1, 1, 1, 1)
love.graphics.print("Loading CrapOS...", 10, 10)
love.graphics.present()

local ok, chunk = pcall(love.filesystem.load, "system.lua")
if ok then
	local ok, msg = pcall(chunk)
	if not ok then
		drawErr(msg)
	else
		callbacks = msg
	end
else
	drawErr(chunk)
end
