local window = {}

local menuWidth, menuHeight = 280, 640
local t

window.windowX, window.windowY = 0, displayHeight - 40 - menuHeight
window.windowWidth, window.windowHeight = menuWidth, menuHeight
window.hideWindowDec = true

local items = {
	{"Internet Explorer", "images/icons/ie.png", function() openWindow("windows/ie.exe") end},
	{"File Explorer", "images/icons/explorer.png", function() openWindow("windows/explorer.exe") end},
	{"Chat", "images/icons/chat.png", function() openWindow("windows/chat.exe") end},
	{"Games", "images/icons/games.png", function() openWindow("windows/games.exe") end},
	{"Music", "images/icons/music.png", function() openWindow("windows/explorer.exe", "Music") end},
	{"Videos", "images/icons/video2.png", function() openWindow("windows/explorer.exe", "Videos") end},
	{"Shop", "images/icons/missing.png", function() openWindow("windows/shop.exe") end},
	{"Control Panel", "images/icons/controlpanel.png", function() openWindow("windows/control.exe") end},
	{"More Programs", "images/icons/app.png", function() openWindow("windows/more.exe") end},
	{"About Windows", "images/icons/info.png", function() openWindow("windows/about.exe") end},
}

function window.load()
	t = 0
end

function window.update(dt)
	t = t + dt
end

function window.draw()
	image("images/gradient.png", 0, 0, window.windowWidth, window.windowHeight, settings.themeColor)
	
	image("images/gradient.png", 0, 0, window.windowWidth, 50,
	{settings.themeColor[1] * 0.6, settings.themeColor[2] * 0.6, settings.themeColor[3] * 0.6, 1})
	image("start.png", 0, 0, window.windowWidth, 50)
	
	local by = 60
	for i, item in ipairs(items) do
		button(item[1], function()
			closeWindow()
			item[3]()
		end, 5, by, menuWidth-10, 40)
		image(item[2], 8, by+3, 35, 35)
		by = by + 45
	end
	
	button("Restart", function()
		messageBox(nil, "Generic Restart Confirmation", {
			{"Yes", function() shutdown(true) end},
			{"No", function() closeMessageBox() end}
		}, "exc")
	end, 80, menuHeight - 70, menuWidth-90, 30, {0.8, 0.8, 0})
	
	button("Shutdown", function()
		messageBox(nil, "Generic Shutdown Confirmation", {
			{"Yes", function() shutdown() end},
			{"No", function() closeMessageBox() end}
		}, "exc")
	end, 80, menuHeight - 35, menuWidth-90, 30, {0.8, 0, 0}, {1, 1, 1})
end

function window.mousepressed(x, y)
	if not (x <= window.windowWidth
	and y >= window.windowY and y <= window.windowY + window.windowHeight)
	and not isMessageBox() then
		closeWindow(window.id)
	end
end

return window
