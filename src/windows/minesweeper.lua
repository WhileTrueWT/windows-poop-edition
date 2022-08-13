local window = {}
window.title = "Minesweeper"
window.icon = "images/icons/explode.png"
window.windowWidth = 400
window.windowHeight = 400

function window.load()
end

function window.draw()
    for x=0,20 do
        for y=0,20 do
            local c = (x%2 ~= y%2) and {0.6, 0.6, 0.6} or {0.4, 0.4, 0.4}
            rect(x*20, y*20, 20, 20, c)
        end
    end
end

function window.mousepressed()
    closeWindow()
    messageBox("Minesweeper", "BOOM", nil, "critical")
end

return window
