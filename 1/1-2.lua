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

local total_zero_clicks = 0
local current_position = 50 -- 0 to 99

local function processLine(line)
	local direction, amount = line:match("([LR])(%d+)")
	amount = tonumber(amount)

	local sign = (direction == "L") and -1 or 1

	for _ = 1, amount do
		current_position = (current_position + sign) % 100
		if current_position == 0 then
			total_zero_clicks = total_zero_clicks + 1
		end
	end
end

for _, line in ipairs(lines) do
	processLine(line)
end

print("The dial hit position 0 a total of " .. total_zero_clicks .. " times.")
