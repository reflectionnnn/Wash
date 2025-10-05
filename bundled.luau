local __DARKLUA_BUNDLE_MODULES __DARKLUA_BUNDLE_MODULES={cache={}, load=function(m)if not __DARKLUA_BUNDLE_MODULES.cache[m]then __DARKLUA_BUNDLE_MODULES.cache[m]={c=__DARKLUA_BUNDLE_MODULES[m]()}end return __DARKLUA_BUNDLE_MODULES.cache[m].c end}do function __DARKLUA_BUNDLE_MODULES.a()



















return {
	STRING = "string",
	NUMBER = "number",
	BINARY_OPERATION = "binary_operation",
	LEFT_PAREN = "left_paren",
	RIGHT_PAREN = "right_paren",
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
return str == "" or str == " " or str == "\t" or str == "\n"
end

local function IsAlpha(str)	
return str:match("%a") ~= nil
end

local function IsDigit(str)	
return str:match("%d") ~= nil
end

local function IsBinaryOperator(str)	
return str == "+" or str == "-" or str == "*" or str == "/" or str == "%" or str == "^"
end

local Lexer = {}
Lexer.__index = Lexer













function Lexer.new(code)	
local self = (setmetatable({}, Lexer) )
	
self.Code = code
	self.Tokens = {}

	self.Line = 1
	self.Column = 1
	self.Position = 1

	return self
end

function Lexer._peek(self, position)	
local index = position or self.Position
	return string.sub(self.Code, index, index)
end

function Lexer._eof(self)	
return self.Position > #self.Code
end

function Lexer._advance(self)	
self.Position += 1
	self.Column += 1

	local currentCharacter = self:_peek()

	if currentCharacter == "\n" then
		self.Line += 1
		self.Column = 0
	end

	return currentCharacter
end

function Lexer._makeString(self)	
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

function Lexer._makeNumber(self)	
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

	return (tonumber(resultNumber) )
end

function Lexer.Tokenize(self)	
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
end end


local Lexer = __DARKLUA_BUNDLE_MODULES.load('c')

local code = [[532 - 53.5 / 2 * (3 - .5 + 67) ]]

local lexer = Lexer.new(code)
local tokens = lexer:Tokenize()

for _, token in tokens do
	print(tostring(token))
end
