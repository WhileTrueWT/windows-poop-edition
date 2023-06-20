local page
local currentPage
local goToPage

function goToPage(id, arg)
	page = id
	local chunk = loadLocalScript("net/" .. page .. ".lua")
	local env = {goToPage = goToPage}
	setmetatable(env, {__index = _G})
	setfenv(chunk, env)
	
	currentPage = chunk()
	
	for i, func in pairs(currentPage) do
		if type(func) == "function" then
			setfenv(currentPage[i], env)
		end
	end
	
	if currentPage and currentPage.load then currentPage.load(arg) end
end

local window = {}
window.title = "Internet Explorer"

local function showSearchResults(term)
	goToPage("crapos.notarealsite.com/search", term)
end

local function search()
	textInput("Type something to search", function(text)
		if #text > 0 and getResource("net/" .. text .. ".lua") then
			goToPage(text)
		else
			showSearchResults(text)
		end
	end)
end


function window.load()
	goToPage("crapos.notarealsite.com/iehome")
end

function window.update(dt)
	if currentPage and currentPage.update then currentPage.update(dt) end
end

function window.draw()
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
	
	love.graphics.translate(0, 40)
	if currentPage and currentPage.draw then currentPage.draw() end
end

return window
