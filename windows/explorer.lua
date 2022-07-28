local window = {}
window.title = "Explorer"
window.icon = "images/icons/explorer.png"

local filegui = love.filesystem.load("lib/filegui.lua")()

local cdir
local filelist

local function refresh()
    filegui.initFileList(cdir)
end

local function cd(dir)
    if dir == ".." then
        cdir = string.match(cdir, "(/?.+/).+/$") or "/"
    else
        cdir = dir .. "/"
    end
    refresh()
end

local function operationError(msg)
    msg = msg or ""
    messageBox("Explorer", "Operation failed.\n" .. msg, nil, "critical")
end

local function selectFile(i)
    filelist[i].selected = not filelist[i].selected
end

function window.load(arg)
    filelist = {}
    filegui.cd = cd
    filegui.selectFile = selectFile
    cdir = arg or "/user"
    cd(cdir)
end

function window.draw()
    text(cdir, 5, 5)
    button("Up", function() cd("..") end, 5, 20, 60, 30)
    
    filegui.drawFileList(5, 60, windowWidth, windowHeight)
end

return window
