local window = {}
window.title = "Sound Recorder"
window.icon = "images/icons/soundrecorder.png"
window.windowWidth = 350
window.windowHeight = 110

local sampleRate = 8000     -- low quality ftw
local maxLength = 10        -- seconds

local device
local sound
local data

local function encodeSound()
    if not data then return end
    
    local s = ""
    
    s = s .. tostring(data:getSampleCount()) .. " "
    s = s .. tostring(data:getSampleRate()) .. " "
    s = s .. tostring(data:getBitDepth()) .. " "
    s = s .. tostring(data:getChannelCount()) .. " "
    
    for i = 0, data:getSampleCount() - 1 do
        s = s .. love.data.pack("string", "n", data:getSample(i))
    end
    
    return s
end

function window.load()
    sound = nil
    device = love.audio.getRecordingDevices()[1]
end

function window.draw()
    button(device:isRecording() and "Stop Recording" or "Start Recording", function()
        if device:isRecording() then
            data = device:getData()
            sound = love.audio.newSource(data)
            device:stop()
        else
            device:start(sampleRate * maxLength)
        end
    end, 5, 5, 120, 30)
    
    if sound then
        button(sound:isPlaying() and "Stop" or "Play", function()
            if sound:isPlaying() then
                sound:stop()
            else
                sound:play()
            end
        end, 130, 5, 80, 30)
        
        button("Save", function()
            save(nil, encodeSound(), "wpa")
        end, 220, 5, 80, 30)
        
        text(math.floor(sound:tell() * 100) / 100, 0, 40)
        rect(50, 40, 240, 15, {0, 0, 0})
        rect(50, 40, 240 * sound:tell() / sound:getDuration(), 15, {0, 0.75, 0})
        text(math.floor(sound:getDuration() * 100) / 100, 300, 40)
        
        button("Half Speed", function()
            local newdata = love.sound.newSoundData(
                data:getSampleCount() * 2,
                data:getSampleRate(),
                data:getBitDepth(),
                data:getChannelCount()
            )
            for i = 0, newdata:getSampleCount() - 1 do
                newdata:setSample(i, data:getSample(math.floor(i/2)))
            end
            
            data = newdata
            sound = love.audio.newSource(data)
        end, 5, 70, 120, 30)
        button("Double Speed", function()
            local newdata = love.sound.newSoundData(
                math.floor(data:getSampleCount() / 2),
                data:getSampleRate(),
                data:getBitDepth(),
                data:getChannelCount()
            )
            for i = 0, newdata:getSampleCount() - 1 do
                newdata:setSample(i, data:getSample(i*2))
            end
            
            data = newdata
            sound = love.audio.newSource(data)
        end, 130, 70, 120, 30)
    end
end

function window.close()
    device:stop()
end

return window
