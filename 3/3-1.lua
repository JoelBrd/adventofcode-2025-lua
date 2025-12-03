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

local function getLargestJoltage(battery_bank)
	-- Find highest ten
	local highestTenIndex = nil

	for i = 1, (#battery_bank - 1) do -- -1 as we need at least one digit after
		if highestTenIndex == nil or battery_bank[i] > battery_bank[highestTenIndex] then
			highestTenIndex = i
		end
	end

	-- Now find the highest digit past the highest ten index
	local highestDigitIndex = nil
	for i = highestTenIndex + 1, #battery_bank do
		if highestDigitIndex == nil or battery_bank[i] > battery_bank[highestDigitIndex] then
			highestDigitIndex = i
		end
	end

	local highestTenNumber = battery_bank[highestTenIndex]
	local highestDigitNumber = battery_bank[highestDigitIndex]

	return highestTenNumber * 10 + highestDigitNumber
end

local total_joltage = 0
for _, bank in ipairs(battery_banks) do
	total_joltage = total_joltage + getLargestJoltage(bank)
end

print("Total Joltage:", total_joltage)
