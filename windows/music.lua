local window = {}
window.title = "Music"
window.icon = "images/icons/music.png"

function window.load()
end

function window.draw()
    local x, y = 5, 5
    for i, file in ipairs(love.filesystem.getDirectoryItems("Music")) do
        local ext = string.match(file, "%.(%w+)$")
        if ext and ext == "mp3" or ext == "wav" then
            image("images/icons/sound.png", x, y, 40, 40)
            button("", function() openWindow("windows/mediaplayer.lua", "Music/" .. file) end, x, y, 40, 40, {1, 1, 1, 0}, nil, false)
            text(file, x, y+40, nil, 80)
            x = x + 85
            if x+80 > windowWidth then
                x = 5
                y = y + 70
            end
        end
    end
end

return window