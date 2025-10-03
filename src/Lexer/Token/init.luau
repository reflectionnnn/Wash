--!strict

local TokenEnum = require("./Token/TokenEnum")

local Token = {}
Token.Enum = TokenEnum

Token.__index = Token

Token.__tostring = function(object: Token)
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

export type Token = typeof(setmetatable(
	{} :: {
		Type: string,
		Value: any,
	},
	Token
))

function Token.new(type: string, value: any): Token
	local self = setmetatable({}, Token) :: Token

	self.Type = type
	self.Value = value

	return self
end

return Token
