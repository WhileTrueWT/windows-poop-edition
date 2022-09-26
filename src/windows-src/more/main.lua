local window = {}
window.title = "More Programs"

local function run()
    textInput("Enter name of program", function(text)
        if text == "all" then
            for _, w in ipairs(love.filesystem.getDirectoryItems("windows")) do
                openWindow("windows/" .. w)
            end
        else 
            openWindow("windows/" .. text .. ".exe") 
        end
    end)
end

local items = {
    {"Notepad", "images/icons/notepad.png", function() openWindow("windows/notepad.exe") end},
    {"Paint", "images/icons/paint.png", function() openWindow("windows/paint.exe") end},
    {"Importer", "images/icons/download.png", function() openWindow("windows/importer.exe") end},
    {"Run", "images/icons/run.png", function() run() end},
    {"Command Prompt", "images/icons/cmd.png", function() openWindow("windows/cmd.exe") end},
    {"Sound Recorder", "images/icons/soundrecorder.png", function() openWindow("windows/soundrecorder.exe") end},
    {"Calculator", "images/icons/calc.png", function() openWindow("windows/calc.exe") end},
    {"Visible Studio", "images/icons/visible-studio.png", function() openWindow("windows/visiblestudio.exe") end},
    {"UCanCode", "images/icons/code.png", function() openWindow("windows/ucancode.exe") end},
    {"Soundboard", "images/icons/soundboard.png", function() openWindow("windows/soundboard.exe") end},
}

function window.load()
end

function window.draw()
    local x, y = 5, 5
    for i, item in ipairs(items) do
        image(item[2], x, y, 40, 40)
        button("", item[3], x, y, 40, 40, {1, 1, 1, 0}, nil, false)
        text(item[1], x, y+40, nil, 80)
        x = x + 85
        if x+80 > windowWidth then
            x = 5
            y = y + 70
        end
    end
end

return window
