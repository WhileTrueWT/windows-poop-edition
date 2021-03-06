local screen = {}

local filegui = love.filesystem.load("lib/filegui.lua")()

local taskbarHeight = 40
local t
local t1

local notif

function notify(s, onclick)
    s = s or ""
    onclick = onclick or function() end
    notif = {text=s, onclick=onclick}
    sound("sounds/notify.wav")
end

function screen.load()
    love.mouse.setVisible(true)
    
    filegui.textShadow = true
    filegui.cd = function(path) openWindow("windows/explorer.lua", path) end
    filegui.initFileList("/user/Desktop")
    
    t = 0
    t1 = 0
end

function screen.update(dt)
    t = t + dt
    t1 = t1 + dt
    
    if t1 >= 2 then
        filegui.initFileList("/user/Desktop")
        t1 = 0
    end
end

function screen.draw()
    local f = love.graphics.getFont()
    
    image(settings.background, 0, 0, displayWidth, displayHeight)
    filegui.drawFileList(10, 10, displayWidth, displayHeight-50, not (isWindowOpen() or isMessageBoxShowing() or isTextInputShowing()))
    image("images/gradient.png", 0, displayHeight-taskbarHeight, displayWidth, taskbarHeight, settings.themeColor)
    
    button("", function() openWindow("windows/startmenu.lua") end, 0, displayHeight-taskbarHeight, 40, taskbarHeight, "images/logo.png", nil, false)
    
    local ex = 50
    for _, w in ipairs(openWindows) do
        if w ~= "windows/startmenu.lua" then
            local title = windows[w].title or ""
            local width = math.max(f:getWidth(title) + 50, 180)
            button(title, function() openWindow(w) end, ex, displayHeight-40, width, 40, nil, {1, 1, 1, 1}, nil, {0.4, 0.6, 1})
            image(windows[w].icon or "images/icons/app.png", ex+5, displayHeight-30, 20, 20)
            ex = ex + width
        end
    end
   
    local ct, cd = os.date("%I:%M %p"), os.date("%b %d %Y")
    text(ct, displayWidth - f:getWidth(ct) - 20, displayHeight - 20 - f:getHeight() / 2 - 8, {1, 1, 1})
    text(cd, displayWidth - f:getWidth(cd) - 20, displayHeight - 20 - f:getHeight() / 2 + 8, {1, 1, 1})
    
    button("", function() hideWindow() end, displayWidth - 10, displayHeight-taskbarHeight, 10, taskbarHeight, nil, nil, false, {0.4, 0.6, 1})
    if notif then
        local w, h = 280, 100
        rect(displayWidth-w-10, displayHeight-taskbarHeight-h-10, w, h, {1, 1, 1, 1})
        text(notif.text, displayWidth-w, displayHeight-taskbarHeight-h, nil, w-10)
        
        button("", function() notif.onclick() notif = nil end, displayWidth-w-10, displayHeight-taskbarHeight-h-10, w, h, {1, 1, 1, 0})
    end
end

return screen
