love.filesystem.setCRequirePath("lib/?.so")
local https = require "https"
love.filesystem.setCRequirePath("??")

local page = ...

local status, body = https.request(page)

love.thread.getChannel("https"):push{
	status = status,
	body = body
}
