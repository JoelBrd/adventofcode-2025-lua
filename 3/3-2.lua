local input = io.open("3/input.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all") -- "10-20,150-300,..."
input:close()

-- Load Battery Banks

local battery_banks = {} -- { { 1, 2, 3 }, { 9, 8, 7, 6}, ... }

local lines = {} -- { "123", "9876", ... }
for line in content:gmatch("[^\r\n]+") do
	table.insert(lines, line)
end

for _, line in ipairs(lines) do
	local bank = {}
	for digit in line:gmatch("%d") do
		table.insert(bank, tonumber(digit))
	end
	table.insert(battery_banks, bank)
end

local function getLargestJoltage(battery_bank, size)
	local index_history = {}

	local joltage = 0
	for i = 1, size do
		local digitsLeftAfterUs = size - i

		local indexRangeStart = (index_history[#index_history] or 0) + 1
		local indexRangeEnd = #battery_bank - digitsLeftAfterUs

		-- Find the highest number in the range
		local highestIndex = nil
		for j = indexRangeStart, indexRangeEnd do
			if highestIndex == nil or battery_bank[j] > battery_bank[highestIndex] then
				highestIndex = j
			end
		end
		table.insert(index_history, highestIndex)

		local pow = 10 ^ (size - i)

		joltage = joltage + battery_bank[highestIndex] * pow
	end

	print("Joltage for size " .. size .. ": " .. joltage)

	return math.floor(joltage)
end

local total_joltage = 0
for _, bank in ipairs(battery_banks) do
	total_joltage = total_joltage + getLargestJoltage(bank, 12)
end

print("Total Joltage:", total_joltage)
