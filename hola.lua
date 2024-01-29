str = "{hoasdkajsd}{correcto}"
local pattern = "{([^{}]+)}"

-- Use string.match to find the match in the input string
local result = str:match(pattern)
print(result)
