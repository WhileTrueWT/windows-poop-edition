local video
local videolist

local function play(v)
    video = love.graphics.newVideo(v)
    love.audio.stop()
    video:play()
end

local window = {}
window.title = "Videos"
window.icon = "images/icons/video2.png"

function window.load(file)
    video = nil
    videolist = {}
    for i, v in ipairs(love.filesystem.getDirectoryItems("Videos")) do
        table.insert(videolist, v)
    end
    if file then
        play(file)
    end
end

function window.draw()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, windowWidth-180, windowHeight)
    if video then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(video, 0, 0, nil, (windowWidth-180)/video:getWidth(), (windowWidth-180)/video:getWidth())
    end
    for i, v in ipairs(videolist) do
        button(v, function() play("Videos/" .. v) end, windowWidth-180, (i-1)*30+5, 180, 30)
    end
end

function window.close()
    love.audio.stop()
end

return window
