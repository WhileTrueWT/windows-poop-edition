local utf8 = require "utf8"
local Object = require "lib.classic"

local Element

local m = {}

local function checkType(obj, class)
    return (obj.is) and (obj:is(class))
end


-- Gui

m.Gui = Object:extend()

function m.Gui:new(t)
    self.frame = t.frame or m.Frame{
        width = t.width,
        height = t.height,
        marginX = 0,
        marginY = 0,
        outlineColor = {0, 0, 0, 0}
    }
end

function m.Gui:put(elements, ...)
    for _, element in ipairs(elements) do
        element.gui = self
        
        if checkType(element, m.Frame) then
            for _, group in ipairs(element.content) do
                for _, element in ipairs(group.elements) do
                    element.gui = self
                end
            end
        end
    end
    self.frame:put(elements, ...)
end

function m.Gui:draw()
    self.frame:draw()
end

function m.Gui:mousepressed(...)
    self.frame:mousepressed(...)
end

function m.Gui:keypressed(...)
    self.frame:keypressed(...)
end

function m.Gui:textinput(...)
    self.frame:textinput(...)
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
function Element:mousepressed() end
function Element:keypressed() end
function Element:textinput() end

-- Frame

m.Frame = Element:extend()

function m.Frame:new(t)
    self.super.new(self, t)
    self.content = {}
    self.x = 0
    self.y = 0
    
    if t.width then
        self.hasFixedWidth = true
    end
    if t.height then
        self.hasFixedHeight = true
    end
    
    self.outlineColor = t.outlineColor or {0, 0, 0, 1}
end

function m.Frame:put(elements, params)
    params = params or {}
    
    local t = {}
    t.elements = elements
    t.align = params.align or "left"
    t.verticalAlign = params.verticalAlign or "center"
    
    for _, element in ipairs(t.elements) do
        element.frame = self
    end
    
    table.insert(self.content, t)
    self:computePositions()
end

function m.Frame:computePositions()
    local ex, ey = self.x, self.y
    local totalFrameWidth = 0
    local totalFrameHeight = 0
    
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
        
        if totalWidth > totalFrameWidth then
            totalFrameWidth = totalWidth
        end
        totalFrameHeight = totalFrameHeight + totalHeight
        
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
                    y = y + totalHeight/2 - (element.height + element.marginY*2)/2
                end
                
                element.x = x
                element.y = y
                ex = ex + element.width + element.marginX*2
                
                if checkType(element, m.Frame) then
                    element:computePositions()
                end
            end
        end
        
        ex = self.x
        ey = ey + totalHeight
    end
    
    if not self.hasFixedWidth then
        self.width = totalFrameWidth
    end
    if not self.hasFixedHeight then
        self.height = totalFrameHeight
    end
end

function m.Frame:mousepressed(x, y, button)
    local mx, my = x - windowX, y - windowY
    for _, group in ipairs(self.content) do
        for _, element in ipairs(group.elements) do
            if  element.x <= mx and mx <= element.x + element.width
            and element.y <= my and my <= element.y + element.height
            then
                element:mousepressed(x, y, button)
            end
        end
    end
end

function m.Frame:keypressed(key, scancode)
    for _, group in ipairs(self.content) do
        for _, element in ipairs(group.elements) do
            element:keypressed(key, scancode)
        end
    end
end

function m.Frame:textinput(text)
    for _, group in ipairs(self.content) do
        for _, element in ipairs(group.elements) do
            element:textinput(text)
        end
    end
end

function m.Frame:draw()
    love.graphics.setColor(self.outlineColor)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    
    for _, group in ipairs(self.content) do
        for _, element in ipairs(group.elements) do
            if checkType(element, Element) then
                element:draw()
            end
        end
    end
end

-- Text

m.Text = Element:extend()

function m.Text:new(t)
    self.text = t.text or ""
    self.font = t.font or love.graphics.getFont()
    self.color = t.color or style.text.color
    
    local width = t.width or self.font:getWidth(self.text)
    local height = t.height or self.font:getHeight() * #(select(2, self.font:getWrap(self.text, width)))
    self.super.new(self, {
        width = width,
        height = height
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
        height = t.height or 30
    })
