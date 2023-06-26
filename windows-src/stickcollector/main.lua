local window = {}
window.title = "Stick Collector"
window.fullscreen = true

local world
local player
local sticks
local speed = 0.2

local function generateWorld()
	local size = 200
	local stickCount = 200

	world = {}
	world.size = size
	world.sticks = {}

	for i=1,stickCount do
		local x = love.math.random(0, size)
		local y = love.math.random(0, size)
		table.insert(world.sticks, {x=x, y=y})
	end
end

local function resetPlayer()
	player = {x=0, y=0}
end

local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end

function window.load()
	generateWorld()
	resetPlayer()
	sticks = 0
end

function window.keypressed(key)
	if key == "escape" then
		closeWindow()
	end
end

function window.update()
	if love.keyboard.isScancodeDown("w") then
		player.y = player.y - speed
	end

	if love.keyboard.isScancodeDown("s") then
		player.y = player.y + speed
	end

	if love.keyboard.isScancodeDown("a") then
		player.x = player.x - speed
	end

	if love.keyboard.isScancodeDown("d") then
		player.x = player.x + speed
	end

	for i, stick in ipairs(world.sticks) do
		if checkCollision(player.x, player.y, 1, 1, stick.x, stick.y, 0.2, 1) then
			table.remove(world.sticks, i)
			sticks = sticks + 1
		end
	end
end

function window.draw()
	love.graphics.push()

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

	love.graphics.translate(windowWidth/2 + 0.5, windowHeight/2 + 0.5)
	love.graphics.scale(30)
	love.graphics.translate(0-player.x, 0-player.y)
	
	love.graphics.setColor(0, 0.2, 0, 1)
	love.graphics.rectangle("fill", 0, 0, world.size, world.size)

	love.graphics.setColor(0, 0.2, 1)
	love.graphics.rectangle("fill", player.x, player.y, 1, 1)

	for i, stick in ipairs(world.sticks) do
		love.graphics.setColor(0.8, 0.4, 0)
		love.graphics.rectangle("fill", stick.x, stick.y, 0.2, 1)
	end

	love.graphics.pop()

	text(sticks .. " sticks", 0, 0, {1, 1, 1})
	text("press escape to exit", 0, 20, {1, 1, 1})
end

return window
