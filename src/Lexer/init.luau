--!strict

local Token = require("Lexer/Token")

type TokenList = { Token.Token }

local function IndexString(operand_string: string, index: number): string?
	return string.sub(operand_string, index, index)
end

local Lexer = {}
Lexer.__index = Lexer

export type Lexer = typeof(setmetatable(
	{} :: {
		Code: string,
		Tokens: TokenList,

		Position: number,
		Line: number,
		Column: number,
	},
	Lexer
))

function Lexer.new(code: string): Lexer
	local self = setmetatable({}, Lexer) :: Lexer

	self.Code = JSONEncode(code) -- To detect new lines and other symbols
	self.Tokens = {}

	self.Position = 0
	self.Line = 0
	self.Column = 0

	return self
end

function Lexer._advance(self: Lexer): boolean
	local nextIndex = self.Position + 1

	-- Return false code if we reached end line
	if nextIndex > #self.Code then
		return false
	end

	if IndexString(self.Code, nextIndex) == "\n" then
		self.Line += 1
	end

	self.Column += 1
	self.Position = nextIndex

	-- Return true if we advanced successfully
	return true
end

function Lexer.Tokenize(self: Lexer): TokenList
	return self.Tokens
end

return Lexer
