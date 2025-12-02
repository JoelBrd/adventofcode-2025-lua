local input = io.open("1/input-dial-rotations.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all")
input:close()

--

-- Split each line into an array
local lines = {} -- {"L3", "R53", ...}
for line in content:gmatch("[^\r\n]+") do
	table.insert(lines, line)
end

local dial_positions = {}

local current_position = 50 -- 0 to 99

local function processLine(line)
	local direction, amount = line:match("([LR])(%d+)")
	amount = tonumber(amount)

	if direction == "L" then
		current_position = (current_position - amount) % 100
	elseif direction == "R" then
		current_position = (current_position + amount) % 100
	end

	table.insert(dial_positions, current_position)
end

for _, line in ipairs(lines) do
	processLine(line)
end

-- Now count how many times it hit 0
local zero_count = 0
for _, position in ipairs(dial_positions) do
	if position == 0 then
		zero_count = zero_count + 1
	end
end

print("The dial hit position 0 a total of " .. zero_count .. " times.")
