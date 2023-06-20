local page = {}

function page.load()
	
end

function page.draw()
	image("_NOTHING/net/twitter.com/twitter.png", 0, 0, 300, windowHeight)
	text("Welcome to Twitter. Here, you can be a bird and tweet at other birds. Sacrifice your soul and mental well-being for the profit of some rich people. Come on, you know you want to.", 310, 10, nil, windowWidth-310)
	button("Sign In", function() closeWindow() messageBox("Internet Explorer", "Internet Explorer has automatically exited twitter.com to protect your mental health and sanity. You're welcome.", nil, "critical") end, 310, 80, 180, 30)
	
	love.graphics.push()
	love.graphics.translate(310, 120)
	love.graphics.scale(2)
	text("NOW OWNED BY THIS ASSHOLE!", 0, 0, nil, (windowWidth-310)/2)
	love.graphics.pop()
	image("_NOTHING/net/twitter.com/musk.png", 310, 180, 240, 90)
end

return page
