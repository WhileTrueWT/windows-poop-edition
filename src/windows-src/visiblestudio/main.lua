local utf8 = require "utf8"
local vurl = love.filesystem.load("lib/vurl.lua")()
local filegui = love.filesystem.load("lib/filegui.lua")()

local window = {}
window.title = "Visible Studio"
window.windowWidth = 1280
window.windowHeight = 720

local headerFont = love.graphics.newFont("fonts/DejaVuSans.ttf", 24)

local txt
local t
local t1
local f
local cursorPos
local preview
local dir = ""
local curLang
local projectName
local projectDir
local tabs
local curTab
local newProjectSelections

local mode = "main"

local textAreaWidth = 800
local textAreaHeight = windowHeight - 80

local langs = {}

langs.vurl = {
    ext = "vurl",
    
    defaultText = [[define load
    # when program loads
end

define update
    # when program state updates
end

define draw
    # when program draws to the screen
    text "Hello world!" 5 5
end]],

    run = function()
        openWindow("windows/vurl.lua", projectDir .. "main.vurl")
    end,
    
    drawPreview = function()
        vurl.setroot(projectDir or "/")
        local ok = pcall(vurl.run, txt)
        if not ok then
            return false
        end
        
        love.graphics.setCanvas(preview)
        love.graphics.clear()
        
        ok = pcall(vurl.callFunc, "draw")
        if not ok then
            love.graphics.setCanvas()
            return false
        end
        
        love.graphics.setCanvas()
        return true
    end
}

langs.lua = {
    ext = "lua",
    
    defaultText = [[local window = {}
window.title = "My Program"

function window.load()
    -- when program loads
end

function window.update()
    -- when program state updates
end

function window.draw()
    -- when program draws to the screen
    text("Hello world!", 5, 5)
end

return window]],
    
    run = function()
        openWindow(projectDir .. "main.lua")
    end,
    
    drawPreview = function()
        local ok, chunk = pcall(loadstring, txt)
        if not ok then
            return false
        end
        
        local ok, program = pcall(chunk)
        if not ok then
            return false
        end
        
        love.graphics.setCanvas(preview)
        love.graphics.clear()
        
        local ok = pcall(program and type(program) == "table" and program.draw or function() end)
        if not ok then
            love.graphics.setCanvas()
            return false
        end
        
        love.graphics.setCanvas()
        return true
    end
}

local langSelections = {
    {name = "Lua", id = "lua"},
    {name = "Vurl", id = "vurl"},
}

local metafileFormat = "zz"

local function drawPreview()
    if not (curLang and curLang.drawPreview) then return end
    
    local ok = curLang.drawPreview()
    if not ok then
        love.graphics.setCanvas()
        return false
    end
    
    love.graphics.setCanvas()
    return true
end

