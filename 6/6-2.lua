local input = io.open("6/input.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all") -- "10-20,150-300,..."
input:close()

-- First, read the input and understand the col number for each line that separates each cephalopod problem.

local problem_divider_col_nums_hash = {}
for line in content:gmatch("[^\r\n]+") do
	for col = 1, (#line + 1) do
		if problem_divider_col_nums_hash[col] ~= false then
			local char = string.sub(line, col, col)
			local is_space = (char == " ") or (char == "")
			problem_divider_col_nums_hash[col] = (problem_divider_col_nums_hash[col] or true) and is_space
		end
	end
end

-- Convert the input into a matrix, where a row's each entry is separated by a space and rows are separated by new lines

local matrix = {}
for line in content:gmatch("[^\r\n]+") do
	local row = {}
	local num = 1
	for col = 1, #line do
		if problem_divider_col_nums_hash[col] then
			num = num + 1
		else
			local char = string.sub(line, col, col)
			row[num] = (row[num] or "") .. char
		end
	end
	table.insert(matrix, row)
end

local dimX = #matrix[1]
local dimY = #matrix

-- Solve cephalopod math problem

local function readCephalopodFormatNums(x_dim)
	local nums_strs = {}
	for d = 1, 1000 do
		local did_write = false
		for y = 1, dimY - 1 do
			local num_str = tostring(matrix[y][x_dim])
			if #num_str >= d then
				local num_d = string.sub(num_str, d, d)
				local num_str = nums_strs[d] or ""
				num_str = num_str .. num_d
				nums_strs[d] = num_str

				did_write = true
			end
		end

		if not did_write then
			break
		end
	end

	local nums = {}
	for _, num_str in ipairs(nums_strs) do
		-- print("Cephalopod number string: " .. string.format("'%s'", num_str))
		table.insert(nums, tonumber(num_str))
	end
	return nums
end

local function solveProblem(x_dim)
	local nums = readCephalopodFormatNums(x_dim)

	local operation_string = matrix[dimY][x_dim]
	if string.find(operation_string, "+") then
		local sum = 0
		for _, num in ipairs(nums) do
			sum = sum + num
		end
		return sum
	elseif string.find(operation_string, "*") then
		local product = 1
		for _, num in ipairs(nums) do
			product = product * num
		end
		return product
	else
		print("Unknown operation: " .. operation_string)
		return 0
	end
end

local sum_of_problem_solutions = 0
for x = 1, dimX do
	sum_of_problem_solutions = sum_of_problem_solutions + solveProblem(x)
end

print("The sum of all problem solutions is: " .. sum_of_problem_solutions)
