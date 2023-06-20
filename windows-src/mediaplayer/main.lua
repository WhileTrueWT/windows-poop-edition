local window = {}
window.title = "Windows Media Player"
window.windowWidth = 340
window.windowHeight = 90

local f
local sound
local isVideo
local videoWidth
local videoHeight

local function decodeWPA(s)
	local sampleCount, sampleRate, bitDepth, channelCount, data = string.match(s, "^(%d+)%s(%d+)%s(%d+)%s(%d+)%s(.+)$")
	
	sampleCount = tonumber(sampleCount)
	if not sampleCount then
		return nil, "Invalid value for: sample count"
	end
	sampleRate = tonumber(sampleRate)
	if not sampleRate then
		return nil, "Invalid value for: sample rate"
	end
	bitDepth = tonumber(bitDepth)
	if not bitDepth then
		return nil, "Invalid value for: bit depth"
	end
	channelCount = tonumber(channelCount)
	if not channelCount then
		return nil, "Invalid value for: channel count"
	end
	
	if not data then
		return nil, "No sample data could be determined"
	end
	
	local soundData = love.sound.newSoundData(sampleCount, sampleRate, bitDepth, channelCount)
	
	local n, idx = 1
	for i = 0, sampleCount-1 do
		n, idx = love.data.unpack("n", data, idx)
		soundData:setSample(i, n)
	end
	
	return soundData
end

local function formatTime(seconds)
	return string.format("%d:%02d", math.floor(seconds/60), seconds%60)
end

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
			videoHeight = math.min(sound:getHeight(), displayHeight - 180)
			videoWidth = videoHeight * (sound:getWidth()/sound:getHeight())
			window.windowWidth = videoWidth + 20
			window.windowHeight = videoHeight + 120
		elseif string.match(string.lower(f), "%.wpa$") then
			isVideo = false
			window.windowWidth = 340
			window.windowHeight = 90
			
			local data, err = decodeWPA(love.filesystem.read(f))
			if not data then
				messageBox("Error", "Failed to decode .wpa file:\n" .. err, {{"OK", function()
					closeMessageBox()
					closeWindow()
				end}}, "sounds/critical.wav")
			end
			sound = love.audio.newSource(data)
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
		love.graphics.draw(sound, 5, 20, nil, videoWidth/sound:getWidth(), videoHeight/sound:getHeight())
		love.graphics.translate(0, videoHeight + 30)
	end
	text(formatTime(math.floor(sound:tell())), 0, 15)
	rect(50, 15, windowWidth-100, 15, {0, 0, 0})
	rect(50, 15, (windowWidth-100) * sound:tell() / dur, 15, {0, 0.75, 0})
	text(formatTime(math.floor(dur)), windowWidth-40, 15)
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
