local utf8 = require "utf8"

local window = {}
window.title = "Paint"
window.icon = "images/icons/paint.png"
local t = 0

local f

local canvas

local isDown = false

local palette = {
    {1, 0, 0},
    {1, 0.5, 0},
    {1, 1, 0},
    {0.5, 1, 0},
    {0, 1, 0},
    {0, 1, 0.5},
    {0, 1, 1},
    {0, 0.5, 1},
    {0, 0, 1},
    {0.5, 0, 1},
    {1, 0, 1},
    {1, 0, 0.5},
    {0.5, 0, 0},
    {0.5, 0.5, 0},
    {0, 0.5, 0},
    {0, 0.5, 0.5},
    {0, 0, 0.5},
    {0.5, 0, 0.5},
    {0, 0, 0},
    {0.5, 0.5, 0.5},
    {1, 1, 1}
}

local color, fillMode, lineWidth
local mouseStartX, mouseStartY
local tool
local tools = {}

tools.brush = {}
function tools.brush.mousepressed(x, y, button)

end

function tools.brush.mousereleased(x, y, button)

end

function tools.brush.mousemoved(x, y, dx, dy)
    love.graphics.push()
    love.graphics.translate(0-windowX-10, 0-windowY-30)
    if love.mouse.isDown(1) then
        love.graphics.setCanvas(canvas)
        
        love.graphics.setColor(color)
        love.graphics.setLineWidth(lineWidth)
        love.graphics.line(x-dx, y-dy, x, y)
        love.graphics.setLineWidth(1)
        
        love.graphics.setCanvas()
    end
    love.graphics.pop()
end

tools.rectangle = {}
function tools.rectangle.mousepressed(x, y, button)
    if button == 1 then
        mouseStartX, mouseStartY = x, y
    end
end

function tools.rectangle.mousereleased(x, y, button)
    if not mouseStartX or not mouseStartY then return end
    
    love.graphics.push()
    love.graphics.translate(0-windowX-10, 0-windowY-30)
    
    love.graphics.setCanvas(canvas)
    
    love.graphics.setColor(color)
    love.graphics.setLineWidth(lineWidth)
    love.graphics.rectangle(fillMode, mouseStartX, mouseStartY, x-mouseStartX, y-mouseStartY)
    love.graphics.setLineWidth(1)
    
    love.graphics.setCanvas()
    
    love.graphics.pop()
end

function tools.rectangle.draw()
    if not mouseStartX or not mouseStartY then return end
    if love.mouse.isDown(1) then
        love.graphics.push()
        love.graphics.translate(0-windowX, 0-windowY)
    
        love.graphics.setColor(color)
        love.graphics.setLineWidth(lineWidth)
        love.graphics.rectangle(fillMode, mouseStartX, mouseStartY, love.mouse.getX() - mouseStartX, love.mouse.getY() - mouseStartY)
        love.graphics.setLineWidth(1)
        
        love.graphics.pop()
    end
end

tools.ellipse = {}
function tools.ellipse.mousepressed(x, y, button)
    if button == 1 then
        mouseStartX, mouseStartY = x, y
    end
end

function tools.ellipse.mousereleased(x, y, button)
    if not mouseStartX or not mouseStartY then return end
    
    love.graphics.push()
    love.graphics.translate(0-windowX-10, 0-windowY-30)
    
    love.graphics.setCanvas(canvas)
    
    love.graphics.setColor(color)
    love.graphics.setLineWidth(lineWidth)
    love.graphics.ellipse(fillMode, mouseStartX + (x - mouseStartX)/2, mouseStartY + (y - mouseStartY)/2, math.abs(x - mouseStartX)/2, math.abs(y - mouseStartY)/2)
    love.graphics.setLineWidth(1)
    
    love.graphics.setCanvas()
    
    love.graphics.pop()
end

function tools.ellipse.draw()
    if not mouseStartX or not mouseStartY then return end
    if love.mouse.isDown(1) then
        love.graphics.push()
        love.graphics.translate(0-windowX, 0-windowY)
    
        love.graphics.setColor(color)
        love.graphics.setLineWidth(lineWidth)
        love.graphics.ellipse(fillMode, mouseStartX + (love.mouse.getX() - mouseStartX)/2, mouseStartY + (love.mouse.getY() - mouseStartY)/2, math.abs(love.mouse.getX() - mouseStartX)/2, math.abs(love.mouse.getY() - mouseStartY)/2)
        love.graphics.setLineWidth(1)
        
        love.graphics.pop()
    end
end

tools.line = {}
function tools.line.mousepressed(x, y, button)
    if button == 1 then
        mouseStartX, mouseStartY = x, y
    end
end

function tools.line.mousereleased(x, y, button)
    if not mouseStartX or not mouseStartY then return end
    
    love.graphics.push()
    love.graphics.translate(0-windowX-10, 0-windowY-30)
    
    love.graphics.setCanvas(canvas)
    
    love.graphics.setColor(color)
    love.graphics.setLineWidth(lineWidth)
    love.graphics.line(mouseStartX, mouseStartY, x, y)
    love.graphics.setLineWidth(1)
    
    love.graphics.setCanvas()
    
    love.graphics.pop()
end

function tools.line.draw()
    if not mouseStartX or not mouseStartY then return end
    if love.mouse.isDown(1) then
        love.graphics.push()
        love.graphics.translate(0-windowX, 0-windowY)
    
        love.graphics.setColor(color)
        love.graphics.setLineWidth(lineWidth)
        love.graphics.line(mouseStartX, mouseStartY, love.mouse.getX(), love.mouse.getY())
        love.graphics.setLineWidth(1)
        
        love.graphics.pop()
    end
