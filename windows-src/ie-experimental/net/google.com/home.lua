local page = {}

local size

function page.load()
	size = 1
end

function page.draw()
	image("_NOTHING/net/google.com/logo.png", windowWidth/2-100, 60, 200*size, 90*size)
	rect(windowWidth/2-140, 160, 280, 20, {1, 1, 1, 1})
	outline(windowWidth/2-140, 160, 280, 20)
	button("Search", function() size = size * 1.1 end, windowWidth/2 - 140, 190, 130, 30)
	button("I Have Feelings", function() size = size / 1.1 end, windowWidth/2 + 10, 190, 130, 30)
	
	text("It looks like you are using a browser that isn't ours. Try Chrome Today!", 10, windowHeight-60)
	button("Try Chrome", function() closeWindow() messageBox("Epic Fail", "It looks like you tried to install a browser that isn't ours.", nil, "critical") end, 550, windowHeight-70, 100, 30)
end

return page
