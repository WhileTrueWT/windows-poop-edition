local acc
local output
local outputCanvas

local function init()
    output = {}
    acc = 0
end

local function drawOutput()
    love.graphics.push()
    love.graphics.reset()
    love.graphics.setCanvas(outputCanvas)
    love.graphics.clear()

    for y, v in ipairs(output) do
        text(v, 0, y*20)
    end

    love.graphics.setCanvas()
    love.graphics.pop()
end

local function cmd(c)
    if c == "i" then
        acc = acc + 1
    elseif c == "d" then
        acc = acc - 1
    elseif c == "s" then
        acc = acc * acc
    elseif c == "o" then
        table.insert(output, acc)
        if #output > 8 then
            table.remove(output, 1)
        end

        if #output == 2 and output[1] == 69 and output[2] == 420 then
            messageBox("Deadfish", "Congratulations! You have won the game because of how funny you are.")
        end
        
        drawOutput()
    end
    -- Make Sure X Is Not Greater Then 256!!!
    if acc == -1 or acc == 256 then
        acc = 0
    end
end

local window = {}
window.title = "Deadfish"
window.windowWidth = 200
window.windowHeight = 200
window.icon = "images/icons/deadfish.png"

function window.load()
    outputCanvas = love.graphics.newCanvas(100, windowHeight)
    init()
end

function window.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(outputCanvas, 100, 0)
    button("i", function() cmd("i") end, 5, 5, 40, 40)
    button("d", function() cmd("d") end, 50, 5, 40, 40)
    button("s", function() cmd("s") end, 5, 50, 40, 40)
    button("o", function() cmd("o") end, 50, 50, 40, 40)
    button("New Game", function() init() drawOutput() end, 5, 95, 85, 40)
end

return window