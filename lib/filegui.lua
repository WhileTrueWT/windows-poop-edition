local m = {}

local filelist = {}
local cdir
local tooltip
local scrollY = 0

local function operationError(msg)
    msg = msg or ""
    messageBox("Explorer", "Operation failed.\n" .. msg, nil, "critical")
end

local function refresh()
    filelist = {}
    
    for i, file in ipairs(love.filesystem.getDirectoryItems(cdir)) do
        if file ~= "_NOTHING" then
            table.insert(filelist, {name=file, info=love.filesystem.getInfo(cdir .. file), selected=false})
        end
    end
end

local tooltipOptions = {
    {"Open in...", function(file)
        open(function(_, path)
            openWindow(path, cdir .. file)
        end, nil, "windows/")
    end},
    {"Make shortcut", function(file)
        local name = string.match(file, "([^/]+)%.?$")
        local success, err = love.filesystem.write("/user/Desktop/" .. name .. ".lnk", cdir .. file)
        if not success and err then
            operationError(err)
            return
        end
    end},
    {"New folder", function()
        textInput("Enter folder name", function(text)
            local success = love.filesystem.createDirectory(cdir .. text)
            if not success then
                operationError()
            end
            refresh()
        end)
    end, global=true},
    {"Get info", function(file)
        local info = love.filesystem.getInfo(cdir .. file)
        if not info then messageBox("Explorer", "File does not exist.", nil, "critical") return end
        messageBox("Explorer", "Type: " .. info.type .. "\nSize: " .. (info.size and tostring(info.size) .. " bytes" or "unknown") .. "\n" .. "Last modified: " .. (info.modtime and os.date("%b %d %Y at %I:%M %p", info.modtime) or "unknown"))
    end},
    {"Rename", function(file)
        textInput("Enter new name", function(text)
            local src, dest = file, text
            
            local info = love.filesystem.getInfo(cdir .. src)
            if info.type == "file" then
                local success, err = love.filesystem.write(cdir .. dest, love.filesystem.read(cdir .. src))
                if not success and err then
                    operationError(err)
                    return
                end

                local success = love.filesystem.remove(cdir .. src)
                if not success then
                    operationError()
                end
            elseif info.type == "directory" then
                local success = love.filesystem.createDirectory(cdir .. dest)
                if not success then
                    operationError()
                    return
                end
                
                local success = love.filesystem.remove(cdir .. src)
                if not success then
                    operationError()
                end
            end
            
            refresh()
        end)
    end},
    {"Copy", function(file)
        local info = love.filesystem.getInfo(cdir .. file)
        if info.type == "file" then
            copy("file", cdir .. file)
        elseif info.type == "directory" then
            copy("dir", cdir .. file)
        end
    end},
    {"Paste", function(file)
        local clipboard = paste()
        if clipboard[1] == "file" then
            local name = string.match(clipboard[2], "([^/]+)%.?$")
            local ext = string.match(clipboard[2], "(%.%w+)$") or ""
            local newName
            local n = 1
            repeat
                newName = name .. ' (' .. tostring(n) .. ')' .. ext
                n = n + 1
            until not love.filesystem.getInfo(cdir .. newName)
            
            local src, dest = clipboard[2], cdir .. newName
            local data, err = love.filesystem.read(src)
            if not data and err then
                operationError(err)
                return
            end
            
            local success, err = love.filesystem.write(dest, data)
            if not success and err then
                operationError(err)
                return
            end
        elseif clipboard[1] == "dir" then
            local name = string.match(clipboard[2], "([^/]+)$")
            local newName
            local n = 1
            repeat
                newName = name .. ' (' .. tostring(n) .. ')'
                n = n + 1
            until not love.filesystem.getInfo(cdir .. newName)
            
            local src, dest = clipboard[2], cdir .. newName
            local success = love.filesystem.createDirectory(dest)
            if not success then
                operationError()
                return
            end
        end
        refresh()
    end, global=true},
    {"Delete", function(file)
        messageBox("Explorer", "You are about to delete '" .. file .. "'. Are you sure?", {{"Yes", function()
            local success = love.filesystem.remove(cdir .. file)
            if not success then
                operationError()
            end
            closeMessageBox()
            refresh()
        end}, {"No", function() closeMessageBox() end}})
    end}
}

m.textShadow = false
m.cd = function() end
m.selectFile = function() end

local function selectFile(i)
    tooltip = i
end

