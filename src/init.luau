--!strict

local Lexer = require("./src/Lexer")
local Parser = require("./src/Parser")

type TokenList = Lexer.TokenList
type AST = Parser.AST

local Bash = {}

export type Bash = typeof(Bash)

function Bash.Lex(self: Bash, code: string): (boolean, TokenList | string)
	local lexer = Lexer.new(code)
	return pcall(lexer.Tokenize, lexer)
end

function Bash.Parse(self: Bash, tokens: TokenList): (boolean, AST | string)
	local parser = Parser.new(tokens)
	return pcall(parser.Parse, parser)
end

function Bash.Run(self: Bash, code: string): (boolean, ...any?)
	local lexSuccess, lexResult = self:Lex(code)

	if not lexSuccess then
		return false, lexResult
	end

	local parseSuccess, parseResult = self:Parse(lexResult :: TokenList)

	if not parseSuccess then
		return false, parseResult
	end

	return true, parseResult
end

local code = "-532.5 *2 (67 / 0.5)"
local success, result = Bash:Run(code)

if not success then
	return print(result)
end

-- -- Print tokens for debug purposes
-- for _, token in result :: TokenList do
-- 	print(token:__repr())
-- end
