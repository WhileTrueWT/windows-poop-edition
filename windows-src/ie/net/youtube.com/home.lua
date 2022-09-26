local videos = {}

local page = {}

function page.load()
    videos = {}
    for i, file in ipairs(love.filesystem.getDirectoryItems("_NOTHING/net/youtube.com/videos")) do
        local name = string.match(file, "([^%.]+)%.%w+")
        table.insert(videos, name)
    end
end

function page.draw()
    image("_NOTHING/net/youtube.com/youtube-legit.png", 5, 5, 200, 100)
    text("Welcome to YouTube", 5, 110)
    
    local x, y = 5, 120
    for i, name in ipairs(videos) do
        image("_NOTHING/net/youtube.com/thumbnails/" .. name .. ".png", x, y, 200, 180)
        button("", function()
            closeWindow()
            messageBox("youtube.com", "FATAL VIDEO PLAYER ERROR 7-B-69-420\nNo, we're not gonna fix this!", nil, "critical")
        end, x, y, 200, 200, {0, 0, 0, 0}, nil, false)
        text(name, x, y+180)
        x = x + 210
        if x+200 >= windowWidth then
            x = 5
            y = y + 210
        end
    end
end

return page
