local page = {}
local t, interval
local users = {}

local function User(name)
    local u = {}
    
    u.name = name or "User"
    
    return u
end

local function Message(text, author)
    local m = {}
    
    m.text = text or ""
    m.author = author or User()
    
    return m
end

local function Channel(name)
    local c = {}
    
    c.name = name or "general"
    c.messages = {}
    
    return c
end

local function generateUser()
    local nouns = {"Person", "Goat", "Poop", "Dog", "Cat", "Moose", "Human", "Computer", "Keyboard"}
    local adjs = {"Cool", "Awesome", "Good", "Bad", "Terrible", "Poopy", "Awful", "Amazing", "AmazinglyAwful", "AwfullyAmazing", "Evil"}
    local name = adjs[love.math.random(1, #adjs)] .. nouns[love.math.random(1, #nouns)] .. tostring(love.math.random(0, 9999))
    return User(name)
end

local function generateMessage()
    local text = ""
    local length = love.math.random(4, 30)
    for i=1,length do
        local r = love.math.random(1, 29)
        text = text .. string.sub("abcdefghijklmnopqrstuvwxyz ,.", r, r)
    end
    
    local author = users[love.math.random(1, #users)]
    
    return Message(text, author)
end

local channels = {
    Channel("general"),
    Channel("general-2"),
    Channel("windows-pe-help"),
}
local currentChannel

local tc = {1, 1, 1, 1}
local me = User("YourMom")

function page.load()
    t = 0
    interval = love.math.random(0.5, 5)
    currentChannel = 1
    
    users = {}
    for i=1,6 do
        table.insert(users, generateUser())
    end
end

function page.update(dt)
    t = t + dt
    if t >= interval then
        table.insert(channels[currentChannel].messages, generateMessage())
        t = 0
        interval = love.math.random(0.5, 5)
    end
end

function page.draw()
    rect(0, 0, windowWidth, windowHeight, {32/255, 34/255, 37/255})
    
    text("Windows Poop Edition", 5, 5, tc)
    for i, channel in ipairs(channels) do
        button("#" .. channel.name, function() currentChannel = i end, 5, 30+(i-1)*40, 140, 30)
    end
    
    local x, y = 180, windowHeight-90 - #channels[currentChannel].messages * 30
    for i, message in ipairs(channels[currentChannel].messages) do
        text(message.author.name .. ": " .. message.text, x, y, tc)
        y = y + 30
    end
    
    rect(180, windowHeight-80, 500, 30, {79/255, 84/255, 92/255, 1})
    text("Message #" .. channels[currentChannel].name, 190, windowHeight-70, {0.8, 0.8, 0.8, 1})
    button("", function()
        textInput("Enter your message", function(text)
            table.insert(channels[currentChannel].messages, Message(text, me))
        end)
    end, 180, windowHeight-80, 500, 30, {0, 0, 0, 0}, nil, false)
end

return page
