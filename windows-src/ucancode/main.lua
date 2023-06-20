local mem = {}
setmetatable(mem, {__index = function() return "" end})
local labels
local i

local function command(line, syntax, func)
	syntax = string.gsub(syntax, "{x}", "(%%w+)")
	syntax = string.gsub(syntax, "{s}", "(\".*\")")
	syntax = "^" .. syntax .. "$"
	local a, b, c = string.match(line, syntax)
	if a then
		return func(a, b, c)
	end
end

local lines

local commands = {
	{
		name = "{x} is {x}",
		func = function(a,b)
			return "mem['" .. a .. "'] = '" .. b .. "'"
		end
	},
	{
		name = "{x} is {s}",
		func = function(a,b)
			 return "mem['" .. a .. "'] = " .. b
		end
	},
	{
		name = "{x} is the value of {x}",
		func = function(a,b)
			return "mem['" .. a .. "'] = mem['" .. b .. "']"
		end
	},
	{
		name = "{x} is a list",
		func = function(a,b)
			return "mem['" .. a .. "'] = {}"
		end
	},
	{
		name = "add {x} to {x}",
		func = function(a,b)
			return "table.insert(mem['".. b .. "'], mem['" .. a .. "'])"
		end
	},
	{
		name = "insert {x} into position {x} of {x}",
		func = function(a,b,c)
			return "table.insert(mem['"..c.."'], mem['"..a.."'], mem['"..b.."'])"
		end
	},
	{
		name = "replace item {x} of {x} with {x}",
		func = function(a,b,c)
			return "mem['"..b.."'][mem['"..a.."']] = mem['"..c.."']"
		end
	},
	{
		name = "remove item {x} from {x}",
		func = function(a,b)
			return "table.remove(mem['"..b.."'], mem['"..a.."'])"
		end
	},
	{
		name = "{x} is the item at position {x} of {x}",
		func = function(a,b,c)
			return "mem['"..a.."'] = mem['"..c.."'][mem['"..b.."']]"
		end
	},
	{
		name = "{x} is {x} plus {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) + tonumber(mem['"..c.."'])"
		end
	},
	{
		name = "{x} is {x} minus {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) - tonumber(mem['"..c.."'])"
		end
	},
	{
		name = "{x} is {x} times {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) * tonumber(mem['"..c.."'])"
		end
	},
	{
		name = "{x} is {x} divided by {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) / tonumber(mem['"..c.."'])"
		end
	},
	{
		name = "{x} is {x} modulo {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) % tonumber(mem['"..c.."'])"
		end
	},
	{
		name = "{x} is whether {x} equals {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = mem['"..b.."'] == mem['"..c.."'] and 'true' or 'false'"
		end
	},
	{
		name = "{x} is whether {x} is more than {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) > tonumber(mem['"..c.."']) and 'true' or 'false'"
		end
	},
	{
		name = "{x} is whether {x} is less than {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) < tonumber(mem['"..c.."']) and 'true' or 'false'"
		end
	},
	{
		name = "{x} is whether {x} is at least {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) >= tonumber(mem['"..c.."']) and 'true' or 'false'"
		end
	},
	{
		name = "{x} is whether {x} is at most {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = tonumber(mem['"..b.."']) <= tonumber(mem['"..c.."']) and 'true' or 'false'"
		end
	},
	{
		name = "{x} is whether {x} and {x} are true",
		func = function(a, b, c)
			return "mem['"..a.."'] = mem['"..b.."'] == 'true' and mem['"..c.."'] == 'true' and 'true' or 'false'"
		end
	},
	{
		name = "{x} is whether {x} or {x} is true",
		func = function(a, b, c)
			return "mem['"..a.."'] = mem['"..b.."'] == 'true' or mem['"..c.."'] == 'true' and 'true' or 'false'"
		end
	},
	{
		name = "{x} is whether {x} is false",
		func = function(a, b)
			return "mem['"..a.."'] = mem['"..b.."'] == 'false' and 'true' or 'false'"
		end
	},
	{
		name = "{x} is {x} joined with {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = mem['"..b.."'] .. mem['"..c.."']"
		end
	},
	{
		name = "{x} is the length of {x}",
		func = function(a, b)
			return "mem['"..a.."'] = #mem['"..b.."']"
		end
	},
	{
		name = "{x} is the letter at position {x} of {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = string.sub(mem['"..c.."'], tonumber(mem['"..b.."']), tonumber(mem['"..b.."']))"
		end
	},
	{
		name = "{x} is a random number between {x} and {x}",
		func = function(a, b, c)
			return "mem['"..a.."'] = math.random(tonumber(mem['"..b.."']), tonumber(mem['"..c.."']))"
		end
	},
	{
		name = "if {x} is true",
		func = function(a)
			return "if mem['" .. a .. "'] == \"true\" then"
		end
	},
	{
		name = "elseif {x} is true",
		func = function(a)
			return "elseif mem['" .. a .. "'] == \"true\" then"
		end
	},
	{
		name = "else",
		func = function()
			return "else"
		end
	},
	{
		name = "while {x} is true",
		func = function(a)
			return "while mem['" .. a .. "'] == \"true\" do"
		end
	},
	{
		name = "when program loads",
		func = function()
			return "function program.load()"
		end
	},
	{
		name = "when program updates",
		func = function()
			return "function program.update(dt)\nt=t+dt"
		end
	},
	{
		name = "when program draws",
		func = function()
			return "function program.draw()"
		end
	},
	{
		name = "when button {x} is clicked",
		func = function(a)
			return "function program.button(b)\nif b ~= '" .. a .. "' then return end"
		end
	},
	{
		name = "when prompt {x} is answered",
		func = function(a)
			return "function program.answer(id, answer)\nif id ~= '" .. a .. "' then return end\nmem['answer'] = answer"
		end
	},
	{
		name = "when mouse is clicked",
		func = function(a)
			return "function program.click(b)\nif b ~= 1 then return end"
		end
	},
	{
		name = "when the {x} key is pressed",
		func = function(a)
			return "function program.key(k)\nif k ~= '" .. a .. "' then return end"
		end
	},
	{
		name = "end",
		func = function()
			return "end"
		end
	},
	{
		name = "move to {x} {x}",
		func = function(a,b)
			return "pen.x, pen.y = tonumber(mem['"..a.."']), tonumber(mem['"..b.."'])"
		end
	},
	{
		name = "change x by {x}",
		func = function(a)
			return "pen.x = pen.x + tonumber(mem['"..a.."'])"
		end
	},
	{
		name = "change y by {x}",
		func = function(a)
			return "pen.y = pen.y + tonumber(mem['"..a.."'])"
		end
	},
	{
		name = "write {x}",
		func = function(a)
			return "text(mem['"..a.."'], pen.x, pen.y)"
		end
	},
	{
		name = "draw button {x} that says {x}",
		func = function(a,b)
			return "button(mem['"..b.."'], function() program.button('"..a.."') end, pen.x, pen.y, 100, 30)"
		end
	},
	{
		name = "ask {x} with id {x}",
		func = function(a,b)
			return "textInput(mem['"..a.."'], function(text) program.answer('"..b.."', text) end)"
		end
	},
	{
		name = "show message box that says {x}",
		func = function(a)
			return "messageBox('UCanCode', mem['"..a.."'], {{'OK', function() closeMessageBox() end}})"
		end
	},
	{
		name = "set color to {x} {x} {x}",
		func = function(a, b, c)
			return "love.graphics.setColor(mem['"..a.."']/255, mem['"..b.."']/255, mem['"..c.."']/255)"
		end
	},
	{
		name = "draw rectangle with size {x} {x}",
		func = function(a,b)
			return "love.graphics.rectangle('fill', pen.x, pen.y, mem['"..a.."'], mem['"..b.."'])"
		end
	},
	{
		name = "draw image {x} with size {x} {x}",
		func = function(a,b,c)
			return "image(mem['"..a.."'], pen.x, pen.y, mem['"..b.."'], mem['"..c.."'])"
		end
	},
	{
		name = "{x} is the time since the program started",
		func = function(a)
			return "mem['"..a.."'] = t"
		end
	},
	{
		name = "reset the timer",
		func = function()
			return "t = 0"
		end
	},
	{
		name = "define {x}",
		func = function(a)
			return "mem['"..a.."'] = function()"
		end
	},
	{
		name = "do {x}",
		func = function(a)
			return "mem['"..a.."']()"
		end
	},
	{
		name = "{x} is whether the mouse is down",
		func = function(a)
			return "mem['"..a.."'] = love.mouse.isDown(1) and 'true' or 'false'"
		end
	},
	{
		name = "{x} is whether the {x} key is down",
		func = function(a, b)
			return "mem['"..a.."'] = love.keyboard.isDown('"..b.."') and 'true' or 'false'"
		end
	},
	{
		name = "{x} is the x position of the mouse",
		func = function(a)
			return "mem['"..a.."'], _ = love.graphics.inverseTransformPoint(love.mouse.getX(), 0)"
		end
	},
	{
		name = "{x} is the y position of the mouse",
		func = function(a)
			return "_, mem['"..a.."'] = love.graphics.inverseTransformPoint(0, love.mouse.getY())"
		end
	},
}

