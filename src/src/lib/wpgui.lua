local Object = require "lib.classic"

local Element

local m = {}

local function checkType(obj, class)
    return (obj.is) and (obj:is(class))
end


-- Gui

m.Gui = Object:extend()

function m.Gui:new(t)
    self.frame = t.frame or m.Frame()
end

function m.Gui:put(...)
    self.frame:put(...)
end

function m.Gui:draw()
    self.frame:draw()
end

-- Frame

m.Frame = Object:extend()

function m.Frame:new(t)
    self.content = {}
end

function m.Frame:put(elements, params)
    params = params or {}
    
    local t = {}
    t.elements = elements
    t.align = params.align or "left"
    
    table.insert(self.content, t)
end

function m.Frame:draw()
    for _, group in ipairs(self.content) do
        for _, element in ipairs(group.elements) do
            if checkType(element, Element) then
                element:draw(0, 0)
            end
        end
    end
end

-- Element

Element = Object:extend()

function Element:new(t)
    self.width = t.width or 0
    self.height = t.height or 0
end

-- Text

m.Text = Element:extend()

function m.Text:new(t)
    self.text = t.text or ""
    self.font = t.font or love.graphics.getFont()
    self.color = t.color or {0, 0, 0, 1}
    
    self.super.new(self, {
        width = t.width or self.font:getWidth(self.text),
        height = t.height or self.font:getHeight()
    })
end

function m.Text:draw(x, y)
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    love.graphics.printf(self.text, x, y, self.width)
end

return m
