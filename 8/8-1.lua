local input = io.open("8/input.txt", "r")
if not input then
	print("Could not open input file")
	return
end

local content = input:read("*all") -- "123,456,789\n101,202,30\n..."
input:close()

-- Convert the input into an array of vertices..

local vertices = {} -- { {123, 456, 789}, {101, 202, 30}, ... }

for line in content:gmatch("[^\r\n]+") do
	local vertex = {}
	for num_str in line:gmatch("%d+") do
		table.insert(vertex, tonumber(num_str))
	end
	table.insert(vertices, vertex)
end

-- Now generate all possible edges ...

local function encodeVertex(vertex)
	return table.concat(vertex, ",")
end

local function decodeVertex(vertex_str)
	local vertex = {}
	for num_str in vertex_str:gmatch("%d+") do
		table.insert(vertex, tonumber(num_str))
	end
	return vertex
end

local function magnitude(vector)
	local sum_sq = 0
	for _, coord in ipairs(vector) do
		sum_sq = sum_sq + coord * coord
	end
	return math.sqrt(sum_sq)
end

local function encodeEdge(v1, v2)
	local vSmall, vLarge -- ensures consistent ordering
	if magnitude(v1) <= magnitude(v2) then
		vSmall = v1
		vLarge = v2
	else
		vSmall = v2
		vLarge = v1
	end

	return "(" .. encodeVertex(vSmall) .. ")-(" .. encodeVertex(vLarge) .. ")"
end

local function decodeEdge(edge_str)
	local v1_str, v2_str = edge_str:match("%(([%d,]+)%)%-%(([%d,]+)%)")
	return decodeVertex(v1_str), decodeVertex(v2_str)
end

local edges = {} -- { ["(123,456,789)-(101,202,30)"] = distance }

for i = 1, #vertices do
	for j = i + 1, #vertices do
		local v1 = vertices[i]
		local v2 = vertices[j]

		local vDiff = {
			v2[1] - v1[1],
			v2[2] - v1[2],
			v2[3] - v1[3],
		}

		local edge_key = encodeEdge(v1, v2)

		edges[edge_key] = magnitude(vDiff)
	end
end

local ordered_edges = {} -- { "(123,456,789)-(101,202,30)", ... }

for edge_key, _ in pairs(edges) do
	table.insert(ordered_edges, edge_key)
end
table.sort(ordered_edges, function(a, b)
	return edges[a] < edges[b]
end)

-- Now make the ten shortest connections and track circuits ...

local circuits = {} -- { { v1, v2 }, { v5, v7, v4 }, ... }

local function printCircuits()
	for ci, circuit in ipairs(circuits) do
		local circuit_str = "  Circuit " .. ci .. ": "
		for _, v in ipairs(circuit) do
			circuit_str = circuit_str .. encodeVertex(v) .. " | "
		end
		print("   >", circuit_str)
	end
end

local function areVerticesInSameCircuit(v1, v2)
	for _, circuit in ipairs(circuits) do
		local foundV1 = false
		local foundV2 = false
		for _, v in ipairs(circuit) do
			if encodeVertex(v) == encodeVertex(v1) then --! Only works because tables references.
				foundV1 = true
			end
			if encodeVertex(v) == encodeVertex(v2) then
				foundV2 = true
			end
		end
		if foundV1 and foundV2 then
			return true
		end
	end
	return false
end

local function buildConnection(v1, v2)
	-- If either vertex is already in a circuit, add the other to it.
	local circuitIndexV1 = -1
	local circuitIndexV2 = -1
	for ci, circuit in ipairs(circuits) do
		for _, v in ipairs(circuit) do
			if encodeVertex(v) == encodeVertex(v1) then
				circuitIndexV1 = ci
			end
			if encodeVertex(v) == encodeVertex(v2) then
				circuitIndexV2 = ci
			end
		end
	end

	if circuitIndexV1 ~= -1 and circuitIndexV2 ~= -1 then
		-- Both vertices are in different circuits, merge them.
		if circuitIndexV1 ~= circuitIndexV2 then
			local circuitV1 = circuits[circuitIndexV1]
			local circuitV2 = circuits[circuitIndexV2]
			-- Merge circuitV2 into circuitV1
			for _, v in ipairs(circuitV2) do
				table.insert(circuitV1, v)
			end
			-- Remove circuitV2
			table.remove(circuits, circuitIndexV2)
		else
			warn("Both vertices are already in the same circuit.")
		end
	elseif circuitIndexV1 ~= -1 then
		-- v1 is in a circuit, add v2
		table.insert(circuits[circuitIndexV1], v2)
	elseif circuitIndexV2 ~= -1 then
		-- v2 is in a circuit, add v1
		table.insert(circuits[circuitIndexV2], v1)
	else
		-- Neither vertex is in a circuit, create a new one.
		table.insert(circuits, { v1, v2 })
	end
end

local total_connections_made = 0

for _, edge in pairs(ordered_edges) do
	local v1, v2 = decodeEdge(edge)
	if areVerticesInSameCircuit(v1, v2) then
		--continue
		total_connections_made = total_connections_made + 1
	else
		print(total_connections_made + 1, "Connecting vertices: " .. encodeVertex(v1) .. " and " .. encodeVertex(v2))
		buildConnection(v1, v2)
		printCircuits()
		total_connections_made = total_connections_made + 1
		if total_connections_made >= 1000 then
			break
		end
	end
end

-- Verify no duplicate vertices across circuits
local vertexSet = {}
for ci, circuit in ipairs(circuits) do
	for _, v in ipairs(circuit) do
		local vKey = encodeVertex(v)
		if vertexSet[vKey] then
			warn("Duplicate vertex found across circuits: " .. vKey)
		else
			vertexSet[vKey] = true
		end
	end
end

print("-----")

-- Calculate the product of 3 largest circuits ...

table.sort(circuits, function(a, b)
	return #a > #b
end)

print("Circuits:")
for i, circuit in ipairs(circuits) do
	local circuit_str = "  Circuit " .. i .. "(" .. #circuit .. "): "
	for _, v in ipairs(circuit) do
		circuit_str = circuit_str .. encodeVertex(v) .. " | "
	end
	print("   >", circuit_str)
end

local product = 1
for i = 1, math.min(3, #circuits) do
	product = product * #circuits[i]
end

print("Product of sizes of three largest circuits: " .. product)
