local window = {}
window.title = "Sound Recorder"
window.windowWidth = 350
window.windowHeight = 60

local device
local sound

function window.load()
    sound = nil
    device = love.audio.getRecordingDevices()[1]
end

function window.draw()
    button(device:isRecording() and "Stop Recording" or "Start Recording", function() if device:isRecording() then sound = love.audio.newSource(device:getData()) device:stop() else device:start(80000) end end, 5, 5, 120, 30)
    
    if sound then
        button(sound:isPlaying() and "Stop" or "Play", function() if sound:isPlaying() then sound:stop() else sound:play() end end, 130, 5, 80, 30)
        text(math.floor(sound:tell() * 100) / 100, 0, 40)
        rect(50, 40, 240, 15, {0, 0, 0})
        rect(50, 40, 240 * sound:tell() / sound:getDuration(), 15, {0, 0.75, 0})
        text(math.floor(sound:getDuration() * 100) / 100, 300, 40)
    end
end

function window.close()
    device:stop()
end

return window