local function openFile(file)
    open(function(content, name)
        local ext = string.match(name, "%.(%w+)$") or ""
        
        local lang = {}
        for k, l in pairs(langs) do
            if l.ext == ext then
                lang = langs[k]
                break
            end
        end
        
        local check
        for _, tab in ipairs(tabs) do
            if tab.file == name then
                check = tab
                break
            end
        end
        
        if not check then
            table.insert(tabs, {
                txt = content,
                file = name,
                lang = lang,
                unsaved = false,
            })
            curTab = tabs[#tabs]
        else
            curTab = check
        end
        
        txt = curTab.txt
        f = curTab.file
        
        mode = "main"
    end, file)
end

local function openProject(file)
    dirInput(function(path)
        if not string.match(path, "/$") then
            path = path .. "/"
        end
        local s = love.filesystem.read(path .. ".vsproject")
        local lang
        projectName, lang = love.data.unpack(metafileFormat, s)
        curLang = langs[lang]
        
        projectDir = path
        filegui.initFileList(projectDir)
        window.title = "Visible Studio - " .. projectName
        mode = "main"
    end, "ProgramFiles/VisibleStudio/")
end

function window.load(file)
    txt = nil
    f = nil
    t = 0
    t1 = 1
    curLang = nil
    projectName = nil
    window.title = "Visible Studio"
    tabs = {}
    newProjectSelections = {}
    
    love.keyboard.setKeyRepeat(true)
    
    preview = love.graphics.newCanvas(800, 600)
    
    if file then
        openProject(file)
    else
        mode = "menu"
    end
    
    cursorPos = 0
end

function window.keypressed(key)
    t1 = 0
    
    if not curTab then return end
    
    if key == "backspace" then
        curTab.unsaved = true
        if cursorPos > 0 then
            local byteoffset = utf8.offset(txt, -1, cursorPos+1)
            if byteoffset then
                txt = (byteoffset > 1 and string.sub(txt, 1, byteoffset - 1) or "") .. (byteoffset < #txt and string.sub(txt, byteoffset+1) or "")
                cursorPos = cursorPos - 1
            end
        end
    end
    
    if key == "return" then
        curTab.unsaved = true
        txt = (cursorPos >= 1 and string.sub(txt, 1, cursorPos) or "") .. "\n" .. (cursorPos < #txt and string.sub(txt, cursorPos+1) or "")
        cursorPos = cursorPos + 1
    end
    
    if key == "left" then
        if cursorPos > 0 then cursorPos = cursorPos - 1 end
    end
    
    if key == "right" then
        if cursorPos < #txt then cursorPos = cursorPos + 1 end
    end
    
    if key == "up" then
        repeat
            if cursorPos <= 1 then break end
            cursorPos = cursorPos - 1
        until string.sub(txt, cursorPos, cursorPos) == "\n"
        if cursorPos > 0 then cursorPos = cursorPos - 1 end
    end
    
    if key == "down" then
        for i=1,2 do
            repeat
                if cursorPos > #txt then break end
                cursorPos = cursorPos + 1
            until string.sub(txt, cursorPos, cursorPos) == "\n"
        end
        cursorPos = cursorPos - 1
    end
    
    if key == "tab" then
        curTab.unsaved = true
        for i=1,4 do
            window.textinput(" ")
        end
    end
    
    curTab.txt = txt
end

function window.textinput(text)
    if not curTab then return end
    
    curTab.unsaved = true
    
    txt = (cursorPos >= 1 and string.sub(txt, 1, cursorPos) or "") .. text .. (cursorPos < #txt and string.sub(txt, cursorPos+1) or "")
    cursorPos = cursorPos + 1
    
    curTab.txt = txt
end

function window.update(dt)
    t = t + dt
    t1 = t1 + dt
    
    if mode == "main" and t1 >= 0.5 then
        t1 = 0
        local ok = drawPreview()
        if not ok then
            text("Error", 0, 0)
        end
    end
end

function window.draw()
    setFont("fonts/DejaVuSans.ttf")
    
    if mode == "main" then
        rect(0, 0, textAreaWidth, windowHeight, {1, 1, 1})
        outline(0, 0, textAreaWidth, textAreaHeight)
        
        rect(0, 0, windowWidth, 30, {0.75, 0.75, 0.75})
        
        local ex = 0
        button("New", function() messageBox("Visible Studio", "Save changes?", {{"Yes", function()
            save(f, txt, curLang.ext, function(name)
                closeMessageBox()
                window.load()
            end)
        end}, {"No", function()
            closeMessageBox()
            window.load()
        end}, {"Cancel", function() closeMessageBox() end}}) end, ex, 0, 60, 30)
        ex = ex + 60
        button("Open", openProject, ex, 0, 60, 30)
        ex = ex + 60
        button("Save", function()
            if not curTab then return end
            
            save(f, txt, curLang.ext, function(name)
                f = name
                curTab.unsaved = false
            end)
        end, ex, 0, 60, 30)
        ex = ex + 60
        button("Run", function()
            curLang.run()
        end, ex, 0, 60, 30)
        ex = ex + 60
        button("Help", function()
            messageBox("Visible Studio", "Under construction")
        end, ex, 0, 60, 30)
        
        rect(0, 30, textAreaWidth, 30, {0.7, 0.7, 0.7})
        local bx = 0
        for i, tab in ipairs(tabs) do
            local label = string.match(tab.file, "/?([^/]+)$") or ""
            if tab.unsaved then
                label = "*" .. label
            end
            
            local width = love.graphics.getFont():getWidth(label) + 60
            
            rect(bx, 30, width + 20, 30,
            curTab == tab and {0.6, 0.6, 0.6, 1} or {0.5, 0.5, 0.5, 1})
            
            button(label, function()
                openFile(tab.file)
            end, bx, 30, width, 30, {0, 0, 0, 0}, nil, false)
            
            button("X", function()
                local function close()
                    table.remove(tabs, i)
                    curTab = (i > 1) and tabs[i-1] or (#tabs > 0) and i+1 or nil
                end
                
                messageBox("Visible Studio", "Save changes to this file?", {
                    {"Yes", function()
                        closeMessageBox()
                        save(tab.file, tab.txt, nil, function()
                            close()
                        end)
                    end},
                    {"No", function()
                        closeMessageBox()
                        close()
                    end},
                    {"Cancel", function()
                        closeMessageBox()
                    end}
                })
                
            end, bx+width, 30, 20, 20, {0.8, 0, 0, 1}, {1, 1, 1, 1})
            
            bx = bx + width + 20
        end
        
        if curTab then
            setFont("fonts/DejaVuSansMono.ttf")
            
            local textCursor = " "
            if math.floor(t*3) % 2 == 0 then
                textCursor = "_"
            end
            
            local f = love.graphics.getFont()
            local _, lines = f:getWrap(string.sub(txt, 1, cursorPos), windowWidth)
            local pos = #lines <= math.floor((windowHeight/2 - 60) / f:getHeight()) and 0 or 0 - #lines * f:getHeight() + (windowHeight/2 - 60)
            
            love.graphics.setScissor(windowX, windowY + 60, textAreaWidth, textAreaHeight - 60)
            
            text((cursorPos >= 1 and string.sub(txt, 1, cursorPos) or "") .. textCursor .. string.sub(txt, cursorPos+1), 0, 60 + pos, nil, textAreaWidth)
            
            love.graphics.setScissor()
            
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setScissor(windowX + textAreaWidth, windowY + 30, windowWidth-textAreaWidth, textAreaHeight-30)
            love.graphics.draw(preview, textAreaWidth, 30)
            
            love.graphics.setScissor()
            setFont("fonts/DejaVuSans.ttf")
        elseif #tabs == 0 then
            text("Select a file below to open it!", 5, 60)
        end
        
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.line(0, textAreaHeight, textAreaWidth, textAreaHeight)
        love.graphics.setColor(1, 1, 1, 1)
        
        button("New File", function()
            textInput("Enter file name", function(s)
                love.filesystem.write(projectDir .. s, "")
                openFile(projectDir .. s)
            end)
        end, 5, textAreaHeight+5, 120, 30)
        
        filegui.drawFileList(0, textAreaHeight+40, window.windowWidth, window.windowHeight - textAreaHeight - 40, nil, {
            onFileOpen = function(f)
                openFile(f)
            end
        })
    
    elseif mode == "menu" then
        
        love.graphics.setFont(headerFont)
        text("Welcome to Visible Studio", 5, 5)
        setFont("fonts/DejaVuSans.ttf")
        text("The barely-usable development environment for Windows Poop Edition applications", 5, 30)
        
        button("New Project", function()
            mode = "new"
        end, 5, 60, 180, 40)
        
        button("Open Existing Project", function()
            openProject()
        end, 5, 110, 180, 40)
    
    elseif mode == "new" then
        love.graphics.setFont(headerFont)
        text("Create a new project", 5, 5)
        setFont("fonts/DejaVuSans.ttf")
        
        text("Project Name: " .. (newProjectSelections.name or ""), 5, 35)
        button("Change", function()
            textInput("Enter project name", function(s)
                newProjectSelections.name = s
            end)
        end, 240, 35, 140, 40)
        
        text("Language:", 5, 65)
        local x, y = 5, 90
        for _, lang in ipairs(langSelections) do
            button(lang.name, function()
                newProjectSelections.lang = lang.id
            end, x, y, 140, 40)
            
            if newProjectSelections.lang == lang.id then
                outline(x, y, 140, 40, {0, 1, 1, 1})
            end
            
            x = x + 150
            if x+150 >= windowWidth then
                x = 5
                y = y + 50
            end
        end
        y = y + 80
        
        button("Create", function()
            if not newProjectSelections.name or #newProjectSelections.name == 0 then
                messageBox("Visible Studio", "Please select a name for this project.", nil, "exc")
                return
            end
            
            projectName = newProjectSelections.name
            projectDir = "ProgramFiles/VisibleStudio/" .. projectName .. "/"
            
            if love.filesystem.getInfo(projectDir, "directory") then
                messageBox("Visible Studio", string.format("There is already another project with the name '%s'. Please choose a different name.", projectName))
                return
            end
            
            if not newProjectSelections.lang then
                messageBox("Visible Studio", "Please select a language to use.", nil, "exc")
                return
            end
            
            curLang = langs[newProjectSelections.lang]
            
            love.filesystem.createDirectory(projectDir)
            
            love.filesystem.write(projectDir .. ".vsproject", love.data.pack("string", metafileFormat,
                projectName,
                newProjectSelections.lang
            ))
            
            local fname = projectDir .. "main." .. curLang.ext
            love.filesystem.write(fname, curLang.defaultText or "")
            openFile(fname)
            
            filegui.initFileList(projectDir)
            window.title = "Visible Studio - " .. projectName
            mode = "main"
        end, 5, y, 120, 40)
    end
end

function window.close()
    if mode ~= "main" then return end
    
    local unsavedFiles = 0
    for _, tab in ipairs(tabs) do
        if tab.unsaved then
            unsavedFiles = unsavedFiles + 1
        end
    end
    
    if unsavedFiles > 0 then
        messageBox("Visible Studio", string.format("There are %d files with unsaved changes. Would you like to save all of these files?", unsavedFiles), {
            {"Yes", function()
                closeMessageBox()
                for _, tab in ipairs(tabs) do
                    if tab.unsaved then
                        save(tab.file, tab.txt, nil, function()
                            love.keyboard.setKeyRepeat(false)
                            closeWindow(nil, true)
                        end)
                    end
                end
            end},
            {"No", function()
                love.keyboard.setKeyRepeat(false)
                closeWindow(nil, true)
            end},
            {"Cancel", function()
                closeMessageBox()
            end},
        })
        return true
    end
end

return window
