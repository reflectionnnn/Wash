--!strict

local Token = require("./Lexer/Token")

local function IsAlpha(str: string): boolean
	return str:match("%a") ~= nil
end

local function IsDigit(str: string): boolean
	return str:match("%d") ~= nil
end

local function IsBlank(str: string): boolean
	return str == "" or str == " " or str == "\t" or str == "\n"
end

local Lexer = {}
Lexer.__index = Lexer

export type Lexer = typeof(setmetatable(
	{} :: {
		Code: string,
		Tokens: { Token.Token },

		Line: number,
		Column: number,
		_position: number,
	},
	Lexer
))

function Lexer.new(code: string): Lexer
	local self = setmetatable({}, Lexer) :: Lexer

	self.Code = code
	self.Tokens = {}

	self.Line = 0
	self.Column = 0
	self._position = 0

	return self
end

function Lexer._peek(self: Lexer, position: number?): string
	local index = position or self._position
	return string.sub(self.Code, index, index)
end

function Lexer._step(self: Lexer): boolean
	if self:_peek(self._position + 1) == "" then
		-- Can't step: Reached end of line
		return false
	end

	self._position += 1
	self.Column += 1

	if self:_peek() == "\n" then
		self.Line += 1
		self.Column = 0
	end

	-- Step was successfull
	return true
end

function Lexer._makeNumber(self: Lexer): number
	local dotAmount = 0
	local result_number = ""

	while true do
		local currentCharacter = self:_peek()

		if IsDigit(currentCharacter) then
			result_number = result_number .. currentCharacter

			self:_step()
		elseif currentCharacter == "." then
			if dotAmount > 1 then
				error("Expected number, got another dot")
			end

			dotAmount += 1
			result_number = result_number .. currentCharacter

			self:_step()
		else
			break
		end
	end

	return tonumber(result_number) :: number
end

function Lexer.Tokenize(self: Lexer): { Token.Token }
	-- Steps and breaks loop if reached end of line
	while self:_step() do
		local currentCharacter = self:_peek()

		if IsBlank(currentCharacter) then
			continue
		elseif IsDigit(currentCharacter) then
			table.insert(self.Tokens, Token.new(Token.Enum.NUMBER, self:_makeNumber()))
		elseif
			currentCharacter == "+"
			or currentCharacter == "-"
			or currentCharacter == "*"
			or currentCharacter == "/"
		then
			table.insert(self.Tokens, Token.new(Token.Enum.BINARY_OPERATION, currentCharacter))
		elseif currentCharacter == "(" then
			table.insert(self.Tokens, Token.new(Token.Enum.LEFT_PAREN))
		elseif currentCharacter == ")" then
			table.insert(self.Tokens, Token.new(Token.Enum.RIGHT_PAREN))
		else
			error("Syntax error")
		end
	end

	return self.Tokens
end

return Lexer
