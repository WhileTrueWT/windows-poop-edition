local g3d = require "lib/g3d"

local window = {}
window.title = "3D Epicness"
window.hideWindowDec = true
window.fullscreen = true
window.windowWidth = displayWidth
window.windowHeight = displayHeight
window.windowX = 0
window.windowY = 0

local chamber
local objects = {}
local objectPositions = {}
local objectDirs = {}
local objectColors = {}
local t

local function makeObject(shape)
    local pos = {}
    local dir = {}
    local color = {}
    for i=1,3 do
        pos[i] = love.math.random(-100, 100)
        dir[i] = love.math.random(-1, 1)
        color[i] = love.math.random()
    end
    
    table.insert(objects, g3d.newModel("lib/" .. shape .. ".obj", "images/gradient.png", pos, nil, {5, 5, 5}))
    table.insert(objectPositions, pos)
    table.insert(objectDirs, dir)
    table.insert(objectColors, color)
end

function window.load()
    t = 0
    objects = {}
    objectPositions = {}
    objectDirs = {}
    love.mouse.setRelativeMode(true)
    chamber = g3d.newModel("lib/cube.obj", "images/background.png", nil, nil, {120, 120, 120})
end

function window.keypressed(key)
    if key == "escape" then
        love.mouse.setRelativeMode(false)
        love.mouse.isVisible(true)
        closeWindow()
    end
end

function window.mousemoved(x,y, dx,dy)
    g3d.camera.firstPersonLook(dx,dy)
end

function window.mousepressed(x, y, button)
    if button == 1 then
        makeObject("cube")
    elseif button == 2 then
        makeObject("sphere")
    end
end

function window.update(dt)
    t = t + dt
    g3d.camera.firstPersonMovement(dt*2)
    for i, obj in ipairs(objects) do
        obj:setRotation(0, t*2, 0)
        local pos = objectPositions[i]
        local dir = objectDirs[i]
        obj:setTranslation(pos[1] + dir[1]/10, pos[2] + dir[2]/10, pos[3] + dir[3]/10)
    end
end

function window.draw()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    chamber:draw()
    for i, obj in ipairs(objects) do
        love.graphics.setColor(objectColors[i])
        obj:draw()
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Left click to make cubes! Right click to make spheres!\nWASD + Space + Shift to move around! Move the mouse to look around!\nEsc to exit! Fun fun fun!!!", 0, 0)
    love.graphics.print("You have made " .. #objects .. " objects", 0, 50)
end

return window
