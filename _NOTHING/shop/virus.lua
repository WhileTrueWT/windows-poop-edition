local w = {}
w.windowX, w.windowY = 0, 0
w.windowWidth, w.windowHeight = 5, 5
w.hideWindowDec = true
w.title = "VIRUS"

function w.update()
    if love.math.random(1, 1000) == 1 then
        switchScreen("screens/crash.lua", "LOL")
    end
end

return w