--!strict

local TokenEnum = require("./Token/TokenEnum")

local Token = {}
Token.Enum = TokenEnum

export type Token = {
	Type: string,
	Value: any?,
}

function Token.new(type: string, value: any?): Token
	local token = {} :: Token

	token.Type = type
	token.Value = value

	return token
end

return Token
