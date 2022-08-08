local window = {}
window.title = "Control Panel"
window.icon = "images/icons/controlpanel.png"

local screens = {}
local screen = "home"

screens.display = {
    draw = function()
        text("Background: " .. tostring(settings.background), 5, 5)
        
        button("Change", function()
            open(function(_, path)
                local ok, msg = pcall(love.image.newImageData, path)
                if not ok then
                    messageBox(window.title,
                    string.format("%s is not an image file or does not use a recognizable image format.\n\n%s", path, msg),
                    nil, "exc")
                    return
                end
                
                settings.background = path
            end)
        end, 5, 20, 100, 30)
    end
}

function window.load()
    screen = "home"
end

function window.update(dt)
end

function window.draw()
    if screen == "home" then
        text("Choose an item:", 5, 5)
        
        button("Display", function() screen = "display" end, 5, 30, 160, 30)
    else
        screens[screen].draw()
    end
end

return window