local function compile(code)
	lines = {}
	for line in string.gmatch(code, "[%S ]+") do
		table.insert(lines, string.match(line, "%s*(.+)"))
	end
	
	local out = "local program = {}\nlocal mem = {}\nlocal pen = {x=0,y=0}\nlocal t = 0\n"
	
	for i, line in ipairs(lines) do
		local s
		for x, cmd in ipairs(commands) do
			s = command(line, cmd.name, cmd.func)
			if s then break end
		end
		if s then out = out .. s .. "\n" else error("unknown command: " .. line) end
	end
	out = out .. "return program"
	
	return out
end

local window = {}
window.title = "UCanCode"

local code, compiled

function window.load(file)
	code, compiled = nil, nil
	open(function(content)
		code = content
	
		local chunk, msg = load(compile(code))
		if not chuck and msg then error(msg) end
		compiled = chunk()
		
		if compiled.load then compiled.load() end
	end, file)
end

function window.mousepressed(button)
	if not compiled then return end
	
	if compiled.click then compiled.click(button) end
end

function window.keypressed(key)
	if not compiled then return end
	
	if compiled.key then compiled.key(key) end
end

function window.update(dt)
	if not compiled then return end
	
	if compiled.update then compiled.update(dt) end
end

function window.draw()
	if not compiled then
		text("WARNING!\nWe feel obligated to inform you that the name 'UCanCode' is a blatant lie, as you will almost certainly not succeed in writing a program in UCanCode. We don't feel like changing the name to 'UCantCode', so you're just gonna have to deal with this.\n\nIf you REALLY want to learn how to program in UCanCode, click the button below to open the documentation in your (actual) browser.", 0, 0, nil, windowWidth)
		button("UCanCode Documentation", function() love.system.openURL("https://esolangs.org/wiki/UCanCode") end, 5, 120, 200, 40)
		return 
	end
	if compiled.draw then compiled.draw() end
end

return window
