local window = {}
window.title = "Calculator"
window.windowWidth = 210
window.windowHeight = 350

local x, y
local m
local op
local isDecimalPoint
local divisor
local isEnteringX

local function addDigit(d)
    if not isEnteringX then
        x = 0
        isEnteringX = true
    end
    
    if isDecimalPoint then
        x = x + d / divisor
        divisor = divisor * 10
    else
        x = x * 10 + d
    end
end

function window.load()
    x = 0
    y = 0
    m = 0
    op = nil
    isDecimalPoint = false
    divisor = nil
    isEnteringX = true
end

function window.draw()
    rect(5, 5, windowWidth-10, 40, {0, 0, 0})
    text(x, 10, 10, {1, 1, 1})
    
    if m ~= 0 then
        text("M", windowWidth-20, 10, {1, 1, 1})
    end
    
    love.graphics.translate(5, 5)
    
    
    
    button("MC", function() m = 0 end, 0, 50, 40, 40)
    
    button("MR", function() x = m end, 50, 50, 40, 40)
    
    button("M-", function() m = m - x end, 100, 50, 40, 40)
    
    button("M+", function() m = m + x end, 150, 50, 40, 40)
    
    button("C", function()
        
        x = 0
        y = 0
        op = nil
        isDecimalPoint = false
        isEnteringX = true
        
    end, 0, 100, 40, 40)
    
    button("CE", function() x = 0 end, 50, 100, 40, 40)
    
    button("sqrt", function()
        isEnteringX = false
        x = math.sqrt(x)
    end, 100, 100, 40, 40)
    
    button("+/-", function() x = 0-x end, 150, 100, 40, 40)
    
    button("7", function() addDigit(7) end, 0, 150, 40, 40)
    button("8", function() addDigit(8) end, 50, 150, 40, 40)
    button("9", function() addDigit(9) end, 100, 150, 40, 40)
    button("4", function() addDigit(4) end, 0, 200, 40, 40)
    button("5", function() addDigit(5) end, 50, 200, 40, 40)
    button("6", function() addDigit(6) end, 100, 200, 40, 40)
    button("1", function() addDigit(1) end, 0, 250, 40, 40)
    button("2", function() addDigit(2) end, 50, 250, 40, 40)
    button("3", function() addDigit(3) end, 100, 250, 40, 40)
    button("0", function() addDigit(0) end, 0, 300, 40, 40)
    button(".", function()
        
        isDecimalPoint = true
        divisor = 10
        
    end, 50, 300, 40, 40)
    
    button("/", function()
    
        op = "/"
        y = x
        isEnteringX = false
        isDecimalPoint = false
        
    end, 150, 150, 40, 40)
    
    button("*", function()
    
        op = "*"
        y = x
        isEnteringX = false
        isDecimalPoint = false
        
    end, 150, 200, 40, 40)
    
    button("-", function()
    
        op = "-"
        y = x
        isEnteringX = false
        isDecimalPoint = false
        
    end, 150, 250, 40, 40)
    
    button("+", function()
    
        op = "+"
        y = x
        isEnteringX = false
        isDecimalPoint = false
        
    end, 150, 300, 40, 40)
    
    button("=", function()
    
        isDecimalPoint = false
        isEnteringX = false
        
        if op then
            if op == "+" then
                x = y + x
            elseif op == "-" then
                x = y - x
            elseif op == "*" then
                x = y * x
            elseif op == "/" then
				x = y / x
            end
        end
        
    end, 100, 300, 40, 40)
    
    love.graphics.origin()
end

return window
