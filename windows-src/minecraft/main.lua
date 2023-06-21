local window = {}
window.title = "Minecraft"
window.hideWindowDec = true
window.windowWidth, window.windowHeight = displayWidth, displayHeight
window.windowX, window.windowY = 0, 0

local screen
local screens = {}

local t

local splashText = {
	"Legitimate!",
	"Genuine!",
	"Won't crash!",
	"Isn't a sussy imposter!",
	"the!",
	"Full of bees and apioforms!",
	"Bug free!",
	"Has an assload of bugs!",
	"Will definitely crash!",
	"The Real Deal!",
	"Hopefully you know this is fake!",
	"So Cool!",
	"The Best Game Ever!",
	"We banned Dream from this version",
	"Probably not very good!",
}
local chosenSplashText

local function centeredText(t, y)
	local f = love.graphics.getFont()
	local x = windowWidth/2 - f:getWidth(t)/2
	text(t, x, y, {1, 1, 1})
end

local function setScreen(id)
	screen = id
	if screens[screen] and screens[screen].load then screens[screen].load() end
end

screens.loading = {}
function screens.loading.load()
	t = 0
end
function screens.loading.draw()
	image("images/jomang.png", 0, 0, windowWidth, windowHeight)
end
function screens.loading.update(dt)
	t = t + dt
	if t >= 3.5 then
		t = 0
		setScreen("title")
	end
end

