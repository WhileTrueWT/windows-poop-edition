local window = {}
window.title = "Calculator"
window.windowWidth = 210

local x, y
local m
local op

function window.load()
    x = 0
    y = 0
    m = 0
    op = nil
end

function window.draw()
    rect(5, 5, windowWidth-10, 40, {0, 0, 0})
    text(x, 10, 10, {1, 1, 1})
    
    love.graphics.translate(5, 5)
    
    
    
    button("MC", function() m = x end, 0, 50, 40, 40)
    
    button("MR", function() x = m end, 50, 50, 40, 40)
    
    button("M-", function() m = m - x end, 100, 50, 40, 40)
    
    button("M+", function() m = m + x end, 150, 50, 40, 40)
    
    button("C", function()
        
        x = 0
        y = 0
        op = nil
        
    end, 0, 100, 40, 40)
    
    button("CE", function() x = 0 end, 50, 100, 40, 40)
    
    button("sqrt", function() x = math.sqrt() end, 100, 100, 40, 40)
    
    button("+/-", function() x = 0-x end, 150, 100, 40, 40)
    
    button("7", function() x = x .. '7' end, 0, 150, 40, 40)
    button("8", function() x = x .. '8' end, 50, 150, 40, 40)
    button("9", function() x = x .. '9' end, 100, 150, 40, 40)
    button("4", function() x = x .. '4' end, 0, 200, 40, 40)
    button("5", function() x = x .. '5' end, 50, 200, 40, 40)
    button("6", function() x = x .. '6' end, 100, 200, 40, 40)
    button("1", function() x = x .. '1' end, 0, 250, 40, 40)
    button("2", function() x = x .. '2' end, 50, 250, 40, 40)
    button("3", function() x = x .. '3' end, 100, 250, 40, 40)
    button("0", function() x = x .. '0' end, 0, 300, 40, 40)
    button(".", function()
        
        if not string.find(tostring(x), ".") then
            x = tonumber(tostring(x) .. '.')
        end
        
    end, 50, 300, 40, 40)
    
    button("/", function()
    
        op = "/"
        y = x
        
    end, 150, 150, 40, 40)
    
    button("*", function()
    
        op = "*"
        y = x
        
    end, 150, 200, 40, 40)
    
    button("-", function()
    
        op = "-"
        y = x
        
    end, 150, 250, 40, 40)
    
    button("+", function()
    
        op = "+"
        y = x
        
    end, 150, 300, 40, 40)
    
    button("=", function()
        
        if op then
            if op == "+" then
                x = x + y
            elseif op == "-" then
                x = x - y
            elseif op == "*" then
                x = x * y
            elseif op == "/" then
                x = x / y
            end
        end
        
    end, 100, 300, 40, 40)
    
    love.graphics.origin()
end

return window