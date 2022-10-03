local exepack = require "lib.exepack"

local window = {}
window.title = "Executable Packager"

local formatVersion = "0.0.0"
local magicNumber = string.char(132, 248)

local dir
local programName
local icon
local hasStarted = false

local function packageExe()
    hasStarted = true
    
    local out = exepack.package{dir = dir, name = programName, icon = icon}
    
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
        image((dir or "") .. icon, 5, 80, 30, 30)
    end
    button("Select", function()
        fileInput(function(path)
            icon = string.match(path, "^" .. string.gsub((dir or ""), "(%W)", "%%%1") .. "(.*)") or path
        end, dir)
    end, 240, 105, 100, 40)
    
    button("Package", function()
        packageExe()
    end, 5, 180, 160, 40)
end

return window
