local window = {}
window.title = "Windows Media Player"
window.icon = "images/icons/speaker.png"
window.windowWidth = 340
window.windowHeight = 90

local sound
local isVideo

function window.load(file)
    f = nil
    
    if not file then
        messageBox("Error", "Error", {{"OK", function()
            closeMessageBox()
            closeWindow()
        end}}, "sounds/critical.wav")
    else
        f = file
        if string.match(string.lower(f), "%.ogg$") then
            isVideo = true
            sound = love.graphics.newVideo(f)
            window.windowWidth = sound:getWidth() + 20
            window.windowHeight = sound:getHeight() + 120
        else
            isVideo = false
            window.windowWidth = 340
            window.windowHeight = 90
            sound = love.audio.newSource(f, "stream")
        end
    end
    
    if sound then sound:play() end
end

function window.draw()
    if not f then return end
    text("Now playing: " .. f, 0, 0)
    
    local dur = (isVideo and (sound:getSource():getDuration() or 100) or sound:getDuration())
    if isVideo then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sound, 5, 20)
        love.graphics.translate(0, sound:getHeight() + 30)
    end
    text(math.floor(sound:tell()), 0, 15)
    rect(50, 15, windowWidth-100, 15, {0, 0, 0})
    rect(50, 15, (windowWidth-100) * sound:tell() / dur, 15, {0, 0.75, 0})
    text(math.floor(dur), windowWidth-40, 15)
    button("<<", function() sound:seek(sound:tell() >= 5 and sound:tell() - 5 or 0) end, 5, 40, 50, 40)
    button(sound:isPlaying() and "Pause" or "Play", function() if sound:isPlaying() then sound:pause() else sound:play() end end, 65, 40, 50, 40)
    button(">>", function()
        sound:seek(sound:tell() + 5 <= dur and sound:tell() + 5 or dur)
        if isVideo and sound:tell() >= dur then
            sound:pause()
            sound:rewind()
        end
    end, 125, 40, 50, 40)
    
    love.graphics.origin()
end

function window.close()
    if sound then
        if isVideo then
            sound:pause()
        else
            sound:stop()
        end
    end
end

return window
