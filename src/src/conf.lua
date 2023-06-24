-- /conf.lua and src/conf.lua should remain identical

-- systemVersion is set here to make it easier to compare the Windows PE
-- version contained in the source archive and the version that's installed
-- in the save directory, and see if they differ. if they do, the installer
-- should automatically be ran so that the new version can be installed.

-- the version of conf.lua that LÖVE executes is always the one from the source
-- directory. however within the actual program, the version of conf.lua from
-- the save directory should be read

local version = "b6.1"
-- dont reassign it when we read the file later
if not systemVersion then
	systemVersion = version
end

function love.conf(t)
	t.identity = "winpe5"
	t.window.title = "Windows Poop Edition 5"
	t.window.icon = "icon.png"
	t.window.fullscreen = true
	t.window.width = 1280
	t.window.height = 720
	t.window.resizable = true
	t.window.depth = 16
end

return version