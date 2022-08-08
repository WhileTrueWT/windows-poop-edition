local window = {}
window.title = "Control Panel"
window.icon = "images/icons/controlpanel.png"

local screens = {}
local screen = "home"
local headerFont = love.graphics.newFont("fonts/DejaVuSans.ttf", 28)

screens.display = {
    title = "Display",
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
        end, 340, 5, 100, 30)
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
        button("Back", function() screen = "home" end, 5, 5, 100, 30)
        
        if screens[screen] then
            love.graphics.push("all")
            love.graphics.setFont(headerFont)
            text("Display", 5, 40)
            love.graphics.pop()
            
            love.graphics.push()
            love.graphics.translate(0, 70)
            
            screens[screen].draw()
            
            love.graphics.pop()
        end
    end
end

return window