screens.title = {}
function screens.title.load()
	t = 0
	chosenSplashText = splashText[love.math.random(#splashText)]
end
function screens.title.update(dt)
   t = t + dt
end
function screens.title.draw()
	image("images/minecraft-background.png", 0, 0, windowWidth, windowHeight)
	image("images/minecraft-logo.png", windowWidth/2 - 420, 150)
	love.graphics.push()
	love.graphics.translate(windowWidth/2, 250)
	love.graphics.scale(math.sin(t*12)/6 + 2)
	text(chosenSplashText, 0, 0, {0, 0, 0})
	text(chosenSplashText, 1, 1, {1, 1, 0})
	love.graphics.pop()
	text("Minecraft Poop Edition 1.69.1\nCopyright CrapOS or whatever", 0, windowHeight-30, {1, 1, 1})

	local y = 300
	button("Singleplayer", function() setScreen("world") end, windowWidth/2 - 150, y, 300, 60)
	y = y + 70
	button("Multiplayer", function() closeWindow() messageBox("Minecraft", "Minecraft has unexpectedly quit while trying to establish an Internet connection. (LOL)", nil, "critical") end, windowWidth/2 - 150, y, 300, 60)
	y = y + 70
	button("Minecraft Realms", function() messageBox("Minecraft", "Error: Nobody actually uses this, right?", nil, "exc") end, windowWidth/2 - 150, y, 300, 60)
	y = y + 70
	button("Quit", function() closeWindow() end, windowWidth/2 - 150, y, 300, 60)
end

screens.world = {}
function screens.world.draw()
	rect(0, 0, windowWidth, windowHeight, {0.4, 0.4, 0.4})
	centeredText("Saved worlds:", 100)
	centeredText("None! If you had worlds here before, we probably deleted them for no reason. Sorry!", 130)
	button("Create New World", function() setScreen("worldload") end, windowWidth/2 - 150, 300, 300, 60)
	button("Back", function() setScreen("title") end, windowWidth/2 - 150, 370, 300, 60)
end

screens.worldload = {}
function screens.worldload.load()
	t = 0
end
function screens.worldload.update(dt)
	t = t + dt
	if t >= 3 then
		setScreen("game")
	end
end
function screens.worldload.draw()
	rect(0, 0, windowWidth, windowHeight, {0.4, 0.4, 0.4})
	centeredText("Loading world...", 100)
end

screens.game = {}
local world
local blockTypes = {
	air = {
		color = {0, 0, 0, 0}
	},
	dirt = {
		color = {0.3, 0.1, 0, 1}
	},
	grass = {
		color = {0.1, 0.4, 0.1, 1}
	},
	stone = {
		color = {0.3, 0.3, 0.3, 1}
	},
	coal = {
		color = {0.1, 0.1, 0.1, 1}
	},
	iron = {
		color = {0.8, 0.8, 0.8, 1}
	},
	gold = {
		color = {0.8, 0.7, 0.4, 1}
	},
	diamond = {
		color = {0.1, 0.8, 1, 1}
	},
}
local blockTypeOrder = {"dirt", "grass", "stone", "coal", "iron", "gold", "diamond"}
local player = {}
local inventory = {}
local inventorySelection
local canJump
local playerSize = 0.8

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
		 x2 < x1+w1 and
		 y1 < y2+h2 and
		 y2 < y1+h1
end

local function checkPlayerCollision()
	for x=math.floor(player.x)-1, math.floor(player.x)+1 do
		for y=math.floor(player.y)-1, math.floor(player.y)+1 do
			if world.map[x] and world.map[x][y] and world.map[x][y].type ~= "air" and checkCollision(player.x, player.y, playerSize, playerSize, x, y, 1, 1) then
				return true
			end
		end
	end
	return false
end

local function movePlayer(dx)
	player.x = player.x + dx
	
	if checkPlayerCollision() then
		player.x = player.x - dx
	end
end

local function playerDie()
	player = {x=20, y=15, speedx=0, speedy=0}
	inventory = {}
	inventorySelection = 1
	for i, block in ipairs(blockTypeOrder) do
		inventory[block] = 0
	end
end

function screens.game.load()
	world = {map={}}
	player = {x=20, y=15, speedx=0, speedy=0}
	inventory = {}
	inventorySelection = 1
	for i, block in ipairs(blockTypeOrder) do
		inventory[block] = 0
	end
	canJump = false
	
	local noiseZ = love.math.random(0, 1000)
	for x=1,480 do
		world.map[x] = {}
		for y=1,60 do
			local block = {}
			
			if y>=49 then
				block = {type="stone"}
			elseif y < 20 then
				block = {type="air"}
			else
				local n = love.math.noise(x/16, y/16, noiseZ)
				local threshold = y>=40 and (0.5 + (y-40)/40) or 0.5
				if n <= threshold then
					if y<40 then
						if y==1 or (y>1 and world.map[x][y-1].type == "air") then
							block = {type="grass"}
						else
							block = {type="dirt"}
						end
					else
						block = {type="stone"}
					end
				else
					block = {type="air"}
				end
			end
			
			if block.type == "stone" then
				if love.math.random(1, 50) == 1 then
					block.type = "coal"
				elseif love.math.random(1, 100) == 1 then
					block.type = "iron"
				elseif love.math.random(1, 200) == 1 then
					block.type = "gold"
				elseif love.math.random(1, 500) == 1 then
					block.type = "diamond"
				end
			end
			
			world.map[x][y] = block
		end
	end
	
	t = 0
end

function screens.game.update(dt)
	t = t + dt
	
	if love.keyboard.isDown("d") then
		movePlayer(0.2)
	end
	
	if love.keyboard.isDown("a") then
		movePlayer(-0.2)
	end
	
	if canJump and love.keyboard.isDown("w") then
		player.speedy = -0.3
	end
	
	player.speedy = player.speedy + 0.02
	player.y = player.y + player.speedy
	
	if checkPlayerCollision() then
		if not canJump then canJump = true end
		player.y = player.y - player.speedy
		player.speedy = 0
	elseif canJump then
		canJump = false
	end
	
	if player.y > 60 then
		playerDie()
	end
end

function screens.game.draw()
	rect(0, 0, windowWidth, windowHeight, {0.4, 0.5, 0.7, 1})
	
	love.graphics.push()
	love.graphics.translate(windowWidth/2, windowHeight/2)
	love.graphics.scale(40)
	love.graphics.translate(0-player.x, 0-player.y)
	
	local lx, ly = math.floor((love.mouse.getX() - windowWidth/2)/40 + player.x), math.floor((love.mouse.getY() - windowHeight/2)/40 + player.y)

	for x, xt in ipairs(world.map) do
		for y, block in ipairs(xt) do
			local sx, sy = love.graphics.transformPoint(x, y)
			if sx >= -40 and sx <= windowWidth+40
			and sy >= -40 and sy <= windowHeight+40 then
				rect(x, y, 1, 1, blockTypes[block.type].color)
				if math.abs(math.floor(player.x) - lx) <= 3 and math.abs(math.floor(player.y) - ly) <= 3
				and x == lx and y == ly then
					rect(x, y, 1, 1, {1, 1, 1, 0.5})
				end
			end
		end
	end
	
	rect(player.x, player.y, playerSize, playerSize, {0.5, 0, 1, 1})
	
	love.graphics.pop()
	
	local x = 10
	for i, block in ipairs(blockTypeOrder) do
		local count = inventory[block]
		rect(x, windowHeight-100, 100, 100, (inventorySelection == i and {0, 0.5, 1, 0.5} or {0.5, 0.5, 0.5, 0.5}))
		rect(x+10, windowHeight-90, 80, 80, blockTypes[block].color)
		text(tostring(count), x, windowHeight-30, {1, 1, 1, 1})
		x = x + 110
	end
end

function screens.game.mousepressed(x, y, button)
	local lx, ly = math.floor((x - windowWidth/2)/40 + player.x), math.floor((y - windowHeight/2)/40 + player.y)
	if math.abs(math.floor(player.x) - lx) <= 3 and math.abs(math.floor(player.y) - ly) <= 3
	and world.map[lx][ly] then
		if button == 1 then
			if world.map[lx][ly].type ~= "air" then
				inventory[world.map[lx][ly].type] = inventory[world.map[lx][ly].type] and (inventory[world.map[lx][ly].type] + 1) or 1
				world.map[lx][ly].type = "air"
			end
		elseif button == 2 then
			if
				inventory[blockTypeOrder[inventorySelection]] > 0
				and world.map[lx][ly].type == "air"
				and not (
					(lx == math.floor(player.x) or lx == math.floor(player.x+playerSize))
					and (ly == math.floor(player.y) or ly == math.floor(player.y+playerSize))
				)
			then
				world.map[lx][ly].type = blockTypeOrder[inventorySelection]
				inventory[blockTypeOrder[inventorySelection]] = inventory[blockTypeOrder[inventorySelection]] - 1
			end
		end
	end
end

function screens.game.keypressed(key)
	local n = tonumber(key)
	if n and n > 0 and n <= #blockTypeOrder then
		inventorySelection = n
	end
end

function window.load()
	t = 0
	setScreen("loading")
end

function window.update(dt)
	if screens[screen] and screens[screen].update then screens[screen].update(dt) end
end

function window.draw()
	if screens[screen] and screens[screen].draw then screens[screen].draw() end
end

function window.mousepressed(x, y, button)
	if screens[screen] and screens[screen].mousepressed then screens[screen].mousepressed(x, y, button) end
end

function window.keypressed(key)
	if key == "escape" then
		closeWindow()
	end
	if screens[screen] and screens[screen].keypressed then screens[screen].keypressed(key) end
end

return window
