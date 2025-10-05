--!strict

local Token = require("./Lexer/Token")

local function IsBlank(str: string): boolean
	return str:match("%s") ~= nil
end

local function IsDigit(str: string): boolean
	return str:match("%d") ~= nil
end

local SINGLE_CHARACTER_TOKENS = {
	["+"] = Token.Enum.PLUS,
	["-"] = Token.Enum.MINUS,
	["*"] = Token.Enum.MULTIPLY,
	["/"] = Token.Enum.DIVIDE,

	["("] = Token.Enum.LEFT_PAREN,
	[")"] = Token.Enum.RIGHT_PAREN,
}

local Lexer = {}
Lexer.__index = Lexer

export type Lexer = typeof(setmetatable(
	{} :: {
		Code: string,

		Line: number,
		Column: number,
		Position: number,
	},
	Lexer
))

function Lexer.new(code: string): Lexer
	local self = setmetatable({}, Lexer) :: Lexer

	self.Code = code

	self.Line = 1
	self.Column = 1
	self.Position = 1

	return self
end

function Lexer._eof(self: Lexer): boolean
	return self.Position > #self.Code
end

function Lexer._peek(self: Lexer, position: number?): string
	local index = position or self.Position
	return string.sub(self.Code, index, index)
end

function Lexer._advance(self: Lexer): string
	self.Position += 1
	self.Column += 1

	local currentCharacter = self:_peek()

	if currentCharacter == "\n" then
		self.Line += 1
		self.Column = 0
	end

	return currentCharacter
end

function Lexer._makeNumber(self: Lexer): number
	local resultNumber = ""
	local dotAmount = 0

	while not self:_eof() do
		local currentCharacter = self:_peek()

		if IsDigit(currentCharacter) then
			resultNumber ..= currentCharacter
			self:_advance()
		elseif currentCharacter == "." then
			if dotAmount > 1 then
				error("Expected number, got another dot")
			end

			dotAmount += 1

			resultNumber ..= currentCharacter
			self:_advance()
		else
			break
		end
	end

	return tonumber(resultNumber) :: number
end

function Lexer.Tokenize(self: Lexer): { Token.Token }
	-- Reset position
	self.Line = 1
	self.Column = 1
	self.Position = 1

	local tokens = {}

	while not self:_eof() do
		local currentCharacter = self:_peek()

		if IsBlank(currentCharacter) then
			self:_advance()
		elseif SINGLE_CHARACTER_TOKENS[currentCharacter] then
			table.insert(tokens, Token.new(SINGLE_CHARACTER_TOKENS[currentCharacter]))
			self:_advance()
		elseif IsDigit(currentCharacter) or currentCharacter == "." then
			table.insert(tokens, Token.new(Token.Enum.NUMBER, self:_makeNumber()))
		else
			error(`Illegal character: {currentCharacter}`)
		end
	end

	return tokens
end

return Lexer
