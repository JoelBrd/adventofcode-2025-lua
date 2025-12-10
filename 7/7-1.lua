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

local function countTotalSplits(drawn_matrix)
	local total_splits = 0

	local dimX = #drawn_matrix[1]
	local dimY = #drawn_matrix

	for x = 1, dimX do
		for y = 1, dimY do
			local char = readTachyonManifoldMatrixEntry(drawn_matrix, x, y)
			if char == CHAR_SPLITTER then
				local char_above = readTachyonManifoldMatrixEntry(drawn_matrix, x, y - 1)
				if char_above == CHAR_BEAM then
					total_splits = total_splits + 1
				end
			end
		end
	end

	return total_splits
end

local tachyonManifoldMatrix = contentToTachyonManifoldMatrix(content)
print("Original Tachyon Manifold Matrix:")
printTachyonManifoldMatrix(tachyonManifoldMatrix)

local drawnTachyonManifoldMatrix = drawTachyonBeamPath(tachyonManifoldMatrix)
print("Tachyon Manifold Matrix with Drawn Beam Paths:")
printTachyonManifoldMatrix(drawnTachyonManifoldMatrix)

local totalSplits = countTotalSplits(drawnTachyonManifoldMatrix)
print("Total number of beam splits: " .. totalSplits)
