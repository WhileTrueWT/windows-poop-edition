local window = {}
window.title = "Importer"
window.icon = "images/icons/download.png"
window.windowWidth = 340
window.windowHeight = 100

local filename, name

function window.load()
    filename = nil
end

function window.draw()
    text(filename and (filename .. "\nImported successfully as: user/" .. name) or "Drag and drop a file here from your host computer, and it will be imported into Windows Poop Edition.", 0, 0, nil, windowWidth)
end

function window.filedropped(file)
    filename = file:getFilename()
    file:open("r")
    local contents = file:read()
    name = string.match(filename, "[/\\]?([^/\\]+)$")
    local success, err = love.filesystem.write("user/" .. name, contents)
    if not success and err then
        messageBox("Error", err, {{"OK", function() closeMessageBox() end}})
        return
    end
end

return window
