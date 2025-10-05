--!strict

local Lexer = require("./src/Lexer")

local code = [[ -532.5 *2 (67 / .5) ]]

local lexer = Lexer.new(code)
local tokens = lexer:Tokenize()

for _, token in tokens do
	print(tostring(token))
end
