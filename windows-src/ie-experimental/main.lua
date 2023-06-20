local https

local gui = require "lib.wpgui"

local linkColor = {0, 0, 1, 1}

local domParse

local mainGui

local page
local isLegacyPage
local currentPage
local legacyCurrentPage
local goToPage

local scrollY

local requestThread
local isRequesting = false

function goToPage(id, arg)
	page = id
	scrollY = 0
	
	if getResource("net/" .. page .. ".lua") then
		
		currentPage = nil
		
		local chunk = loadLocalScript("net/" .. page .. ".lua")
		local env = {goToPage = goToPage}
		setmetatable(env, {__index = _G})
		setfenv(chunk, env)
		
		legacyCurrentPage = chunk()
		
		for i, func in pairs(legacyCurrentPage) do
			if type(func) == "function" then
				setfenv(legacyCurrentPage[i], env)
			end
		end
		
		if legacyCurrentPage and legacyCurrentPage.load then legacyCurrentPage.load(arg) end
		
	else
		isRequesting = true
		currentPage = nil
		legacyCurrentPage = nil
		
		requestThread:start(page)
	end
end

local window = {}
window.title = "Internet Explorer"

local function showSearchResults(term)
	goToPage("crapos.notarealsite.com/search", term)
end

local function search()
	textInput("Enter a URL to visit", function(text)
		goToPage(text)
	end)
	--[[
	textInput("Type something to search", function(text)
		if #text > 0 and getResource("net/" .. text .. ".lua") then
			goToPage(text)
		else
			showSearchResults(text)
		end
	end)
	]]
end

local function drawContent()
	local font = love.graphics.getFont()
	
	love.graphics.push()
	love.graphics.translate(0, scrollY)
	love.graphics.setScissor(window.windowX, window.windowY + 40, window.windowWidth, window.windowHeight - 40)
	
	if legacyCurrentPage and legacyCurrentPage.draw then
		legacyCurrentPage.draw()
	elseif currentPage then
		local x, y = 5, 5
		local curText = {}
		
		local function doneText()
			local s = ""
			for i = 2, #curText, 2 do
				s = s .. curText[i]
			end
			
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.printf(curText, x, y, windowWidth-10, "left")
			local _, lines = font:getWrap(s, windowWidth-10)
			y = y + #lines * font:getHeight()
			curText = {}
		end
		
		for _, thing in ipairs(currentPage.parsed) do
			if type(thing) == "string" then
				table.insert(curText, style.text.color)
				table.insert(curText, thing)
			elseif type(thing) == "table" then
				if thing.type == "a" then
					table.insert(curText, linkColor)
					table.insert(curText, thing.value)
				end
			end
		end
		
		if #curText > 0 then
			doneText()
		end
	end
	
	love.graphics.pop()
end


function window.load()
	if love.system.getOS() ~= "Linux" then
		closeWindow(window.id, true)
		messageBox("Error", "This program currently only works on a Linux host.")
		return
	end
	
	love.filesystem.setCRequirePath("lib/?.so")
	https = require "https"
	love.filesystem.setCRequirePath("??")
	
	domParse = loadLocalScript("domParse.lua")()
	
	mainGui = gui.Gui{
		width = windowWidth,
		height = windowHeight
	}
	
	local toolbar = gui.Frame{
		width = windowWidth,
		marginX = 0, marginY = 0,
		color = {0.75, 0.75, 0.75, 1}
	}
	
	toolbar:put({
		gui.Button{
			width = 30, height = 30,
			color = "icons/missing.png",
			outlineColor = {0, 0, 0, 0},
			action = function()
				messageBox("Error", "Button function not found.", nil, "critical")
			end
		},
		gui.Button{
			width = 30, height = 30,
			color = "icons/missing.png",
			outlineColor = {0, 0, 0, 0},
			action = function()
				messageBox("Error", "Button function not found.", nil, "critical")
			end
		},
		gui.TextBox{
			
			width = 360,
			onEnterPressed = function(self)
				goToPage(self.value)
			end
		}
	})
	
	local contentArea = gui.Canvas{
		width = windowWidth, height = windowHeight,
		draw = drawContent,
		marginX = 0, marginY = 0
	}
	
	mainGui:put({toolbar}, {align = "center"})
	mainGui:put({contentArea}, {align = "center"})
	
	scrollY = 0
	requestThread = love.thread.newThread(getResource("request.lua"))
	
	goToPage("crapos.notarealsite.com/iehome")
end

function window.update(dt)
	if legacyCurrentPage and legacyCurrentPage.update then
		legacyCurrentPage.update(dt)
	
	elseif isRequesting then
		local data = love.thread.getChannel("https"):pop()
		if data then
			currentPage = data
			isRequesting = false
			
			currentPage.parsed = domParse(currentPage.body)
		end
	end
end

function window.draw()
	mainGui:draw()
	
	--[[
	rect(0, 0, windowWidth, 30, {0.75, 0.75, 0.75})
	image("icons/missing.png", 0, 0, 30, 30)
	button("", function() messageBox("Error", "Button function not found.", nil, "critical") end, 0, 0, 30, 30, {0, 0, 0, 0}, nil, false)
	image("icons/missing.png", 35, 0, 30, 30)
	button("", function() messageBox("Error", "Button function not found.", nil, "critical") end, 35, 0, 30, 30, {0, 0, 0, 0}, nil, false)
	image("icons/gears.png", windowWidth-30, 0, 30, 30)
	button("", function() switchScreen("screens/crash.lua", "FILESYSTEM_EPIC_FAILIURE 0x000BAD") end, windowWidth-30, 0, 30, 30, {0, 0, 0, 0}, nil, false)
	rect(70, 5, 360, 20, {1, 1, 1})
	text(page or "", 70, 5)
	button("", function() search() end, 70, 5, 360, 20, {0, 0, 0, 0}, nil, false)
	]]
	
	
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

function window.wheelmoved(dx, dy)
	scrollY = scrollY + dy*10
end

return window
