local m = {}

function m.package(t)
    local dir = assert(t.dir, "directory not specified")
    local programName = assert(t.name, "program name not specified")
    local icon = t.icon or ""
    
    local out = magicNumber
    
    out = out .. love.data.pack("string", "zzz",
        formatVersion,
        programName,
        icon
    )
    
    local files = {}
    
    local function getFiles(d)
        for _, file in ipairs(love.filesystem.getDirectoryItems(dir .. d)) do
            if love.filesystem.getInfo(dir .. d .. file, "directory") then
                getFiles(d .. file .. "/")
            else
                table.insert(files, d .. file)
            end
        end
    end
    
    getFiles("")
    
    out = out .. love.data.pack("string", "T", #files)
    for _, file in ipairs(files) do
        out = out .. love.data.pack("string", "z", file)
    end
    
    for _, file in ipairs(files) do
        local data = love.filesystem.read(dir .. file)
        out = out .. love.data.pack("string", "s", data)
    end
    out = out .. "\0"
    
    return out
end

return m