local function openFile(file)
    local ext = string.match(file, "%.(%w+)$") or ""
    local dir = string.match(file, "(.*/).*$") or ""
    if ext == "txt" then
        openWindow("windows/notepad.lua", file)
    elseif ext == "png" or ext == "jpg" then
        openWindow("windows/imageviewer.lua", file)
    elseif ext == "mp3" or ext == "wav" then
        openWindow("windows/mediaplayer.lua", file)
    elseif ext == "ogg" then
        openWindow("windows/mediaplayer.lua", file)
    elseif ext == "ucc" then
        openWindow("windows/ucancode.lua", file)
    elseif ext == "bf" then
        openWindow("windows/bf.lua", file)
    elseif ext == "lua" then
        if dir ~= "/windows/" then
            messageBox("Explorer", "WARNING: You are attempting to open a non-authorized program file. Doing this may have strange and/or damaging results. Are you sure?", {{"Yes", function() openWindow(file) end}, {"No", function() closeMessageBox() end}}, "exc")
        else
            openWindow(file)
        end
    elseif ext == "vurl" then
        openWindow("windows/vurl.lua", file)
    elseif ext == "lnk" then
        local data = love.filesystem.read(file)
        openFile(data)
    elseif ext == "wpa" then
        openWindow("windows/mediaplayer.lua", file)
    else
        messageBox("Explorer", "Explorer does not know how to open '" .. ext .. "' files", nil, "exc")
    end
end

function m.initFileList(dir)
    if dir == ".." then
        cdir = string.match(cdir, "(/?.+/).+/$") or "/"
    else
        cdir = dir
        if not string.match(cdir, "/$") then
            cdir = cdir .. "/"
        end
    end
    refresh()
    scrollY = 0
end

function m.drawFileList(xpos, ypos, w, h, cc, param)
    if cc == nil then cc = true end
    param = param or {}
    param.onFileOpen = param.onFileOpen or openFile
    local x, y = xpos, ypos
    
    local sx, sy = love.graphics.transformPoint(xpos, ypos)
    love.graphics.setScissor(sx, sy, w, h)
    
    if cc and (#filelist == 0 and not tooltip) then
        button("", {function()
            if love.mouse.isDown(2) then
                tooltip = "g"
            end
        end, any=true}, x, y, w, h, {1, 1, 1, 0}, nil, false)
    end
    
    love.graphics.push()
    love.graphics.translate(0, scrollY)
    
    for i, file in ipairs(filelist) do
        if file.info then
            if file.info.type == "directory" then
                image("images/icons/folder.png", x, y, 40, 40)
            elseif file.info.type == "file" then
                local ext = string.match(file.name, "%.(%w+)$")
                local icon
                if ext == "png" or ext == "jpg" then
                    icon = "images/icons/picture.png"
                elseif ext == "wav" or ext == "mp3" or ext == "wpa" then
                    icon = "images/icons/sound.png"
                elseif ext == "txt" then
                    icon = "images/icons/text.png"
                elseif ext == "ogg" then
                    icon = "images/icons/video.png"
                elseif ext == "ucc" then
                    icon = "images/icons/code.png"
                elseif ext == "bf" then
                    icon = "images/icons/brainflip.png"
                elseif ext == "lua" then
                    icon = "images/icons/app.png"
                elseif ext == "vurl" then
                    icon = "images/icons/vurl.png"
                else
                    icon = "images/icons/file.png"
                end
                image(icon, x, y, 40, 40)
            end
        end
        if cc then
            button("", {function()
                    if tooltip then
                        tooltip = nil
                        return
                    end
                    if file.info then
                        if love.mouse.isDown(2) then
                            selectFile(i)
                        elseif file.info.type == "file" then
                            param.onFileOpen(cdir .. file.name)
                        elseif file.info.type == "directory" then
                            m.cd(cdir .. file.name)
                        end
                    end
            end, any=true}, x, y, 40, 40, {1, 1, 1, 0}, nil, false)
        end
        if file.selected then
            rect(x, y, 40, 40, {0, 0.8, 1, 0.5})
        end
        if m.textShadow then
            love.graphics.push()
            love.graphics.translate(-1, 1)
            text(file.name, x, y+40, {0, 0, 0, 1}, 80)
            love.graphics.pop()
            text(file.name, x, y+40, {1, 1, 1, 1}, 80)
        else
            text(file.name, x, y+40, nil, 80)
        end
        
        x = x + 85
        if x >= xpos+w - 80 then
            x = xpos
            y = y + 70
        end
    end
    
    love.graphics.pop()
    love.graphics.setScissor()
    
    x, y = xpos, ypos
    if tooltip == "g" then
        local i = 1
        for _, option in ipairs(tooltipOptions) do
            if option.global then
                button(option[1], function()
                    tooltip = nil
                    option[2]()
                end, x+40, y + i*20, 120, 20, {1, 1, 1, 1})
                i = i + 1
            end
        end
    else
        for i, file in ipairs(filelist) do
            if tooltip and i == tooltip then
                for i, option in ipairs(tooltipOptions) do
                    button(option[1], function()
                        tooltip = nil
                        option[2](file.name)
                    end, x+40, y + i*20, 120, 20, {1, 1, 1, 1})
                end
            end
            x = x + 85
            if x >= w - 80 then
                x = xpos
                y = y + 70
            end
        end
    end
end

function m.wheelmoved(x, y)
    scrollY = scrollY + y*30
end

return m