end

function m.Button:draw()
    local brightnessOffset = 0
    
    local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
    if  self.x <= mx
        and mx <= self.x + self.width
        and self.y <= my
        and my <= self.y + self.height
        and not love.mouse.isDown(1)
    then
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

function m.Button:mousepressed(x, y, button)
    if button == 1 then
        self:action()
    end
end

-- Image

m.Image = Element:extend()

function m.Image:new(t)
    self.file = t.file or ""
    
    self.super.new(self, {
        width = t.width or self.loveImage:getWidth(),
        height = t.height or self.loveImage:getHeight()
    })
end

function m.Image:draw()
    image(self.file, self.x, self.y, self.width, self.height)
end

-- Canvas

m.Canvas = Element:extend()

function m.Canvas:new(t)
    self.super.new(self, t)
    self.draw = t.draw and (function(self)
        love.graphics.push()
        local gx, gy = love.graphics.transformPoint(self.x, self.y)
        love.graphics.setScissor(gx, gy, self.width, self.height)
        love.graphics.translate(self.x, self.y)
        
        t.draw()
        
        love.graphics.setScissor()
        love.graphics.pop()
    end) or function() end
end

-- TextBox

m.TextBox = Element:extend()

function m.TextBox:new(t)
    self.super.new(self, {
        width = t.width or 200,
        height = t.height or 30
    })
    
    self.value = ""
    self.label = t.label or ""
    self.multiline = t.multiline or false
    self.color = t.color or {1, 1, 1, 1}
    self.outlineColor = t.outlineColor or {0, 0, 0, 1}
    self.textColor = t.textColor or style.text.color
    self.labelColor = t.labelColor or {0.6, 0.6, 0.6, 1}
    self.font = t.font or love.graphics.getFont()
    
    self.onEnterPressed = t.onEnterPressed or function() end
    
    self.isActive = false
    self.lines = self.multiline and {""}
    self.currentLine = self.lines and 1
    self.currentPos = 0
end

