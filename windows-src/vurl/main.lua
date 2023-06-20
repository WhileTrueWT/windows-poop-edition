local vurl = love.filesystem.load("lib/vurl.lua")()

-- start of windows PE interface

window = {}
window.title = "Vurl Program"

local root = "/"
local code
local t
local hasStarted = false

vurl.setcmd("icon", function(a)
	window.icon = root .. a[1]
end)
	
vurl.setcmd("title", function(a)
	window.title = a[1]
end)

function window.load(arg)
	if arg then
		code = love.filesystem.read(arg)
		t = 0
		
		root = string.match(arg, "^(.*/).*$") or "/"
		vurl.setroot(root)
		
		vurl.run(code)
		hasStarted = true
		
		vurl.callFunc("load")
	end
end

function window.update(dt)
	if not hasStarted then return end
	t = t + dt
	
	vurl.callFunc("update")
end

function window.draw()
	if not hasStarted then return end
	
	vurl.callFunc("draw")
end

function window.keypressed(key)
	vurl.setvar("_key", key)
	vurl.callFunc("keypressed")
end

function window.mousepressed(x, y, button)
	vurl.setvar("_mx", x)
	vurl.setvar("_my", y)
	vurl.setvar("_mb", button)
	vurl.callFunc("mousepressed")
end

return window
