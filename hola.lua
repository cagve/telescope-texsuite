local str = "{hoasdkajsd}{correcto}"
local pattern = "{([^{}]+)}"

-- Initialize a table to store the captured content
local resultTable = {}

-- -- Iterate over the input string and capture each match
for match in str:gmatch(pattern) do
	table.insert(resultTable, match)
end
print(resultTable[2])
