local __DARKLUA_BUNDLE_MODULES __DARKLUA_BUNDLE_MODULES={cache={}, load=function(m)if not __DARKLUA_BUNDLE_MODULES.cache[m]then __DARKLUA_BUNDLE_MODULES.cache[m]={c=__DARKLUA_BUNDLE_MODULES[m]()}end return __DARKLUA_BUNDLE_MODULES.cache[m].c end}do function __DARKLUA_BUNDLE_MODULES.a()

















return {
	STRING = "string",
	NUMBER = "number",
	PLUS = "plus",
	MINUS = "minus",
	MULTIPLY = "multiply",
	DIVIDE = "divide",
	LEFT_PAREN = "left_paren",
	RIGHT_PAREN = "right_paren",
	EOF = "eof",
}
end function __DARKLUA_BUNDLE_MODULES.b()


local TokenEnum = __DARKLUA_BUNDLE_MODULES.load('a')

local Token = {}
Token.Enum = TokenEnum

Token.__index = Token

Token.__tostring = function(object)
	if object then
		if object.Value then
			return `{object.Type}: {object.Value}`
		else
			return `{object.Type}`
		end
	else
		return "Attempt to represent token class"
	end
end









function Token.new(type, value)	
local self = (setmetatable({}, Token) )
	
self.Type = type
	self.Value = value

	return self
end

return Token
end function __DARKLUA_BUNDLE_MODULES.c()


local Token = __DARKLUA_BUNDLE_MODULES.load('b')

local function IsBlank(str)	
return str:match("%s") ~= nil
end

local function IsDigit(str)	
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











function Lexer.new(code)	
local self = (setmetatable({}, Lexer) )
	
self._code = code
	self._line = 1
	self._column = 1
	self._position = 1

	return self
end

function Lexer._error(self, text)
	error(`Lexer error (Line {self._line}, Column {self._column}): {text}`)
end

function Lexer._eof(self)	
return self._position > #self._code
end

function Lexer._peek(self, position)	
local index = position or self._position
	return string.sub(self._code, index, index)
end

function Lexer._advance(self)	
self._position += 1
	self._column += 1

	local currentCharacter = self:_peek()

	if currentCharacter == "\n" then
		self._line += 1
		self._column = 0
	end

	return currentCharacter
end

function Lexer._makeNumber(self)	
local resultNumber = ""
	local dotAmount = 0

	while not self:_eof() do
		local currentCharacter = self:_peek()

		if IsDigit(currentCharacter) then
			resultNumber ..= currentCharacter
			self:_advance()
		elseif currentCharacter == "." then
			if dotAmount > 0 then
				self:_error("Expected number, got another dot")
			end

			dotAmount += 1

			resultNumber ..= currentCharacter
			self:_advance()
		else
			break
		end
	end

	return (tonumber(resultNumber) )
end

function Lexer.Tokenize(self)	
	
self._line = 1
	self._column = 1
	self._position = 1

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
			self:_error(`Illegal character: {currentCharacter}`)
		end
	end

	table.insert(tokens, Token.new(Token.Enum.EOF))
	return tokens
end

return Lexer
end end


local Lexer = __DARKLUA_BUNDLE_MODULES.load('c')

local code = "-532.5 *2 (67 / 0.5)"

local lexer = Lexer.new(code)
local success, tokens = pcall(lexer.Tokenize, lexer)

if not success then
	return print(tokens)
end

for _, token in tokens do
	print(tostring(token))
end
