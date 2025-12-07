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
	-- print("Range Size", end_range - start_range)
end

for id in content_ingredients:gmatch("%d+") do
	table.insert(ingredient_ids, tonumber(id))
	-- print("Ingredient ID:", id)
end

-- Calculate total of ingredient IDs that fall within any of the ranges

local function doRangesOverlap(range1, range2)
	return not (range1[2] < range2[1] or range2[2] < range1[1])
end

local function mergeRange(range1, range2)
	if not doRangesOverlap(range1, range2) then
		return nil
	end
	return { math.min(range1[1], range2[1]), math.max(range1[2], range2[2]) }
end

local function areRangesEqual(range1, range2)
	return range1[1] == range2[1] and range1[2] == range2[2]
end

-- Merges overlapping ranges into non-overlapping ranges
local function mergeRanges(messy_ranges)
	local merged = {}

	table.insert(merged, messy_ranges[1])

	for _, range in pairs(messy_ranges) do
		local wasPutInMerged = false
		for i, mergedRange in pairs(merged) do
			if not areRangesEqual(range, mergedRange) then
				local newMergedRange = mergeRange(range, mergedRange)
				if newMergedRange then
					merged[i] = newMergedRange
					wasPutInMerged = true
					break
				end
			else
				wasPutInMerged = true
				break
			end
		end

		if not wasPutInMerged then
			table.insert(merged, range)
		end
	end

	return merged
end

local final_independent_ranges = nil
for i = 1, 100 do
	local merged_ranges = mergeRanges(ranges)

	if #merged_ranges == #ranges then
		final_independent_ranges = merged_ranges
		break
	else
		ranges = merged_ranges
	end
end

if not final_independent_ranges then
	print("Could not fully merge ranges after several iterations")
	return
end

local total = 0
for _, range in pairs(final_independent_ranges or {}) do
	total = total + (range[2] - range[1] + 1)
end

print("Total of ingredient IDs that fall within any of the ranges:", total)
