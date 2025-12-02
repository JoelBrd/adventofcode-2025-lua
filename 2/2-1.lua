local input = io.open("2/input.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all") -- "10-20,150-300,..."
input:close()

--

local ranges = {} -- { {10, 20}, {150, 300}, ... }

-- separated by commas
for range_str in content:gmatch("[^,]+") do
	local start_str, end_str = range_str:match("(%d+)%-(%d+)")
	local start_num = tonumber(start_str)
	local end_num = tonumber(end_str)
	table.insert(ranges, { start_num, end_num })
end

local function doesIdHaveRepeatingPattern(id, rep)
	local id_str = tostring(id)
	local len = #id_str
	if len % rep ~= 0 then
		return false
	end

	local segment_len = len / rep
	local segment = id_str:sub(1, segment_len)

	for i = 1, rep - 1 do
		local start_index = i * segment_len + 1
		local end_index = start_index + segment_len - 1
		local current_segment = id_str:sub(start_index, end_index)
		if current_segment ~= segment then
			return false
		end
	end

	return true
end

-- id is invalid if it is some sequence of digits repeated twice
local function isInvalidId(id)
	-- odd length ids cannot be made of a repeated sequence
	local id_str = tostring(id)
	local len = #id_str

	for rep = 2, len do
		if doesIdHaveRepeatingPattern(id, rep) then
			return true
		end
	end

	return false
end

local invalid_ids = {}

for _, range in ipairs(ranges) do
	local start_num = tonumber(range[1])
	local end_num = tonumber(range[2])

	for id = start_num, end_num do
		if isInvalidId(id) then
			table.insert(invalid_ids, id)
		end
	end
end

local sum = 0
for _, id in ipairs(invalid_ids) do
	sum = sum + id
end

print("Found " .. #invalid_ids .. " invalid IDs. Sum:", sum)
