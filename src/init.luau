--!strict

local Lexer = require("./src/Lexer")

local code = [[ 532 + 53.5 / 2 * (3 + 3) ]]

local lexer = Lexer.new(code)
local tokens = lexer:Tokenize()

for _, token in tokens do
	print(tostring(token))
end
