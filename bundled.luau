local __DARKLUA_BUNDLE_MODULES
__DARKLUA_BUNDLE_MODULES = {
	cache = {},
	load = function(m)
		if not __DARKLUA_BUNDLE_MODULES.cache[m] then
			__DARKLUA_BUNDLE_MODULES.cache[m] = { c = __DARKLUA_BUNDLE_MODULES[m]() }
		end
		return __DARKLUA_BUNDLE_MODULES.cache[m].c
	end,
}
do
	function __DARKLUA_BUNDLE_MODULES.a()
		return {
			STRING = "string",
			NUMBER = "number",

			BINARY_OPERATION = "binary_operation",
			LEFT_PAREN = "left_paren",
			RIGHT_PAREN = "right_paren",
		}
	end
	function __DARKLUA_BUNDLE_MODULES.b()
		local TokenEnum = __DARKLUA_BUNDLE_MODULES.load("a")

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
			local self = (setmetatable({}, Token))

			self.Type = type
			self.Value = value

			return self
		end

		return Token
	end
	function __DARKLUA_BUNDLE_MODULES.c()
		local Token = __DARKLUA_BUNDLE_MODULES.load("b")

		local function IsAlpha(str)
			return str:match("%a") ~= nil
		end

		local function IsDigit(str)
			return str:match("%d") ~= nil
		end

		local function IsBlank(str)
			return str == "" or str == " " or str == "\t" or str == "\n"
		end

		local Lexer = {}
		Lexer.__index = Lexer

		function Lexer.new(code)
			local self = (setmetatable({}, Lexer))

			self.Code = code
			self.Tokens = {}

			self.Line = 0
			self.Column = 0
			self._position = 0

			return self
		end

		function Lexer._peek(self, position)
			local index = position or self._position
			return string.sub(self.Code, index, index)
		end

		function Lexer._step(self)
			if self:_peek(self._position + 1) == "" then
				return false
			end

			self._position += 1
			self.Column += 1

			if self:_peek() == "\n" then
				self.Line += 1
				self.Column = 0
			end

			return true
		end

		function Lexer._makeNumber(self)
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

			return (tonumber(result_number))
		end

		function Lexer.Tokenize(self)
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
	end
end

local Lexer = __DARKLUA_BUNDLE_MODULES.load("c")

local code = [[ 532 + 53.5 / 2 * (3 + 3) ]]

local lexer = Lexer.new(code)
local tokens = lexer:Tokenize()

for _, token in tokens do
	print(tostring(token))
end
