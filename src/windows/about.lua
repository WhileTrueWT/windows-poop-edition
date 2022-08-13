local aboutText = [[
This is a beta version of Windows Poop Edition 5.
]]

local window = {}
window.title = "About Windows"
window.icon = "images/icons/info.png"

function window.draw()
    image("images/logo.png", 5, 5, 100, 100)
    text("Windows Poop Edition 5\n" .. systemVersion, 5, 110)
    text("\"\"©\"\"2022 CrapOS", 5, 150)
    button("Get Help", function() messageBox("Help Error", "No.", nil, "critical") end, 5, 200, 100, 40)

    text(aboutText, 200, 5, nil, windowWidth-200)
end

return window