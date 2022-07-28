local window = {}
window.title = "Solitaire"
window.icon = "images/icons/solitaire.png"

local dragging
local cards = {}

local function Card()
    local card = {}
    
    local r = love.math.random(1, 26)
    card.label = tostring(love.math.random(0,9)) .. string.sub("ABCDEFGHIJKLMNOPQRSTUVWXYZ", r, r)
    card.color = {love.math.random(0, 1)/2, love.math.random(0, 1)/2, love.math.random(0, 1)/2, 1}
    card.x = love.math.random(0, windowWidth)
    card.y = love.math.random(0, windowHeight)
    
    return card
end

function window.load()
    dragging = nil
    cards = {}
    for i=1,20 do
        table.insert(cards, Card())
    end
end

function window.mousepressed(x, y, button)
    if button ~= 1 then return end
    local lx, ly = x-windowX, y-windowY
    for i, card in ipairs(cards) do
        if card.x <= lx and lx <= card.x+60
        and card.y <= ly and ly <= card.y+80 then
            dragging = i
        end
    end
end

function window.mousereleased()
    if dragging then
        dragging = nil
    end
end

function window.mousemoved(x, y, dx, dy)
    if dragging then
        cards[dragging].x = cards[dragging].x + dx
        cards[dragging].y = cards[dragging].y + dy
    end
end

function window.draw()
    rect(0, 0, windowWidth, windowHeight, {0, 0.5, 0})
    for i, card in ipairs(cards) do
        rect(card.x, card.y, 60, 80, {1, 1, 1})
        rect(card.x+20, card.y+30, 20, 20, card.color)
        outline(card.x, card.y, 60, 80, {0, 0, 0})
        text(card.label, card.x, card.y)
    end
end

return window
