local Object = require "lib.classic"

local Element

local m = {}

local function checkType(obj, class)
    return (obj.is) and (obj:is(class))
end


-- Gui

m.Gui = Object:extend()

function m.Gui:new(t)
    self.frame = t.frame or m.Frame{width = t.width, height = t.height}
end

function m.Gui:put(...)
    self.frame:put(...)
end

function m.Gui:mousepressed(...)
    self.frame:mousepressed(...)
end

function m.Gui:draw()
    self.frame:draw()
end

-- Element

Element = Object:extend()

function Element:new(t)
    self.x = 0
    self.y = 0
    self.width = t.width or 0
    self.height = t.height or 0
    self.marginX = t.marginX or 10
    self.marginY = t.marginY or 10
end

function Element:draw() end

-- Frame

m.Frame = Element:extend()

function m.Frame:new(t)
    self.super.new(self, t)
    self.content = {}
    self.x = 0
    self.y = 0
    self.marginX = 0
    self.marginY = 0
end

function m.Frame:put(elements, params)
    params = params or {}
    
    local t = {}
    t.elements = elements
    t.align = params.align or "left"
    t.verticalAlign = params.verticalAlign or "center"
    
    table.insert(self.content, t)
    self:computePositions()
end

function m.Frame:computePositions()
    local ex, ey = 0, 0
    
    for _, group in ipairs(self.content) do
        local totalWidth = 0
        local totalHeight = 0
        
        for _, element in ipairs(group.elements) do
            totalWidth = totalWidth + element.width + element.marginX*2
            
            local height = element.height + element.marginY*2
            if height > totalHeight then
                totalHeight = height
            end
        end
        
        if group.align == "left" then
        elseif group.align == "right" then
            ex = ex + self.width - totalWidth
        elseif group.align == "center" then
            ex = ex + math.floor(self.width/2 - totalWidth/2), 0
        end
        
        for _, element in ipairs(group.elements) do
            if checkType(element, Element) then
                
                local x, y = ex + element.marginX, ey + element.marginY
                
                if group.verticalAlign == "top" then
                elseif group.verticalAlign == "center" then
                    y = y + totalHeight/2 - element.height/2
                end
                
                element.x = x
                element.y = y
                ex = ex + element.width + element.marginX*2
            end
        end
        
        ex = 0
        ey = ey + totalHeight
    end
end

function m.Frame:mousepressed(x, y, button)
    local mx, my = x - windowX, y - windowY
    for _, group in ipairs(self.content) do
        for _, element in ipairs(group.elements) do
            print(mx, my, element.x, element.y, element.width, element.height)
            if  (element.action) and (button == 1)
            and element.x <= mx and mx <= element.x + element.width
            and element.y <= my and my <= element.y + element.height
            then
                element:action()
            end
        end
    end
end

function m.Frame:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    for _, group in ipairs(self.content) do
        for _, element in ipairs(group.elements) do
            if checkType(element, Element) then
                element:draw()
            end
        end
    end
    
    love.graphics.pop()
end

-- Text

m.Text = Element:extend()

function m.Text:new(t)
    self.text = t.text or ""
    self.font = t.font or love.graphics.getFont()
    self.color = t.color or style.text.color
    
    self.super.new(self, {
        width = t.width or self.font:getWidth(self.text),
        height = t.height or self.font:getHeight()
    })
end

function m.Text:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    love.graphics.printf(self.text, self.x, self.y, self.width)
end

-- Button

m.Button = Element:extend()

function m.Button:new(t)
    self.label = t.label or ""
    self.action = t.action or function() end
    self.color = t.color or style.button.color
    self.tint = t.tint or {1, 1, 1, 1}
    self.outlineColor = t.outlineColor or style.button.outlineColor
    self.labelColor = t.labelColor or style.button.textColor
    self.labelFont = t.labelFont or love.graphics:getFont()
    
    self.super.new(self, {
        width = t.width or self.labelFont:getWidth(self.label) + 40,
        height = t.height or 40
    })
end

function m.Button:draw()
    local brightnessOffset = 0
    
    local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
    if self.x <= mx and mx <= self.x + self.width and self.y <= my and my <= self.y + self.height then
        brightnessOffset = 0.1
    else
        brightnessOffset = 0
    end
    
    local newColor
    
    if type(self.color) == "string" then
        if brightnessOffset > 0 then
            newColor = {1, 1, 1, 0.25}
        else
            newColor = {0, 0, 0, 0}
        end
        image(self.color, self.x, self.y, self.width, self.height, self.tint)
        rect(self.x, self.y, self.width, self.height, newColor)
    else
        newColor = {self.color[1] + brightnessOffset, self.color[2] + brightnessOffset, self.color[3] + brightnessOffset, self.color[4]}
        rect(self.x, self.y, self.width, self.height, newColor)
    end
    outline(self.x, self.y, self.width, self.height, self.outlineColor)
    text(self.label, self.x + self.width/2 - self.labelFont:getWidth(self.label)/2, self.y + self.height/2 - self.labelFont:getHeight()/2, self.labelColor)
end

return m
