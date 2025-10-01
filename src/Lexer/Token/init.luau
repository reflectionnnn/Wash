--!strict

local TokenEnum = require("Token/TokenEnum")

local Token = {}
Token.__index = Token

Token.Enum = TokenEnum

export type Token = typeof(setmetatable(
	{} :: {
		Type: string,
	},
	Token
))

function Token.new(type: string): Token
	assert(table.find(TokenEnum, type), `Invalid token type "{type}"`)

	local self = setmetatable({}, Token) :: Token

	self.Type = type

	return self
end

return Token
