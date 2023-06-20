-- this is definitely totally an actual proper DOM parser.
-- (it isn't. at all.)

local acknowledgedTags = {
	a = true,
	img = true,
}

local function domParse(html)
	local body = {}
	
	local _, bodyTag = html:find("<body")
	if not bodyTag then
		return {""}
	end
	
	local bodyStart = html:find(">", bodyTag)
	if not bodyStart then
		return {""}
	end
	bodyStart = bodyStart + 1
	
	local bodyEnd = html:find("</body>") or #html
	
	local bodyStr = html:sub(bodyStart, bodyEnd)
	
	local s = ""
	local i = 1
	while i <= #bodyStr do
		local char = bodyStr:sub(i, i)
		
		if char == "<" then
			table.insert(body, s)
			s = ""
			
			local tagName = bodyStr:match("%w*", i+1)
			
			if acknowledgedTags[tagName] then
				local attr = {}
				i = i + #tagName
				
				while true do
					if (tagName == "img") and bodyStr:match("%s*/>", i) or bodyStr:match("%s*>", i) then
						break
					end
					
					local space, attrName = bodyStr:match("(%s+)(%w+)", i)
					if attrName then
						i = i + #space + #attrName
						local space, attrValue = bodyStr:match("%s*=%s*'([^']*)'", i)
							or bodyStr:match("%s*=%s*\"([^']*)\"", i)
							or bodyStr:match("%s*=%s*([^%s'\"])", i)
							or ""
						i = i + #space, #attrValue
						
						attr[attrName] = attrValue
					end
				end
				
				i = i - 1
				local tagEnd
				
				if tagName == "img" then
					_, tagEnd = bodyStr:find("/>", i)
					print(tagName, tagEnd)
					i = tagEnd or #bodyStr
					value = ""
				else
					i = bodyStr:find(">", i) or #bodyStr
					local valueEnd
					valueEnd, tagEnd = bodyStr:find("</" .. tagName .. ">", i)
					valueEnd = valueEnd or #bodyStr
					tagEnd = tagEnd or #bodyStr
					value = bodyStr:sub(i+1, valueEnd-1)
				end
				table.insert(body, {type=tagName, value=value, attr=attr})
				
				i = tagEnd
			else
				i = bodyStr:find(">", i) or #bodyStr
			end
		else
			s = s .. char
		end
		
		i = i + 1
	end
	
	if #s > 0 then
		table.insert(body, s)
	end
	
	return body
end

return domParse
