local window = {}
window.title = "Games"

local games = {
	{"Minecraft", "windows/minecraft.exe", "images/icons/minecraft.png", "Place and break blocks"},
	{"Stick Collector", "windows/stickcollector.exe", "images/icons/stick.png", "Collect sticks"},
	{"Deadfish", "windows/deadfish.exe", "images/icons/deadfish.png"},
	{"FNAF: Secureness Beach", "windows/fnaf.exe", "images/icons/missing.png"},
	{"3D Epicness", "windows/3d.exe", "images/icons/3d.png", "Fun with 3D shapes! Now with more Branding™!"},
	{"Solitaire", "windows/solitaire.exe", "images/icons/solitaire.png", "Cards"},
	{"Minesweeper", "windows/minesweeper.exe", "images/icons/explode.png", "Explode"},
}

function window.load()
end

function window.draw()
	image("images/gamesforwindowspe.png", 0, 0, 360, 80)
	text("Welcome to Games. We have a whole lot of AWESOME games bundled with Windows Poop Edition, so feel free to explore them!", 0, 80, nil, windowWidth)
	
	local x, y = 5, 120
	local w, h = 240, 50
	for i, game in ipairs(games) do
		button("", function() openWindow(game[2]) end, x, y, w, h)
		image(game[3] or "images/icons/missing.png", x, y, h, h)
		text(game[1], x + 55, y, nil, w)
		text(game[4] or "[description not found]", x + 55, y + 20, nil, w)
		x = x + w + 10
		if x + w >= windowWidth then
		   x = 5
		   y = y + h + 10
		end
	end
end


return window