function m.TextBox:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(self.outlineColor)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    
    love.graphics.setFont(self.font)
    
    if (not self.isActive) and (#self.value == 0) then
        love.graphics.setColor(self.labelColor)
        love.graphics.print(self.label, self.x + 5, self.y + 5)
    else
        local cursor = ""
        if self.isActive then
            cursor = ((math.floor(love.timer.getTime() * 2) % 2) == 0) and "_" or " "
        end
        
        local s = self.value
        local f = love.graphics.getFont()
        local pos = f:getWidth(s) <= self.width and 0 or 0 - f:getWidth(s) + (self.width - 10)
        
        local sx, sy = love.graphics.transformPoint(self.x, self.y)
        love.graphics.setScissor(sx, sy, self.width, self.height)
        love.graphics.setColor(self.textColor)
        
        if self.multiline then
            for i, line in ipairs(self.lines) do
                love.graphics.print(
                    (i == self.currentLine) and
                        string.sub(line, 1, self.currentPos)
                        .. cursor
                        .. string.sub(line, self.currentPos + 1)
                    or line,
                self.x + 5 + pos, self.y + 5 + (i-1)*f:getHeight())
            end
        else
            love.graphics.print(
                string.sub(self.value, 1, self.currentPos)
                .. cursor
                .. string.sub(self.value, self.currentPos + 1),
            self.x + 5 + pos, self.y + 5)
        end
        
        love.graphics.setScissor()
    end
    
end

function m.TextBox:mousepressed(x, y, button)
    if self.gui.activeTextBox then
        self.gui.activeTextBox.isActive = false
    end
    self.gui.activeTextBox = self
    self.isActive = true
    love.keyboard.setKeyRepeat(true)
end

function m.TextBox:textinput(text)
    if self.isActive then
        if self.multiline then
            self.lines[self.currentLine] = string.sub(self.lines[self.currentLine], 1, self.currentPos) .. text .. string.sub(self.lines[self.currentLine], self.currentPos+1)
            self:updateValue()
        else
            self.value = string.sub(self.value, 1, self.currentPos) .. text .. string.sub(self.value, self.currentPos+1)
        end
        self.currentPos = self.currentPos + 1
    end
end

function m.TextBox:keypressed(key)
    if self.isActive then
        if key == "return" then
            if self.multiline then
                table.insert(self.lines, self.currentLine+1, string.sub(self.lines[self.currentLine], self.currentPos+1))
                self.lines[self.currentLine] = string.sub(self.lines[self.currentLine], 1, self.currentPos)
                self.currentLine = self.currentLine + 1
                self.currentPos = 0
                self:updateValue()
            else
                self.gui.activeTextBox = nil
                self.isActive = false
                love.keyboard.setKeyRepeat(false)
                self:onEnterPressed()
            end
        
        elseif key == "backspace" then
            if self.multiline then
                local byteoffset = utf8.offset(self.lines[self.currentLine], -1, self.currentPos+1)
                if byteoffset then
                    self.lines[self.currentLine] = string.sub(self.lines[self.currentLine], 1, byteoffset - 1) .. string.sub(self.lines[self.currentLine], byteoffset+1)
                    self.currentPos = self.currentPos - 1
                elseif self.currentLine > 1 then
                    local line = table.remove(self.lines, self.currentLine)
                    self.currentLine = self.currentLine - 1
                    self.currentPos = #self.lines[self.currentLine]
                    self.lines[self.currentLine] = self.lines[self.currentLine] .. line
                end
                self:updateValue()
            else
                local byteoffset = utf8.offset(self.value, -1, self.currentPos+1)
                if byteoffset then
                    self.value = string.sub(self.value, 1, byteoffset - 1) .. string.sub(self.value, byteoffset+1)
                    self.currentPos = self.currentPos - 1
                end
            end
        
        elseif key == "left" then
            if self.multiline and self.currentPos == 0 and self.currentLine > 1 then
                self.currentLine = self.currentLine - 1
                self.currentPos = #self.lines[self.currentLine]
            elseif self.currentPos > 0 then
                self.currentPos = self.currentPos - 1
            end
        
        elseif key == "right" then
            if self.multiline and self.currentPos == #self.lines[self.currentLine] and self.currentLine < #self.lines then
                self.currentLine = self.currentLine + 1
                self.currentPos = 0
            elseif self.currentPos < #(self.multiline and self.lines[self.currentLine] or self.value) then
                self.currentPos = self.currentPos + 1
            end
        
        elseif self.multiline and key == "up" and self.currentLine > 1 then
            self.currentLine = self.currentLine - 1
            if self.currentPos > #self.lines[self.currentLine] then
                self.currentPos = #self.lines[self.currentLine]
            end
        
        elseif self.multiline and key == "down" and self.currentLine < #self.lines then
            self.currentLine = self.currentLine + 1
            if self.currentPos > #self.lines[self.currentLine] then
                self.currentPos = #self.lines[self.currentLine]
            end
        end
    end
end

function m.TextBox:updateValue()
    self.value = table.concat(self.lines, "\n")
end

-- CheckBox

m.CheckBox = Element:extend()

function m.CheckBox:new(t)
    self.value = t.value or false
    
    self.onToggle = t.onToggle or function() end
    
    self.super.new(self, {
        width = 30,
        height = 30
    })
end

function m.CheckBox:draw()
    image(self.value and "images/check.png" or "images/uncheck.png", self.x, self.y, self.width, self.height)
    
    local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
    if  self.x <= mx
        and mx <= self.x + self.width
        and self.y <= my
        and my <= self.y + self.height
        and not love.mouse.isDown(1)
    then
        rect(self.x, self.y, self.width, self.height, {1, 1, 1, 0.2})
    end
end

function m.CheckBox:mousepressed()
    self.value = not self.value
    self.onToggle(self.value)
end

return m
