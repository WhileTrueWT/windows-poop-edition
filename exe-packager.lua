local formatVersion = "0.0.0"
local magicNumber = string.char(132, 248)

local dir = ...
assert(dir, "directory not specified")

if not string.match(dir, "/$") then
    dir = dir .. "/"
end

local outfile = "./src/src/windows/" .. string.match(dir, "/*([^/]+)/$") .. ".exe"

local packageData = dofile(dir .. "package.lua")
local programName = assert(packageData.name, "program name not specified")
local icon = packageData.icon or ""

local out = magicNumber

out = out .. string.pack("zzz",
    formatVersion,
    programName,
    icon
)

local files = {}

local f = io.popen('find "' .. dir .. '" -type f -printf "%P\\0"')
local itemstr = f:read("*a")
f:close()

for s in string.gmatch(itemstr, "([^\0]+)") do
    table.insert(files, s)
end

out = out .. string.pack("T", #files)
for _, file in ipairs(files) do
    out = out .. string.pack("z", file)
end

for _, file in ipairs(files) do
    local f = io.open(dir .. file)
    local data = f:read("*a")
    f:close()
    
    out = out .. string.pack("s", data)
end
out = out .. "\0"

local f = io.open(outfile, "wb")
f:write(out)
f:close()
