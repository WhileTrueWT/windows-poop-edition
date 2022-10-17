-- /conf.lua and src/conf.lua should remain identical
-- ... well technically src/conf.lua does not absolutely need to exist i think
-- but this feels more complete okay

function love.conf(t)
    t.identity = "winpe4"
    t.version = "11.3"
    t.window.title = "Windows Poop Edition 5"
    t.window.icon = "icon.png"
    t.window.fullscreen = true
    t.window.width = 1280
    t.window.height = 720
    t.window.depth = 16
end
