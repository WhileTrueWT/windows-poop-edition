-- FAIR WARNING: THIS CODE IS FUCKING SHIT!!!
-- Proceed at own risk!!!!!!!!!

local utf8 = require "utf8"
local filegui = require "lib.filegui"

displayWidth, displayHeight = 1280, 720

local startingScreen = "screens/startup.lua"
local crashScreen = "screens/crash.lua"

local screens = {}
windows = {}
currentScreen = nil
local currentWindow, currentMessageBox, currentTextInputBox
local t

local canClick

local clipboard = {"text", ""}

openWindows = {}

windowX, windowY, windowWidth, windowHeight = 0, 0, 0, 0

local isDragging = false
local isResizingX = false
local isResizingY = false

--local callingWindow

stdin = ""
stdout = ""

-- this thing is really stupid and a possibly bad idea by past me
-- but i'll deal with it later (never)
function print(...)
	for _, v in ipairs({...}) do
		stdout = stdout .. tostring(v) .. "\t"
	end
	stdout = stdout .. "\n"
end


-- STYLE

style = {}

style.text = {}
style.text.color = {0, 0, 0}

style.button = {}
style.button.color = "images/button.png"
style.button.textColor = {0.1, 0.1, 0.1}
style.button.outlineColor = {0.1, 0.1, 0.1}

style.bar = {}
style.bar.color = {0.75, 0.75, 0.75}

style.taskbar = {}
style.taskbar.color = {0, 0.25, 1}
style.taskbar.height = 40
style.taskbar.startButtonColor = {0, 0.75, 0}

style.windowBar = {}
style.windowBar.color = "images/gradient.png"
style.windowBar.inactiveColor = "images/button.png"
style.windowBar.closeButtonColor = "images/closebutton.png"
style.windowBar.minimizeButtonColor = "images/minimizebutton.png"

style.window = {}
style.window.backgroundColor = {0.95, 0.95, 0.95}

style.cursor = {}
style.cursor.image = "images/cursor.png"

style.font = "fonts/DejaVuSans.ttf"

-- SETTINGS

settings = {}

settings.background = "images/background.png"
settings.themeColor = {1, 1, 1, 1}
settings.appendToPath = "false"

-- SOUND SCHEME

soundScheme = {}
soundScheme.default = "sounds/default.wav"
soundScheme.exc = "sounds/exc.wav"
soundScheme.critical = "sounds/critical.wav"
soundScheme.ast = "sounds/ast.wav"

-- MESSAGE BOX ICONS

messageBoxIcons = {}
messageBoxIcons.default = "images/icons/info.png"
messageBoxIcons.exc = "images/icons/exc.png"
messageBoxIcons.critical = "images/icons/critical.png"
messageBoxIcons.ast = "images/icons/info.png"

local function loadSettings(file)
	if not love.filesystem.getInfo(file) then return end
	local f = love.filesystem.newFile(file)
	f:open("r")
	for line in f:lines() do
		local k, v = string.match(line, "([^=]+)=([^=]+)")
		if k and v then
			local d1, d2, d3, d4 = string.match(v, "(%d+) (%d+) (%d+) (%d+)")
			if d1 and d2 and d3 and d4 then
				v = {tonumber(d1)/255, tonumber(d2)/255, tonumber(d3)/255, tonumber(d4)/255}
			end
			settings[k] = v
		end
	end
	f:close()
end

local function saveSettings(file)
	local t = ""
	for k,v in pairs(settings) do
		if type(v) == "table" then
			local s = ""
			for _, n in ipairs(v) do
				s = s .. tostring(math.floor(n * 255)) .. " "
			end
			v = s
		end
		t = t .. k .."=" .. v .. "\n"
	end
	love.filesystem.write(file, t)
end

-- SOUND

local sounds = {}

function importSound(file, type)
	if sounds[file] then return end
	
	local filedata
	if callingWindow and callingWindow.resources and callingWindow.resources[file] then
		filedata = callingWindow.resources[file]
	else
		if not love.filesystem.getInfo(file, "file") then return nil, "ERROR: file '" .. tostring(file) .. "' does not exist"  end
	end
	
	local id = filedata and ("@" .. callingWindow.file .. ":" .. file) or file
	
	type = type or "static"
	sounds[id] = love.audio.newSource(filedata or file, type)
	return id
end

function sound(s)
	if not sounds[s] then
		s = importSound(s)
	end
	
	love.audio.play(sounds[s])
end

-- OS FUNCTIONS, or whatever

