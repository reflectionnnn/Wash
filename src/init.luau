--!strict

local Lexer = require("./src/Lexer")

local code = "-532.5 *2 (67 / 0.5)"

local lexer = Lexer.new(code)
local success, tokens = pcall(lexer.Tokenize, lexer)

if not success then
	return print(tokens)
end

for _, token in tokens do
	print(tostring(token))
end
