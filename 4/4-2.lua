local input = io.open("4/input.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all") -- "10-20,150-300,..."
input:close()

-- Convert Input into matrix of rolls of paper

local grid_rolls_of_paper = {} -- { {true, false, false}, {false, true, ...}, ... }

local lines = {} -- { "..@@.@@@@.", "@@@.@.@.@@", ... }
for line in content:gmatch("[^\r\n]+") do
	table.insert(lines, line)
end

for _, line in ipairs(lines) do
	local row = {}
	local len = #line
	for i = 1, len do
		local char = line:sub(i, i)
		if char == "@" then
			table.insert(row, true)
		else
			table.insert(row, false)
		end
	end

	table.insert(grid_rolls_of_paper, row)
end

--

local DIRECTIONS = {
	{ dx = -1, dy = -1 },
	{ dx = 0, dy = -1 },
	{ dx = 1, dy = -1 },
	{ dx = -1, dy = 0 },
	{ dx = 1, dy = 0 },
	{ dx = -1, dy = 1 },
	{ dx = 0, dy = 1 },
	{ dx = 1, dy = 1 },
}

local function getNeighbouringRollsOfPaperIndexes(grid, x, y)
	local neighbours = {} -- { {x=1,y=1}, {x=2,y=3}, ... }

	for _, direction in pairs(DIRECTIONS) do
		local nx = x + direction.dx
		local ny = y + direction.dy

		if grid[nx] and grid[nx][ny] then
			table.insert(neighbours, { x = nx, y = ny })
		end
	end

	return neighbours
end

-- The forklifts can only access a roll of paper if there are fewer than four rolls of paper in the eight adjacent positions.
local function whichRollsOfPaperCanBeAccessedByForkliftFour(grid)
	local indexes = {} -- { {x=1,y=1}, {x=2,y=3}, ... }

	for x = 1, #grid do
		for y = 1, #grid[x] do
			if grid[x][y] then
				local neighbours = getNeighbouringRollsOfPaperIndexes(grid, x, y)
				local canAccess = #neighbours < 4

				if canAccess then
					table.insert(indexes, { x = x, y = y })
				end
			end
		end
	end

	return indexes
end

local running_total = 0
while true do
	local indexes = whichRollsOfPaperCanBeAccessedByForkliftFour(grid_rolls_of_paper)

	if #indexes == 0 then
		break
	end

	running_total = running_total + #indexes

	-- Remove accessed rolls of paper from grid
	for _, index in ipairs(indexes) do
		grid_rolls_of_paper[index.x][index.y] = false
	end

	print("Removed " .. #indexes .. " rolls of paper, running total: " .. running_total)
end

print("Total Rolls of Paper that can be accessed by forklift:", running_total)
