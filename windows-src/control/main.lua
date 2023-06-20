local window = {}
window.title = "Control Panel"

local wallpapers = {
	{"Default", "images/background.png"},
	{"Longhorn", "images/longhorn-bg.jpg"},
}

local sounds = {
	{title="Critical Stop", key="critical", default="sounds/critical.wav"},
	{title="Exclamation", key="exc", default="sounds/exc.wav"},
	{title="Default", key="default", default="sounds/default.wav"},
	{title="Asterisk", key="ast", default="sounds/ast.wav"},
	{title="Startup", key="startup", default="sounds/startup.wav"},
	{title="Shutdown", key="shutdown", default="sounds/shutdown.wav"},
}

local sections = {
	{
		name = "General",
		draw = function()
			text("Balloon (aka Notifications)", 10, 10)
			text("Balloon is ON", 10, 40, {0, 0.5, 0})
			button("Turn Off", function()
				messageBox("Permission Error", "You do not have permission to perform this action.", nil, "critical")
			end, 160, 40, 100, 30)
			
			text("Time and Date", 10, 90)
			text(os.date("It is currently %I:%M:%S on %B %d, %Y."), 10, 120)
			text("No, you can't change your time and date settings. You shouldn't need to anyways; CrapOS has super hyper accurate time-keeping technologies built right in to the system, so there's no way it could ever be wrong.", 10, 160, {0.5, 0.5, 0.5}, windowWidth-140)
		end
	},
	{
		name = "Appearence",
		draw = function()
			text("Wallpaper", 10, 10)
			local x, y = 10, 40
			for _, wallpaper in ipairs(wallpapers) do
				button("", function() 
					settings.background = wallpaper[2]
				end, x, y, 160, 90, wallpaper[2], nil, false)
				text(wallpaper[1], x, y+100)
				x = x + 170
				if x+10 >= windowWidth-10 then
					x = 10
					y = y + 120
				end
			end
			x = 10
			y = y + 150
			
			button("Custom Wallpaper", function()
				open(function(_, path)
					local ok, msg = pcall(love.image.newImageData, path)
					if not ok then
						messageBox(window.title,
						string.format("%s is not an image file or does not use a recognizable image format.\n\n%s", path, msg),
						nil, "exc")
						return
					end
					
					settings.background = path
				end)
			end, x, y, 260, 40)
			y = y + 50
			
			button("Change Window Color", function()
				selectColor(function(color)
					settings.themeColor = color
				end)
			end, x, y, 260, 40)
			y = y + 50
			
			text("Window Transparency:", x, y)
			button(settings.themeColor[4] == 1 and "Off" or "On", function()
				settings.themeColor[4] = (settings.themeColor[4] == 1 and 0.7 or 1)
			end, x+220, y, 80, 40)
			y = y + 50
			
		end
	},
	{
		name = "Sounds",
		draw = function()
			text("Sound Scheme", 10, 10)
			text("UNDER CONSTRUCTION", 10, 30, {0.5, 0.5, 0.5})
			
			--[[
			for i, sound in ipairs(sounds) do
				button(sound.title, function()
					open(function(_, path)
						local ok, msg = pcall(love.sound.newSoundData, path)
						if not ok then
							messageBox(window.title,
							string.format("%s is not an audio file or does not use a recognizable audio format.\n\n%s", path, msg),
							nil, "exc")
							return
						end
						
						settings.soundScheme[sound.key] = path
					end)
				end, 10, i*40, 140, 30)
				text(tostring(settings.soundScheme[sound.key]), 160, i*40)
			end
			--]]
			
		end
	},
	{
		name = "System",
		draw = function()
			text("Screw up your computer with ease", 10, 10)
			
			button("Crash", function() switchScreen("screens/crash.lua") end, 10, 40, 140, 30)
			text("For all your system crashing needs", 160, 40)
			
			button("Reset Settings", function() 
				messageBox("Confirmation", "Are you sure you want to reset your settings? Your files will be preserved, but your computer will restart and all preferences will be cleared.", {{"Yes", function()
					settings = {}
					love.event.quit("restart")
				end}, {"No", function() closeMessageBox() end}})
			end, 10, 80, 140, 30)
			text("Resets all settings and restarts your computer", 160, 80, nil, windowWidth-290)
			
			text("WARNING: Everything below this point is stuff that you probably shouldn't touch unless you know what you're doing (at least somewhat)!", 10, 120, nil, windowWidth-290)
			
			text("appendToPath:", 10, 200)
			button("Save Directory First", function()
				settings.appendToPath = "false"
			end, 160, 200, 240, 40)
			button("Source Directory First", function()
				settings.appendToPath = "true"
			end, 160, 250, 240, 40)
		end
	},
}
local currentSection = 1

function window.draw()
	outline(0, 0, 120, windowHeight)
	
	for i, section in ipairs(sections) do
		button(section.name or "", function() currentSection = i end, 0, (i-1)*30, 120, 30)
	end
	
	love.graphics.push()
	love.graphics.translate(120, 0)
	
	sections[currentSection].draw()
	
	love.graphics.pop()
end

return window
