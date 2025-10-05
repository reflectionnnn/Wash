--!strict

local Token = require("./Lexer/Token")

local function IsBlank(str: string): boolean
	return str == "" or str == " " or str == "\t" or str == "\n"
end

local function IsAlpha(str: string): boolean
	return str:match("%a") ~= nil
end

local function IsDigit(str: string): boolean
	return str:match("%d") ~= nil
end

local function IsBinaryOperator(str: string): boolean
	return str == "+" or str == "-" or str == "*" or str == "/" or str == "%" or str == "^"
end

local Lexer = {}
Lexer.__index = Lexer

export type Lexer = typeof(setmetatable(
	{} :: {
		Code: string,
		Tokens: { Token.Token },

		Line: number,
		Column: number,
		Position: number,
	},
	Lexer
))

function Lexer.new(code: string): Lexer
	local self = setmetatable({}, Lexer) :: Lexer

	self.Code = code
	self.Tokens = {}

	self.Line = 1
	self.Column = 1
	self.Position = 1

	return self
end

function Lexer._peek(self: Lexer, position: number?): string
	local index = position or self.Position
	return string.sub(self.Code, index, index)
end

function Lexer._eof(self: Lexer): boolean
	return self.Position > #self.Code
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

function Lexer._makeString(self: Lexer): string
	local resultString = self:_advance()

	while not self:_eof() do
		local currentCharacter = self:_peek()

		if IsAlpha(currentCharacter) then
			resultString = resultString .. currentCharacter
			self:_advance()
		else
			break
		end
	end

	return resultString
end

function Lexer._makeNumber(self: Lexer): number
	local resultNumber = ""
	local dotAmount = 0

	while not self:_eof() do
		local currentCharacter = self:_peek()

		if currentCharacter == "." then
			if dotAmount > 1 then
				error("Expected number, got another dot")
			end

			dotAmount += 1

			resultNumber ..= currentCharacter
			self:_advance()
		elseif IsDigit(currentCharacter) then
			resultNumber ..= currentCharacter
			self:_advance()
		else
			break
		end
	end

	return tonumber(resultNumber) :: number
end

function Lexer.Tokenize(self: Lexer): { Token.Token }
	while not self:_eof() do
		local currentCharacter = self:_peek()

		if IsBlank(currentCharacter) then
			self:_advance()
		elseif IsAlpha(currentCharacter) then
			table.insert(self.Tokens, Token.new(Token.Enum.STRING, self:_makeString()))
		elseif IsDigit(currentCharacter) or currentCharacter == "." then
			table.insert(self.Tokens, Token.new(Token.Enum.NUMBER, self:_makeNumber()))
		elseif IsBinaryOperator(currentCharacter) then
			table.insert(self.Tokens, Token.new(Token.Enum.BINARY_OPERATION, currentCharacter))
			self:_advance()
		elseif currentCharacter == "(" then
			table.insert(self.Tokens, Token.new(Token.Enum.LEFT_PAREN))
			self:_advance()
		elseif currentCharacter == ")" then
			table.insert(self.Tokens, Token.new(Token.Enum.RIGHT_PAREN))
			self:_advance()
		else
			error(`Illegal character: {currentCharacter}`)
		end
	end

	return self.Tokens
end

return Lexer
