local window = {}
window.title = "Executable Packager"

local dir
local programName
local icon
local hasStarted = false

local function packageExe()
    hasStarted = true
    
    local out = love.data.pack("string", "zz",
        programName,
        icon
    )
    
    local files = love.filesystem.getDirectoryItems(dir)
    
    for _, file in ipairs(files) do
        out = out .. love.data.pack("string", "s", file)
    end
    out = out .. "\0"
    
    for _, file in ipairs(files) do
        local data = love.filesystem.read(dir .. file)
        out = out .. love.data.pack("string", "s", data)
    end
    out = out .. "\0"
    
    save(nil, out, "exe", function(path)
        messageBox("Executable Packager", string.format("%s packaged successfully!", path))
    end)
    
    
end

function window.load(arg)
    hasStarted = false
    
    if arg then
        dir = arg
    end
end

function window.draw()
    text("Source directory: " .. (dir or ""), 5, 5)
    button("Select", function()
        dirInput(function(path)
            if not string.match(path, "/$") then
                path = path .. "/"
            end
            dir = path
        end)
    end, 240, 5, 100, 40)
    
    text("Program name: " .. (programName or ""), 5, 55)
    button("Select", function()
        textInput("Enter a (human-readable) name for this program", function(s)
            programName = s
        end)
    end, 240, 55, 100, 40)
    
    text("Icon: ", 5, 105)
    if icon then
        image(icon, 5, 80, 30, 30)
    end
    button("Select", function()
        fileInput(function(path)
            icon = path
        end, dir)
    end, 240, 105, 100, 40)
    
    button("Package", function()
        packageExe()
    end, 5, 180, 160, 40)
end

return window
