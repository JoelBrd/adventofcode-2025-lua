local input = io.open("7/input.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all") -- "10-20,150-300,..."
input:close()

-- Convert the input into a matrix, where a row's each entry is separated by a space and rows are separated by new lines

local CHAR_EMPTY_SPACE = "."
local CHAR_SOURCE = "S"
local CHAR_SPLITTER = "^"
local CHAR_BEAM = "|"

local function contentToTachyonManifoldMatrix(content_input)
	local matrix = {}
	for line in content_input:gmatch("[^\r\n]+") do
		local row = {}
		for col = 1, #line do
			local char = string.sub(line, col, col)
			table.insert(row, char)
		end
		table.insert(matrix, row)
	end
	return matrix
end

local function readTachyonManifoldMatrixEntry(matrix, x, y)
	return matrix[y] and matrix[y][x]
end

local function writeTachyonManifoldMatrixEntry(matrix, x, y, value)
	matrix[y] = matrix[y] or {}
	matrix[y][x] = value
end

local function printTachyonManifoldMatrix(matrix)
	local dimX = #matrix[1]
	local dimY = #matrix
	for y = 1, dimY do
		local row_str = ""
		for x = 1, dimX do
			row_str = row_str .. tostring(matrix[y][x]) .. " "
		end
		print(row_str)
	end
end

local function drawTachyonBeamPath(matrix)
	local dimX = #matrix[1]
	local dimY = #matrix

	local drawn_matrix = {}

	-- Copy original matrix into drawn matrix
	for x = 1, dimX do
		for y = 1, dimY do
			local char = readTachyonManifoldMatrixEntry(matrix, x, y)
			writeTachyonManifoldMatrixEntry(drawn_matrix, x, y, char)
		end
	end

	local function tryDescendBeamFrom(x_start, y_start)
		local charBelow = readTachyonManifoldMatrixEntry(drawn_matrix, x_start, y_start + 1)
		if charBelow == CHAR_EMPTY_SPACE then
			writeTachyonManifoldMatrixEntry(drawn_matrix, x_start, y_start + 1, CHAR_BEAM)
			tryDescendBeamFrom(x_start, y_start + 1)
		elseif charBelow == CHAR_SPLITTER then
			-- Try left
			local charLeft = readTachyonManifoldMatrixEntry(drawn_matrix, x_start - 1, y_start + 1)
			if charLeft == CHAR_EMPTY_SPACE then
				writeTachyonManifoldMatrixEntry(drawn_matrix, x_start - 1, y_start + 1, CHAR_BEAM)
				tryDescendBeamFrom(x_start - 1, y_start + 1)
			end

			-- Try right
			local charRight = readTachyonManifoldMatrixEntry(drawn_matrix, x_start + 1, y_start + 1)
			if charRight == CHAR_EMPTY_SPACE then
				writeTachyonManifoldMatrixEntry(drawn_matrix, x_start + 1, y_start + 1, CHAR_BEAM)
				tryDescendBeamFrom(x_start + 1, y_start + 1)
			end
		end
	end

	-- Extend down discovered beams.
	for x = 1, dimX do
		for y = 1, dimY do
			local char = readTachyonManifoldMatrixEntry(drawn_matrix, x, y)
			if char == CHAR_SOURCE or char == CHAR_BEAM then
				tryDescendBeamFrom(x, y)
			end
		end
	end

	return drawn_matrix
end

local function findSplitterBelow(matrix, x_start, y_start)
	local dimY = #matrix
	for y = y_start + 1, dimY do
		local char = readTachyonManifoldMatrixEntry(matrix, x_start, y)
		if char == CHAR_SPLITTER then
			return { x = x_start, y = y }
		end
	end
	return nil
end

local function countTotalQuantumTachyonTimelines(drawn_matrix)
	local total_timelines = 0

	local dimX = #drawn_matrix[1]
	local dimY = #drawn_matrix

	-- Find Source
	local source_pos = { x = -1, y = -1 }
	for y = 1, dimY do
		for x = 1, dimX do
			local char = readTachyonManifoldMatrixEntry(drawn_matrix, x, y)
			if char == CHAR_SOURCE then
				source_pos.x = x
				source_pos.y = y
				break
			end
		end
		if source_pos.x ~= -1 then
			break
		end
	end

	local first_splitter_pos = findSplitterBelow(drawn_matrix, source_pos.x, source_pos.y)
	if not first_splitter_pos then
		print("No splitter found below source.")
		return 0
	end

	local cache = {} -- { [`x,y`] = total_timelines_from_here }

	local function recurseFromSplitter(splitter_pos)
		-- read cache incase we've already computed this
		local cache_key = tostring(splitter_pos.x) .. "," .. tostring(splitter_pos.y)
		if cache[cache_key] then
			return cache[cache_key]
		end

		local this_total_timelines = 0

		local left_splitter_pos = findSplitterBelow(drawn_matrix, splitter_pos.x - 1, splitter_pos.y)
		if left_splitter_pos then
			this_total_timelines = this_total_timelines + recurseFromSplitter(left_splitter_pos)
		else
			-- end of timeline
			this_total_timelines = this_total_timelines + 1
		end

		local right_splitter_pos = findSplitterBelow(drawn_matrix, splitter_pos.x + 1, splitter_pos.y)
		if right_splitter_pos then
			this_total_timelines = this_total_timelines + recurseFromSplitter(right_splitter_pos)
		else
			-- end of timeline
			this_total_timelines = this_total_timelines + 1
		end

		-- cache
		cache[cache_key] = this_total_timelines

		return this_total_timelines
	end

	total_timelines = total_timelines + recurseFromSplitter(first_splitter_pos)

	return total_timelines
end

local tachyonManifoldMatrix = contentToTachyonManifoldMatrix(content)
print("Original Tachyon Manifold Matrix:")
printTachyonManifoldMatrix(tachyonManifoldMatrix)

local drawnTachyonManifoldMatrix = drawTachyonBeamPath(tachyonManifoldMatrix)
print("Tachyon Manifold Matrix with Drawn Beam Paths:")
printTachyonManifoldMatrix(drawnTachyonManifoldMatrix)

local totalTimelines = countTotalQuantumTachyonTimelines(drawnTachyonManifoldMatrix)
print("Total number of quantum tachyon timelines: " .. totalTimelines)
