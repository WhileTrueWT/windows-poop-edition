local screen = {}
local t

function screen.load()
    love.mouse.setVisible(false)
    t = 0
end

function screen.update(dt)
    t = t + dt
    if t >= 5 or love.keyboard.isDown("lshift") and love.keyboard.isDown("s") and love.keyboard.isDown("k") then
        sound("sounds/startup.wav")
        switchScreen("screens/desktop.lua")
    end
end

function screen.draw()
    local loadingCount = math.floor(t*8)%16 + 1
    image("images/logo.png", displayWidth/2 - 50, displayHeight/2 - 50, 100, 100)
    for x=1,loadingCount do
        rect((x-1)*12 + displayWidth / 2 - 96, displayHeight / 2 + 100, 10, 20, {0, 0.75, 0})
    end
    text("Version: " .. systemVersion, 0, 15, {1, 1, 1})
end

return screen