function switchScreen(id, arg)
	if not screens[id] then return "ERROR: no such screen '" .. tostring(id) .. "'" end
	
	currentWindow = nil
	currentMessageBox = nil
	currentTextInputBox = nil
	
	openWindows = {}
	
	local prevScreen = currentScreen
	currentScreen = id
	if screens[currentScreen].load then
		local ok, msg = pcall(screens[currentScreen].load, arg)
		if not ok then
			if currentScreen ~= crashScreen then
				switchScreen(crashScreen, msg)
				return
			else
				currentScreen = prevScreen
				love.window.showMessageBox(
					"Crash Failure",
					"The system has failed to crash because the crash screen has an error. How ironic.\n\n" .. msg,
					"error"
				)
			end
		end
	end
end

function openWindow(file, arg)
	if string.match(file, "%.lua$") then
		legacyOpenWindow(file, arg)
		return
	end
	
	local targetFormatVersion = "0.0.0"
	local tMajor, tMinor, tPatch = string.match(targetFormatVersion, "^(%d+).(%d+).(%d+)$")
	
	if not love.filesystem.getInfo(file, "file") then
		local err = string.format("ERROR: file '%s' does not exist", file)
		messageBox("Error", err, nil, "critical")
		return err
	end
	
	local data = love.filesystem.read(file)
	
	local magicNumber, pos = love.data.unpack("c2", data)
	if magicNumber ~= string.char(132, 248) then
		local err = string.format("%s is not a valid Windows PE application. (Magic number mismatch)", file)
		messageBox("Error", err, nil, "critical")
		return err
	end
	
	local formatVersion, programName, programIcon
	formatVersion, programName, programIcon, pos = love.data.unpack("zzz", data, pos)
	local vMajor, vMinor, vPatch = string.match(formatVersion, "^(%d+).(%d+).(%d+)$") or function()
		
		local err = string.format("Error decoding '%s': misformatted version string", file)
		messageBox("Error", err, nil, "critical")
		return err
		
	end
	
	if vMajor ~= tMajor then
		local err = string.format("%s: This file's format is of an incompatable version (%s, expected %d.x.x)", file, formatVersion, tMajor)
		messageBox("Error", err, nil, "critical")
		return err
	end
	
	local resnames = {}
	local rescount
	rescount, pos = love.data.unpack("<I8", data, pos)
	
	for _ = 1, rescount do
		local name
		name, pos = love.data.unpack("z", data, pos)
		
		table.insert(resnames, name)
	end
	
	local resources = {}	
	for _, name in ipairs(resnames) do
		local s
		s, pos = love.data.unpack("s8", data, pos)
		resources[name] = love.filesystem.newFileData(s, name)
	end
	
	if not resources["main.lua"] then
		local err = string.format("ERROR: executable '%s' has no entry point", file)
		messageBox("Error", err, nil, "critical")
		return err
	end
	
	local window, err = importWindow(resources["main.lua"])
	if err then
		messageBox("Error", err, nil, "critical")
		return err
	end
	
	currentMessageBox = nil
	currentTextInputBox = nil
	isDragging = false
	window.isActive = true
	window.file = file
	window.icon = programIcon
	
	window.resources = {}
	for k,v in pairs(resources) do
		window.resources[k] = v
	end
	
	table.insert(openWindows, window)
	
	callingWindow = window
	
	local id = #openWindows
	window.id = id
	
	window.windowWidth = window.windowWidth or 720
	window.windowHeight = window.windowHeight or 480
	window.windowX = window.windowX or (displayWidth / 2 - window.windowWidth / 2) + (id-1) * 40
	window.windowY = window.windowY or (displayHeight / 2 - window.windowHeight / 2) + (id-1) * 40
	
	if window.resizable == nil then window.resizable = true end
	
	if window.fullscreen then
		window.hideWindowDec = true
		window.windowWidth = displayWidth
		window.windowHeight = displayHeight
		window.windowX = 0
		window.windowY = 0
		window.resizable = false
	end
	
	windowX, windowY, windowWidth, windowHeight = window.windowX, window.windowY, window.windowWidth, window.windowHeight
	
	if openWindows[id].load then
		local ok, msg = pcall(openWindows[id].load, arg)
		if not ok then
			closeWindow(callingWindow, true)
			messageBox("Program Error", msg, {{"OK", function() closeMessageBox() end}})
		end
	end
	
	showWindow(id)
end

