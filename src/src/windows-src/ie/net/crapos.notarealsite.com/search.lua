local term

local index = {
    youtube = {"youtube.com/home"},
    google = {"google.com/home"},
    discord = {"discord.com/app"},
    twitter = {"twitter.com/home"},
    facebook = {"facebook.com/home"}
}

local page = {}

function page.load(arg)
    term = string.lower(arg)
    
    if not index[term] then
        goToPage("crapos.notarealsite.com/legit404page")
    end
end

function page.draw()
    text("Search results for \"" .. term .. "\"", 0, 0)
    for i, result in ipairs(index[term]) do
        button(result, function() goToPage(result) end, 5, i*50, 200, 40)
    end
end

return page