end

local txt = ""

tools.text = {}
function tools.text.mousepressed(x, y, button)
    if button == 1 then
        mouseStartX, mouseStartY = x, y
        txt = ""
    end
end

function tools.text.keypressed(key)
    if not mouseStartX or not mouseStartY then return end
    
    if key == "backspace" then
        local byteoffset = utf8.offset(txt, -1)
        if byteoffset then
            txt = string.sub(txt, 1, byteoffset - 1)
        end
    end
    
    if key == "return" then
        if not mouseStartX or not mouseStartY then return end
        
        love.graphics.push()
        love.graphics.translate(0-windowX-10, 0-windowY-30)
        
        love.graphics.setCanvas(canvas)
        
        love.graphics.setColor(color)
        love.graphics.print(txt, mouseStartX, mouseStartY)
        
        love.graphics.setCanvas()
        
        love.graphics.pop()
        
        mouseStartX, mouseStartY = nil, nil
    end
end

function tools.text.textinput(text)
    txt = txt .. text
end

function tools.text.draw()
    if not mouseStartX or not mouseStartY then return end
    
    local textCursor = ""
    if math.floor(t*3) % 2 == 0 then
        textCursor = "_"
    end
    
    love.graphics.push()
    love.graphics.translate(0-windowX, 0-windowY)

    love.graphics.setColor(color)
    love.graphics.print(txt .. textCursor, mouseStartX, mouseStartY)
    
    love.graphics.pop()
end

local function saveImg()
    local imgdata, err = canvas:newImageData():encode("png")
    if not imgdata and err then
        messageBox("Error", err, {{"OK", function() closeMessageBox() end}}, "sounds/critical.wav")
    end
    
    save(f, imgdata:getString(), "png", function(path)
        f = path
        window.title = "Paint - " .. f
    end)
end

local function openImg(file)
    open(function(_, path)
        f = path
        local img = love.graphics.newImage(f)
        if canvas then
            canvas:renderTo(function()
                love.graphics.push()
                love.graphics.origin()
                love.graphics.setScissor()
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(img, 0, 0)
                love.graphics.pop()
            end)
        end
        window.title = "Paint - " .. f
    end, file)
end

function window.load(file)
    f = nil
    window.title = "Paint"
    t = 0
    isDown = false
    tool = "brush"
    color = {0, 0, 0}
    fillMode = "fill"
    lineWidth = 1
    
    canvas = love.graphics.newCanvas(480, 360)
    canvas:renderTo(function()
        love.graphics.setScissor()
        love.graphics.clear(1, 1, 1, 1)
    end)
    
    if file then
        openImg(file)
    end
end

function window.mousepressed(x, y, button)
    if tools[tool].mousepressed then tools[tool].mousepressed(x, y, button) end
    if windowX + 10 <= x and x <= windowX + 490 and windowY + 30 <= y and y <= windowY + 390 then isDown = true end
end

function window.mousereleased(x, y, button)
    if tools[tool].mousereleased then tools[tool].mousereleased(x, y, button) end
    isDown = false
end

function window.mousemoved(x, y, dx, dy)
    if tools[tool].mousemoved then tools[tool].mousemoved(x, y, dx, dy) end
end

function window.keypressed(key)
    if tools[tool].keypressed then tools[tool].keypressed(key) end
end

function window.textinput(text)
    if tools[tool].textinput then tools[tool].textinput(text) end
end

function window.update(dt)
    t = t + dt
end

function window.draw()
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, 10, 30)
    outline(10, 30, 480, 360)
    
    love.graphics.setScissor(windowX + 10, windowY + 30, 480, 360)
    if tools[tool].draw then tools[tool].draw() end
    love.graphics.setScissor()
    
    button("New", function() if isDown then return end messageBox("Paint", "Save changes?", {{"Yes", function() saveImg() closeMessageBox() window.load() end}, {"No", function() closeMessageBox() window.load() end}, {"Cancel", function() closeMessageBox() end}}) end, 0, 0, 80, 25)
    button("Open", function() if isDown then return end openImg() end, 100, 0, 80, 25)
    button("Save", function() if isDown then return end saveImg() end, 200, 0, 80, 25)
    
    button("Brush", function() if isDown then return end tool = "brush" end, 10, 400, 80, 30)
    button("Rectangle", function() if isDown then return end tool = "rectangle" end, 100, 400, 80, 30)
    button("Ellipse", function() if isDown then return end tool = "ellipse" end, 190, 400, 80, 30)
    button("Line", function() if isDown then return end tool = "line" end, 280, 400, 80, 30)
    button("Text", function() if isDown then return end tool = "text" end, 370, 400, 80, 30)
    rect(10, 440, 30, 30, color)
    button("Line Width", function() textInput("Enter a number", function(text) lineWidth = tonumber(text) end) end, 50, 440, 80, 30)
    button("Fill Mode", function() textInput("Enter 'fill' or 'line'", function(text) if text == "fill" or text == "line" then fillMode = text end end) end, 140, 440, 80, 30)
    
    for y, c in ipairs(palette) do
        button("", function() if isDown then return end color = c end, 500 + (y-1)%2 * 40, 30 + math.floor((y-1)/2)*40, 30, 30, c, false)
    end
    
    button("Custom Color", function() if isDown then return end selectColor(function(c) color = c end) end, 580, 30, 120, 30)
end

return window
