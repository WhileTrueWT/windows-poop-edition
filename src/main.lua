local totalSize
local isInstalling
local hasFinished
local copiedSize = 0
local currentDir = ""

local bodyColor = {1, 1, 1, 1}

local function determineDirSize(dir)
	local size = 0
	for _, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
		local info = love.filesystem.getInfo(dir .. "/" .. item)
		if info.type == "directory" then
			size = size + determineDirSize(dir .. "/" .. item)
		else
			size = size + (info.size or 0)
		end
	end
	return size
end

local function copyDir(src, dest)
	if src == "src/.git" then
		return
	end
	
	currentDir = dest
	coroutine.yield()
	
	if dest ~= "" then
		assert(love.filesystem.createDirectory(dest))
	end
	
	for _, item in ipairs(love.filesystem.getDirectoryItems(src)) do
		local info = love.filesystem.getInfo(src .. "/" .. item)
		if info.type == "directory" then
			copyDir(src .. "/" .. item, dest .. "/" .. item)
		else
			local data, size = love.filesystem.read(src .. "/" .. item)
			love.filesystem.write(dest .. "/" .. item, data)
			copiedSize = copiedSize + size
		end
	end
end
local copyDirCo = coroutine.create(copyDir)

local function beginInstall()
	isInstalling = true
	totalSize = determineDirSize("src")
	coroutine.resume(copyDirCo, "src", "")
end

local function finishInstall()
	isInstalling = false
	hasFinished = true
end

function love.load()
	love.window.setTitle("Windows Poop Edition 5 Installer")
	
	isInstalling = false
	hasFinished = false
	love.graphics.setNewFont(16)
	
	setupbg = love.graphics.newImage("setupbg.png")
	logo = love.graphics.newImage("logo.png")
end

function love.update()
	if isInstalling then
		if coroutine.status(copyDirCo) == "dead" then
			finishInstall()
		else
			coroutine.resume(copyDirCo)
		end
	end
end

function love.draw()
	local width, height = love.graphics.getDimensions()
	local bodyWidth = width*0.6
	local bodyHeight = height*0.6
	local bodyLeft = width/2 - bodyWidth/2
	local bodyTop = height/2 - bodyHeight/2
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(setupbg, 0, 0, nil, width/setupbg:getWidth(), height/setupbg:getHeight())
	
	love.graphics.setColor(bodyColor)
	love.graphics.rectangle('fill', bodyLeft, bodyTop, bodyWidth, bodyHeight)
	
	love.graphics.translate(bodyLeft, bodyTop)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(logo, 10, 10)
	love.graphics.translate(0, logo:getHeight()+10)
	
	love.graphics.setColor(0.1, 0.1, 0.1)
	
	if not isInstalling and not hasFinished then
	
		love.graphics.printf(
			"Welcome to the Windows Poop Edition 5 installer. This program will prepare your computer for the wonderful world of Windows PE!\n\nPress any key to begin installing...",
			10, 10,
			bodyWidth-20
		)
	
	elseif hasFinished then
		
		love.graphics.printf(
			"Windows Poop Edition has installed successfully, I think. Now you can experience this OS's wonderful technologies!\n\nPress any key to reboot into Windows PE...",
			10, 10,
			bodyWidth-20
		)
	
	else
		
		love.graphics.printf("Windows PE is installing...", 10, 10, love.graphics.getWidth()-20)
		
		love.graphics.print(string.format("Copying folder: %s", currentDir), 10, 30)
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle('fill', 10, 60, 500, 50)
		
		love.graphics.setColor(0, 0.5, 0)
		love.graphics.rectangle('fill', 10, 60, (copiedSize / totalSize)*500, 50)
		
		love.graphics.setColor(0.1, 0.1, 0.1)
		
	end
end

function love.keypressed()
	if not isInstalling and not hasFinished then
		beginInstall()
	elseif hasFinished then
		love.event.quit("restart")
	end
end
