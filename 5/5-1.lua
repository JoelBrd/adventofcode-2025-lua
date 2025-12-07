local input = io.open("5/input.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all") -- "10-20,150-300,..."
input:close()

-- Split content into 2 parts; separeted by a blank line

local content_ranges = content:match("^(.-)\n\n")
local content_ingredients = content:match("\n\n(.*)$")

-- Convert Input into ranges, and ingredient IDs

local ranges = {} -- { {10,20}, {150,300}, ... }
local ingredient_ids = {} -- { 1, 2, 3, ... }

for range in content_ranges:gmatch("[^\r\n]+") do
	local start_range, end_range = range:match("(%d+)%-(%d+)")
	table.insert(ranges, { tonumber(start_range), tonumber(end_range) })
	-- print("Range:", start_range, end_range)
end

for id in content_ingredients:gmatch("%d+") do
	table.insert(ingredient_ids, tonumber(id))
	-- print("Ingredient ID:", id)
end

-- Calculate total of ingredient IDs that fall within any of the ranges

local function isNumberInRange(number, range)
	return number >= range[1] and number <= range[2]
end

local total_fresh_ingredient_ids = 0
for _, id in ipairs(ingredient_ids) do
	local is_fresh = false
	for _, range in ipairs(ranges) do
		if isNumberInRange(id, range) then
			is_fresh = true
			break
		end
	end

	if is_fresh then
		total_fresh_ingredient_ids = total_fresh_ingredient_ids + 1
	end
end

print("Total of fresh ingredient IDs:", total_fresh_ingredient_ids)
