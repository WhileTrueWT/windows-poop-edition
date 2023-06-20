local window = {}
window.title = "Soundboard"
window.windowWidth = 340
window.windowHeight = 120

local sounds = {
	['1']="sounds/critical.wav",
	['2']="sounds/exc.wav",
	['3']="sounds/default.wav",
	['4']="sounds/ast.wav",
	['5']="sounds/startup.wav",
	['6']="sounds/shutdown.wav",
}

local sources = {}
for _, file in pairs(sounds) do
	sources[file] = love.audio.newSource(file, "static")
end

function window.draw()
	text("Press 1 for DUDUDUN\nPress 2 for Bleebaboop\nPress 3 for Bloop\nPress 4 for BlaBLOOP\nPress 5 for HWUAAAAHUAAHAAAA\nPress 6 for the other HWUAAAAHUAAHAAAA", 5, 5)
end

function window.keypressed(key)
	if sounds[key] then
		if sources[sounds[key]]:isPlaying() then sources[sounds[key]]:stop() end
		sources[sounds[key]]:play()
	end
end

return window
