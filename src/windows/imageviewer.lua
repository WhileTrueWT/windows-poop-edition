local window = {}
window.title = "Image Viewer"
window.icon = "images/icons/picture.png"

local image
local f

function window.load(file)
    f = nil
    
    if not file then
        textInput("Type a filepath to open", function(text)
            f = text
            image = love.graphics.newImage(f)
        end)
    else
        f = file
        image = love.graphics.newImage(f)
    end
end

function window.draw()
    if image then
        local w = image:getWidth() <= windowWidth and 1 or windowWidth / image:getWidth()
        local h = image:getHeight() <= windowHeight and 1 or windowHeight / image:getHeight()
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(image, 0, 0, nil, w, h)
    end
end

return window
