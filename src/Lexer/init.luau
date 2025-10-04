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

local function IsBinary(str: string): boolean
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

	self.Line = 0
	self.Column = 0
	self.Position = 0

	return self
end

function Lexer._peek(self: Lexer, position: number?): string
	local index = position or self.Position
	return string.sub(self.Code, index, index)
end

function Lexer._step(self: Lexer, amount: number?): boolean
	-- Amount to step the code, can be negative to step back
	local stepAmount = amount or 1

	-- Reached end of the line or trying to step back too far
	if self:_peek(self.Position + stepAmount) == "" then
		return false
	end

	self.Position += stepAmount
	self.Column += stepAmount

	if self:_peek() == "\n" then
		if stepAmount > 0 then
			self.Line += 1
			self.Column = 0
		elseif stepAmount < 0 then
			self.Line -= 1
		end
	end

	-- Step was successful
	return true
end

function Lexer._makeString(self: Lexer): string
	local result_string = "" .. self:_peek()

	while self:_step() do
		local currentCharacter = self:_peek()

		if IsAlpha(currentCharacter) then
			result_string = result_string .. currentCharacter
		else
			self:_step(-1)
			break
		end
	end

	return result_string
end

function Lexer._makeNumber(self: Lexer): number
	local dotAmount = 0
	local result_number = "" .. self:_peek()

	if result_number == "." then
		dotAmount += 1
	end

	while self:_step() do
		local currentCharacter = self:_peek()

		if currentCharacter == "." then
			if dotAmount > 1 then
				error("Expected number, got another dot")
			end

			dotAmount += 1
			result_number = result_number .. currentCharacter
		elseif IsDigit(currentCharacter) then
			result_number = result_number .. currentCharacter
		else
			self:_step(-1)
			break
		end
	end

	return tonumber(result_number) :: number
end

function Lexer.Tokenize(self: Lexer): { Token.Token }
	while self:_step() do
		local currentCharacter = self:_peek()

		if IsBlank(currentCharacter) then
			continue
		elseif IsAlpha(currentCharacter) then
			table.insert(self.Tokens, Token.new(Token.Enum.STRING, self:_makeString()))
		elseif IsDigit(currentCharacter) or currentCharacter == "." then
			table.insert(self.Tokens, Token.new(Token.Enum.NUMBER, self:_makeNumber()))
		elseif IsBinary(currentCharacter) then
			table.insert(self.Tokens, Token.new(Token.Enum.BINARY_OPERATION, currentCharacter))
		elseif currentCharacter == "(" then
			table.insert(self.Tokens, Token.new(Token.Enum.LEFT_PAREN))
		elseif currentCharacter == ")" then
			table.insert(self.Tokens, Token.new(Token.Enum.RIGHT_PAREN))
		else
			error(`Illegal character: {currentCharacter}`)
		end
	end

	return self.Tokens
end

return Lexer
