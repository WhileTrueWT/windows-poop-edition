local page = {}

local sites = {
    {"youtube.com/home", "Youtube"},
    {"google.com/home", "Google"},
    {"discord.com/app", "Discord"},
    {"twitter.com/home", "Twitter"},
    {"facebook.com/home", "Facebook"}
}

function page.draw()
    text("Welcome to Internet Explorer!\nWe promise this browser will function properly!", 5, 5)
    text("Here are some of the places you can visit using the wonderful technologies of this browser.", 5, 40)
    
    local x, y = 5, 60
    for i, site in ipairs(sites) do
        button(site[2], function() goToPage(site[1]) end, x, y, 180, 30)
        x = x + 190
        if x+190 >= windowWidth then
            x = 5
            y = y + 40
        end
    end
end

return page
