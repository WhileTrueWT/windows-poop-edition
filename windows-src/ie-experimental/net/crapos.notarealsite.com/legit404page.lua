local page = {}

function page.draw()
	image("images/icons/ie.png", 5, 5, 50, 50)
	text("Whatever you just tried to find, it doesn't seem to exist.\nMaybe we just haven't looked hard enough, but we really couldn't care less about fixing this issue.", 5, 65)
	button("Try Again", function() closeWindow() messageBox("Imdernet eksplorerror", "IE has encountered a very bad error", nil, "critical") end, 5, 110, 100, 30)
end

return page