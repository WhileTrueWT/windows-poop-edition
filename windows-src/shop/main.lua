local window = {}
window.title = "Shop"

function window.load()
    
end

function window.draw()
    text("Welcome to the Windows Poop Edition store!", 5, 5)
    text("APPS", 5, 30)
    for y=1,5 do
        button("ERROR", function() usersMoney = usersMoney - 999999999999 end, 5, 30 + y*50, 200, 40)
    end
    button("Cool Virus", function()
        messageBox("strings.shop.virusInstallFailure", "????????????????????????????????????????????????????????????", nil, "sounds/shutdown.wav")
    end, 5, 330, 200, 40)
end

return window