function legacyOpenWindow(file, arg)
	local window, err = importWindow(file)
	if err then
		messageBox("Error", err, nil, "critical")
		return err
	end
	
	currentMessageBox = nil
	currentTextInputBox = nil
	isDragging = false
	window.isActive = true
	window.file = file
	
	table.insert(openWindows, window)
	
	callingWindow = window
	
	local id = #openWindows
	window.id = id
	
	window.windowWidth = window.windowWidth or 720
	window.windowHeight = window.windowHeight or 480
	window.windowX = window.windowX or (displayWidth / 2 - window.windowWidth / 2) + (id-1) * 40
	window.windowY = window.windowY or (displayHeight / 2 - window.windowHeight / 2) + (id-1) * 40
	
	windowX, windowY, windowWidth, windowHeight = window.windowX, window.windowY, window.windowWidth, window.windowHeight
	
	if openWindows[id].load then
		local ok, msg = pcall(openWindows[id].load, arg)
		if not ok then
			closeWindow(callingWindow, true)
			messageBox("Program Error", msg, {{"OK", function() closeMessageBox() end}})
		end
	end
	showWindow(#openWindows)
end

--[[
function openSubwindow(window)
	currentMessageBox = nil
	currentTextInputBox = nil
	isDragging = false
	window.isActive = true
	
	table.insert(openWindows, window)
	
	local id = #openWindows
	window.id = id
	if openWindows[id].load then
		local ok, msg = pcall(openWindows[id].load, arg)
		if not ok then
			closeWindow(nil, true)
			messageBox("Program Error", msg, {{"OK", function() closeMessageBox() end}})
		end
	end
	showWindow(#openWindows)
end
--]]

function closeWindow(window, force)
	window = window or callingWindow or openWindows[currentWindow]
	
	if not force and window and window.close then
		local status = window.close()
		if status then
			return status
		end
	end
	
	for i, w in ipairs(openWindows) do
		if w == window then
			table.remove(openWindows, i)
			break
		end
	end
	
	if #openWindows > 0 then
		local i = #openWindows
		
		while i > 0 and not openWindows[i].isActive do
			i = i - 1
		end
		
		if i < 1 then
			currentWindow = nil
		else
			currentWindow = i
		end
	else
		currentWindow = nil
	end
	
	currentMessageBox = nil
	currentTextInputBox = nil
end

function showWindow(id)
	currentWindow = id
	if not openWindows[currentWindow] then return end
	local window = openWindows[currentWindow]	
	   
	window.isActive = true
end

function hideWindow()
	if currentWindow == nil then return end
	
	openWindows[currentWindow].isActive = false
	if currentWindow > 1 then
		currentWindow = currentWindow - 1
	else
		currentWindow = nil
	end
end

function isWindowOpen()
	return (currentWindow ~= nil)
end

function isMessageBoxShowing()
	return (currentMessageBox ~= nil)
end

function isTextInputShowing()
	return (currentTextInputBox ~= nil)
end

function messageBox(title, text, buttons, s)
	title = title or "Windows"
	text = text or ""
	buttons = buttons or {{"OK", function() closeMessageBox() end}}
	local icon = soundScheme[s] and s or "default"
	s = soundScheme[s] or s or soundScheme.default
	currentMessageBox = {title=title, text=text, buttons=buttons, icon=icon}
	if sounds[s] and sounds[s]:isPlaying() then sounds[s]:stop() end
	sound(s)
end

function closeMessageBox()
	currentMessageBox = nil
end

function textInput(title, onfinish)
	currentTextInputBox = {title=title, input="", onfinish=onfinish, type="text", window=callingWindow}
end

function fileInput(onfinish, startdir)
	filegui.cd = function(path)
		filegui.initFileList(path)
	end
	filegui.initFileList(startdir or "user/")
	currentTextInputBox = {title="", input="", onfinish=onfinish, type="fileopen", window=callingWindow}
end

function dirInput(onfinish, startdir)
	startdir = startdir or "user/"
	filegui.cd = function(path)
		currentTextInputBox.dir = path
		filegui.initFileList(path)
	end
	filegui.initFileList(startdir)
	currentTextInputBox = {title="", input="", onfinish=onfinish, type="diropen", dir=startdir, window=callingWindow}
end

function fileSaveInput(onfinish, startdir)
	filegui.cd = function(path)
		filegui.initFileList(path)
	end
	filegui.initFileList(startdir or "user/")
	currentTextInputBox = {title="", input="", onfinish=onfinish, type="filesave", window=callingWindow}
end

function open(onfinish, file, startdir)
	if file then
		onfinish(love.filesystem.read(file), file)
	else
		fileInput(function(path)
			onfinish(love.filesystem.read(path), path)
		end, startdir)
	end
end

function save(dest, content, ext, onfinish)
	onfinish = onfinish or function() end
	local function s(dest, content, ext)
		if ext and not string.match(dest, "%.%w+$") then
			dest = dest .. "." .. ext
		end
		
		love.filesystem.write(dest, content)
		onfinish(dest)
	end
	
	if not dest then
		fileSaveInput(function(text)
			s("user/" .. text, content, ext)
			dest = "user/" .. text
		end)
	else
		s(dest, content, ext)
	end
end

function getResource(path)
	if callingWindow and callingWindow.resources and callingWindow.resources[path] then
		return callingWindow.resources[path]
	else
		return nil
	end
end

function loadLocalScript(path)
	local filedata = getResource(path)
	if not filedata then return end
	
	local ok, chunk = pcall(loadstring, filedata:getString(), filedata:getFilename())
	
	if not ok then
		messageBox("Program Error", string.format("ERROR occured while loading local script '%s'\n%s", tostring(path), tostring(chunk)), nil, "critical")
		return
	end
	
	return chunk
end

function shutdown(restart)
	local refusingWindows = {}
	for id = #openWindows, 1, -1 do
		local window = openWindows[id]
		local status = closeWindow(window)
		if status then
			table.insert(refusingWindows, {id=id, window=window})
		end
	end
	
	if #refusingWindows > 0 then
		local s = ""
		for i, w in ipairs(refusingWindows) do
			s = s .. (w.window and w.window.title or w.window.file or "???") .. (i < #refusingWindows and ", " or "")
		end
		messageBox(nil, "The following programs are preventing Windows from shutting down, because they are being stubborn and refusing to close:\n" .. s .. "\n\nYou can either go and deal with these whiny programs, or force them to shutdown anyways.", {
			{"OK", function() closeMessageBox() end},
			{"Force Quit", function()
				for _, w in ipairs(refusingWindows) do
					closeWindow(w, true)
				end
				switchScreen("screens/shutdown.lua", restart and "restart")
			end}
		})
		return
	end
	
	switchScreen("screens/shutdown.lua", restart and "restart")
end

function copy(type, data)
	clipboard = {type, data}
end

function paste()
	return clipboard
end

function selectColor(onfinish)
	textInput("Enter RGB color (ex. 255 0 128)", function(text)
		local terms = {}
		for t in string.gmatch(text, "%S+") do
			table.insert(terms, tonumber(t) or 0)
		end
		
		for i=1,3 do
			terms[i] = tonumber(terms[i]) or 0
		end
		
		onfinish{terms[1] / 255, terms[2] / 255, terms[3] / 255, 1}
	end)
end

-- just noticed these two functions are completely redundant lol
-- i wont remove them, just in case it breaks some random thing
function isWindowOpen()
	if currentWindow then
		return true
	else
		return false
	end
end

function isMessageBox()
	if currentMessageBox then
		return true
	else
		return false
	end
end

local function call(func, ...)
	local ok, msg = pcall(func, ...)
	if not ok then
		closeWindow(nil, true)
		messageBox("Program Error", msg, {{"OK", function() closeMessageBox() end}}, "critical")
	end
end

local function callScreen(func, ...)
	local ok, msg = pcall(func, ...)
	if not ok then 
		if currentScreen ~= crashScreen then
			switchScreen(crashScreen, msg)
		else
			error(msg)
		end
	end
end

-- FONTS

local fonts = {}

function importFont(file, size)
	if fonts[file] then return end
	
	if not love.filesystem.getInfo(file) then return "ERROR: file '" .. tostring(file) .. "' does not exist"  end
	
	size = size or 14
	fonts[file] = love.graphics.newFont(file, size)
end

function setFont(f)
	if fonts[f] then love.graphics.setFont(fonts[f]) end
end

-- RECTANGLE

function rect(x, y, width, height, color)
	color = color or {1, 1, 1}
	
	love.graphics.setColor(color)
	love.graphics.rectangle("fill", x, y, width, height)
end

-- OUTLINE

function outline(x, y, width, height, color)
	color = color or {0, 0, 0}
	
	love.graphics.setColor(color)
	love.graphics.rectangle("line", x, y, width, height)
end

-- TEXT

function text(t, x, y, color, width)
	color = color or style.text.color
	width = width or displayWidth
	
	love.graphics.setColor(color)
	love.graphics.printf(t, x, y, width)
end

-- IMAGE

local images = {}

function importImage(file)
	if images[file] then return end
	
	local filedata
	
	if (callingWindow and callingWindow.resources and callingWindow.resources[file]) then
		filedata = callingWindow.resources[file]
	else
		if not love.filesystem.getInfo(file, "file") then return nil, "ERROR: file '" .. tostring(file) .. "' does not exist"  end
	end
	
	local id = filedata and ("@" .. callingWindow.file .. ":" .. file) or file
	
	images[id] = love.graphics.newImage(filedata or file)
	return id
end

function image(img, x, y, width, height, color)
	if (not images[img]) and not (callingWindow and images["@" .. callingWindow.file .. ":" .. img]) then
	--if not images[img] then
		local err
		img, err = importImage(img)
		if err then
			return
		end
	end
	
	if callingWindow and images["@" .. callingWindow.file .. ":" .. img] then
		img = "@" .. callingWindow.file .. ":" .. img
	end
	
	color = color or {1, 1, 1, 1}
	
	love.graphics.setColor(color)
	local sx, sy = 1, 1
	if width then sx = width / images[img]:getWidth() end
	if height then sy = height / images[img]:getHeight() end
	love.graphics.draw(images[img], x, y, nil, sx, sy)
end

-- BUTTON

canClick = true

function button(t, onclick, x, y, width, height, color, textColor, line, tint)
	local anyButton
	if type(onclick) == "table" then
		anyButton = onclick.any
		onclick = onclick[1]
	else
		anyButton = false
	end
	color = color or style.button.color
	textColor = textColor or style.button.textColor
	if line == nil then line = true end
	tint = tint or {1, 1, 1, 1}
	local f = love.graphics.getFont()
	
	local brightnessOffset = 0
	
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
	if x <= mx and mx <= x + width and y <= my and my <= y + height then
		if (anyButton and love.mouse.isDown(1, 2, 3) or love.mouse.isDown(1)) and canClick then
			call(onclick)
			canClick = false
		else
			brightnessOffset = 0.1
		end
	else
		brightnessOffset = 0
	end
	
	local newColor
	
	if type(color) == "string" then
		if brightnessOffset > 0 then
			newColor = {1, 1, 1, 0.25}
		else
			newColor = {0, 0, 0, 0}
		end
		image(color, x, y, width, height, tint)
		rect(x, y, width, height, newColor)
	else
		newColor = {color[1] + brightnessOffset, color[2] + brightnessOffset, color[3] + brightnessOffset, color[4]}
		rect(x, y, width, height, newColor)
	end
	if line then outline(x, y, width, height, style.button.outlineColor) end
	text(t, math.floor(x + width/2 - f:getWidth(t)/2), math.floor(y + height/2 - f:getHeight()/2), textColor)
end

-- SCREENS

local arg

local function importScreen(file)
	if screens[file] then return end
	
	if not love.filesystem.getInfo(file) then return "ERROR: file '" .. tostring(file) .. "' does not exist"  end
	
	local ok, chunk, result
	ok, chunk = pcall(love.filesystem.load, file)
	if not ok then 
		if file ~= crashScreen then
			startingScreen = crashScreen
			arg = chunk
		else
			error(chunk)
		end
	else
		ok, result = pcall(chunk)
		if not ok then 
			if file ~= crashScreen then
				startingScreen = crashScreen
				arg = result
			else
				error(result)
			end
		else
			screens[file] = result
		end
	end
end

-- WINDOWS

function importWindow(file)
	local window = {}
	
	if (type(file) == "string") and not love.filesystem.getInfo(file) then return nil, "ERROR: file '" .. tostring(file) .. "' does not exist"	end
	
	local ok, chunk, result
	if (type(file) == "string") then
		ok, chunk = pcall(love.filesystem.load, file)
	else
		ok, chunk = pcall(loadstring, file:getString(), file:getFilename())
	end
	if not ok then
		window = {load = function() messageBox("Program Error", chunk, {{"OK", function() closeMessageBox() closeWindow(nil, true) end}}, "critical") end}
	else
		ok, result = pcall(chunk)
		if not ok then
			window = {load = function() messageBox("Program Error", result, {{"OK", function() closeMessageBox() closeWindow(nil, true) end}}, "critical") end}
		elseif type(result) == "table" then
			window = result
		else
			return nil, "ERROR: " .. tostring(file) .. " is not a valid CrapOS application. (file did not return table)"
		end
	end
	
	return window
end

-- window decoration

function windowDec(window, id)
	title = window.title or "Window"	
	
	rect(0, 0, window.windowWidth, window.windowHeight, style.window.backgroundColor)
	image((id == currentWindow) and style.windowBar.color or style.windowBar.inactiveColor, 0, -30, window.windowWidth, 30, settings.themeColor)
	outline(0, -30, window.windowWidth, window.windowHeight + 30)
	
	-- window title
	local f = love.graphics.getFont()
	text(title, 5, -15 - f:getHeight()/2, {1, 1, 1})
	
	-- minimize button
	button("", function() hideWindow() end, window.windowWidth - 60, -30, 30, 30, style.windowBar.minimizeButtonColor, nil, false)
	
	-- close button
	button("", function() closeWindow(window) end, window.windowWidth - 30, -30, 30, 30, style.windowBar.closeButtonColor, nil, false)
end

-- MESSAGE BOX

local messageX, messageY, messageWidth, messageHeight

local function drawMessageBox()
	if currentMessageBox then
		local f = love.graphics.getFont()
		
		local _, lines = f:getWrap(currentMessageBox.text, messageWidth-80)
		local textheight = #lines*f:getHeight()
		local height
		if messageHeight-70 < textheight then
			height = textheight + 70
		else
			height = messageHeight
		end
		
		rect(messageX, messageY, messageWidth, height, style.window.backgroundColor)
		image(style.windowBar.color, messageX, messageY-30, messageWidth, 30, settings.themeColor)
		outline(messageX, messageY - 30, messageWidth, height + 30)
		
		-- title
		text(currentMessageBox.title, math.floor(messageX + 5), math.floor(messageY - 15 - f:getHeight()/2), {1, 1, 1})
		
		-- icon
		image(messageBoxIcons[currentMessageBox.icon], messageX + 10, messageY + 10, 50, 50)
		
		-- text
		text(currentMessageBox.text, math.floor(messageX + 70), math.floor(messageY + 20), nil, messageWidth - 80)
		
		-- buttons
		local bx = messageX + 10
		for x, b in ipairs(currentMessageBox.buttons) do
			local w = math.max(f:getWidth(b[1]), 70)
			button(b[1], b[2], bx, messageY + height - 40, w+10, 30)
			bx = bx + w + 15
		end
	end
end

function drawTextInputBox()
	if currentTextInputBox then
		if currentTextInputBox.type == "text" then
			local lx, ly, lw, lh = displayWidth/2 - 180, displayHeight/2 - 40, 360, 80
			rect(lx, ly, lw, lh, style.window.backgroundColor)
			outline(lx, ly, lw, lh)

			text(currentTextInputBox.title, lx+5, ly+5)

			outline(lx+5, ly+25, lw-10, 20)

			local textCursor = ""
			if math.floor(t*3) % 2 == 0 then
				textCursor = "_"
			end

			local s = currentTextInputBox.input
			local f = love.graphics.getFont()
			local pos = f:getWidth(s) <= 350 and 0 or 0 - f:getWidth(s) + 340

			love.graphics.setScissor(lx+5, ly+25, lw-10, 20)
			text(s .. textCursor, lx+5 + pos, ly+25, nil)
			love.graphics.setScissor()

			button("Cancel", function() currentTextInputBox = nil end, lx+5, ly+50, 60, 25)
		elseif currentTextInputBox.type == "fileopen" then
			local lx, ly, lw, lh = displayWidth/2 - 240, displayHeight/2 - 150, 480, 300
			rect(lx, ly, lw, lh, style.window.backgroundColor)
			outline(lx, ly, lw, lh)
			
			button("Up", function() filegui.cd("..") end, lx+5, ly+5, 30, 25)
			
			filegui.drawFileList(lx+5, ly+30, lw-10, lh-40, canClick, {onFileOpen = function(path)
				currentTextInputBox.onfinish(path)
				currentTextInputBox = nil
			end})
			
			button("Cancel", function() currentTextInputBox = nil end, lx+5, ly+270, 60, 25)
		elseif currentTextInputBox.type == "diropen" then
			local lx, ly, lw, lh = displayWidth/2 - 240, displayHeight/2 - 150, 480, 300
			rect(lx, ly, lw, lh, style.window.backgroundColor)
			outline(lx, ly, lw, lh)
			
			button("Up", function() filegui.cd("..") end, lx+5, ly+5, 30, 25)
			
			filegui.drawFileList(lx+5, ly+30, lw-10, lh-40, canClick, {onFileOpen = function() end})
			
			button("Select Folder", function()
				currentTextInputBox.onfinish(currentTextInputBox.dir)
				currentTextInputBox = nil
			end, lx+5, ly+270, 160, 25)
			button("Cancel", function() currentTextInputBox = nil end, lx+170, ly+270, 60, 25)
		elseif currentTextInputBox.type == "filesave" then
			local lx, ly, lw, lh = displayWidth/2 - 240, displayHeight/2 - 150, 480, 300
			rect(lx, ly, lw, lh, style.window.backgroundColor)
			outline(lx, ly, lw, lh)
			
			button("Up", function() filegui.cd("..") end, lx+5, ly+5, 30, 25)
			
			filegui.drawFileList(lx+5, ly+30, lw-10, lh-40, canClick, {onFileOpen = function() end})
			
			outline(lx+5, ly+245, lw-10, 20)

			local textCursor = ""
			if math.floor(t*3) % 2 == 0 then
				textCursor = "_"
			end

			local s = currentTextInputBox.input
			local f = love.graphics.getFont()
			local pos = f:getWidth(s) <= 350 and 0 or 0 - f:getWidth(s) + 340

			love.graphics.setScissor(lx+5, ly+245, lw-10, 20)
			text(s .. textCursor, lx+5 + pos, ly+245, nil)
			love.graphics.setScissor()
			
			button("Cancel", function() currentTextInputBox = nil end, lx+5, ly+270, 60, 25)
		end
	end
end

local cursor = (love.system.getOS() ~= "Windows") and style.cursor.image and love.mouse.newCursor(style.cursor.image) or love.mouse.getSystemCursor("arrow")
local cursorSizewe = love.mouse.getSystemCursor("sizewe")
local cursorSizens = love.mouse.getSystemCursor("sizens")
local cursorSizenwse = love.mouse.getSystemCursor("sizenwse")

local function updateDimensions(width, height)
	width = width or love.graphics.getWidth()
	height = height or love.graphics.getHeight()
	displayWidth, displayHeight = width, height
	messageX, messageY, messageWidth, messageHeight = displayWidth / 2 - 200, displayHeight / 2 - 60, 400, 120
end

-- love callbacks

local callbacks = {}

function callbacks.load()
	
	updateDimensions()
	
	inputtingText = false
	
	love.filesystem.setIdentity(love.filesystem.getIdentity(), false)
	
	local confChunk = love.filesystem.load("conf.lua")
	local version = confChunk and confChunk(true)
	if (not confChunk) or (systemVersion ~= version) then
		-- removing main.lua triggers the installer
		love.filesystem.remove("main.lua")
		love.event.quit("restart")
	end
	
	for _, file in ipairs(love.filesystem.getDirectoryItems("screens")) do
		importScreen("screens/" .. file)
	end
	
	for _, file in ipairs(love.filesystem.getDirectoryItems("fonts")) do
		importFont("fonts/" .. file)
	end
	
	if cursor then love.mouse.setCursor(cursor) end
	if style.font then setFont(style.font) end
	
	t = 0
	
	local info = love.filesystem.getInfo("user", "directory")
	if not info then
		love.filesystem.createDirectory("user")
	end

	if not love.filesystem.getInfo("user/Desktop", "directory") then
		love.filesystem.createDirectory("user/Desktop")
	end
	
	if not love.filesystem.getInfo("ProgramFiles", "directory") then
		love.filesystem.createDirectory("ProgramFiles")
	end
	
	loadSettings("settings")
	
	love.filesystem.setIdentity(love.filesystem.getIdentity(), settings.appendToPath == "true")
	
	switchScreen(startingScreen, arg)
end

function callbacks.mousepressed(x, y, button)
	local curwin = currentWindow and openWindows[currentWindow]
	local rx = curwin and x >= curwin.windowX + curwin.windowWidth and x <= curwin.windowX + curwin.windowWidth + 5
	local ry = curwin and y >= curwin.windowY + curwin.windowHeight and y <= curwin.windowY + curwin.windowHeight + 5
			
	hasClickedCurrentWindow = curwin and (
		(x >= curwin.windowX and x <= curwin.windowX + curwin.windowWidth
		and y >= curwin.windowY-30 and y <= curwin.windowY + curwin.windowHeight + 30)
	or (
		curwin.resizable and (rx or ry)
	))
	
	if not (currentMessageBox or currentTextInputBox) then
		if not hasClickedCurrentWindow then
			for id = #openWindows, 1, -1 do
				local window = openWindows[id]
				
				if x >= window.windowX and x <= window.windowX + window.windowWidth
				and y >= window.windowY-30 and y <= window.windowY + window.windowHeight + 30 then
					if currentWindow == id then
						break
					end
					
					currentWindow = id
					canClick = false
					break
				end
			end
		end
		
		if curwin
		and x >= curwin.windowX and x <= curwin.windowX + curwin.windowWidth
		and y >= curwin.windowY-30 and y <= curwin.windowY + curwin.windowHeight + 30
		and not curwin.hideWindowDec then
			
			if y <= curwin.windowY then
				isDragging = true
			end
		end
		
		if curwin and curwin.resizable then
			isResizingX = rx
			isResizingY = ry
			if rx or ry then
				canClick = false
			end
		end
	end
	
	if openWindows[currentWindow] and openWindows[currentWindow].mousepressed then
		callingWindow = openWindows[currentWindow]
		call(openWindows[currentWindow].mousepressed, x, y, button)
		callingWindow = nil
	end
end

function callbacks.mousereleased(x, y, button)
	if openWindows[currentWindow] and openWindows[currentWindow].mousereleased then
		callingWindow = openWindows[currentWindow]
		call(openWindows[currentWindow].mousereleased, x, y, button)
		callingWindow = nil
	end
	canClick = true
	isDragging = false
	isResizingX = false
	isResizingY = false
end

function callbacks.mousemoved(x, y, dx, dy)
	local window = openWindows[currentWindow]
	if window then
		if isDragging then
			window.windowX = window.windowX + dx
			window.windowY = window.windowY + dy
			
			if window.windowY > displayHeight - 40 then
				window.windowY = window.windowY - dy
			end
		end
		
		if window.resizable then
			local rx = x >= window.windowX + window.windowWidth and x <= window.windowX + window.windowWidth + 5
			local ry = y >= window.windowY + window.windowHeight and y <= window.windowY + window.windowHeight + 5
			
			if (isResizingX and isResizingY) or (rx and ry) then
				love.mouse.setCursor(cursorSizenwse)
			elseif isResizingX or rx then
				love.mouse.setCursor(cursorSizewe)
			elseif isResizingY or ry then
				love.mouse.setCursor(cursorSizens)
			else
				love.mouse.setCursor(cursor)
			end
			
			if isResizingX and (x - window.windowX) >= 100 then
				window.windowWidth = x - window.windowX
			end
			
			if isResizingY and (y - window.windowY) >= 100 then
				window.windowHeight = y - window.windowY
			end
		end
		
		if window.mousemoved then
			callingWindow = window
			call(window.mousemoved, x, y, dx, dy)
			callingWindow = nil
		end
	end
end

function callbacks.wheelmoved(x, y)
	if filegui then filegui.wheelmoved(x, y) end
	if openWindows[currentWindow] and openWindows[currentWindow].wheelmoved then
		callingWindow = openWindows[currentWindow]
		call(openWindows[currentWindow].wheelmoved, x, y)
		callingWindow = nil
	end
end

function callbacks.keypressed(key)
	if key == "f4" then
		love.window.setFullscreen(not love.window.getFullscreen())
		updateDimensions()
	end

	if currentTextInputBox then
		if key == "backspace" then
			local byteoffset = utf8.offset(currentTextInputBox.input, -1)
			if byteoffset then
				currentTextInputBox.input = string.sub(currentTextInputBox.input, 1, byteoffset - 1)
			end
		end
		
		if key == "return" then
			if currentTextInputBox.onfinish then
				callingWindow = currentTextInputBox.window
				local ok, msg = pcall(currentTextInputBox.onfinish, currentTextInputBox.input)
				if not ok then
					closeWindow(callingWindow)
					messageBox("Program Error", msg, {{"OK", function() closeMessageBox() end}}, "critical")
					return
				end
				callingWindow = nil
			end
			currentTextInputBox = nil
		end
	elseif openWindows[currentWindow] and openWindows[currentWindow].keypressed then
		callingWindow = openWindows[currentWindow]
		call(openWindows[currentWindow].keypressed, key)
		callingWindow = nil
	end
end

function callbacks.textinput(text)
	if currentTextInputBox then
		currentTextInputBox.input = currentTextInputBox.input .. text
	elseif openWindows[currentWindow] and openWindows[currentWindow].textinput then
		callingWindow = openWindows[currentWindow]
		openWindows[currentWindow].textinput(text)
		callingWindow = nil
	end
end

function callbacks.filedropped(file)
	if openWindows[currentWindow] and openWindows[currentWindow].filedropped then
		callingWindow = openWindows[currentWindow]
		call(openWindows[currentWindow].filedropped, file)
		callingWindow = nil
	end
end

function callbacks.resize(width, height)
	updateDimensions(width, height)
end

function callbacks.update(dt)
	t = t + dt
	if screens[currentScreen] and screens[currentScreen].update then
		callScreen(screens[currentScreen].update, dt)
	end
	for _, w in ipairs(openWindows) do
		if w.update then
			callingWindow = w
			call(w.update, dt)
			callingWindow = nil
		end
	end
end

function callbacks.draw()
	if love.mouse.getRelativeMode() then canClick = false end
	local cc = true
	local prevCc = canClick
	setFont(style.font)
	if screens[currentScreen] and screens[currentScreen].draw then
		callScreen(screens[currentScreen].draw)
	end
	
	local function drawWindow(id)
		local window = openWindows[id]
		if not window then return end
		if window.isActive then
			cc = true
			
			windowX, windowY, windowWidth, windowHeight = window.windowX, window.windowY, window.windowWidth, window.windowHeight
			love.graphics.translate(window.windowX, window.windowY)
			
			if canClick and currentMessageBox or currentTextInputBox or (id ~= currentWindow) then
				prevCc = canClick
				canClick, cc = false, false
			end
			
			if not window.hideWindowDec then
				windowDec(window, id)
			end
			if window then
				love.graphics.setScissor(window.windowX, window.windowY, window.windowWidth, window.windowHeight)
			end
			
			if window and window.draw then
				callingWindow = window
				call(window.draw)
				callingWindow = nil
			end
			
			love.graphics.setScissor()
			love.graphics.origin()
			if not cc then canClick = prevCc end
			setFont(style.font)
		end
	end
	
	for id, _ in ipairs(openWindows) do
		if id ~= currentWindow then
			drawWindow(id)
		end
	end
	
	if currentWindow then
		drawWindow(currentWindow)
	end
	
	drawTextInputBox()
	drawMessageBox()
end

function callbacks.quit()
	love.filesystem.setIdentity(love.filesystem.getIdentity(), false)
	saveSettings("settings")
	love.mouse.setCursor()
end

return callbacks
