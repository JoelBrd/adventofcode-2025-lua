local input = io.open("6/input.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all") -- "10-20,150-300,..."
input:close()

-- Convert the input into a matrix, where a row's each entry is separated by a space and rows are separated by new lines

local matrix = {}
for line in content:gmatch("[^\r\n]+") do
	local row = {}
	for num in line:gmatch("%S+") do
		table.insert(row, num)
	end
	table.insert(matrix, row)
end

local dimX = #matrix[1]
local dimY = #matrix

-- Solve cephalopod math problem

local function solveProblem(x_dim)
	local nums = {}
	for y = 1, dimY - 1 do
		table.insert(nums, tonumber(matrix[y][x_dim]))
	end

	local operation_string = matrix[dimY][x_dim]
	if operation_string == "+" then
		local sum = 0
		for _, num in ipairs(nums) do
			sum = sum + num
		end
		return sum
	elseif operation_string == "*" then
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
