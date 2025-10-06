--!strict

local TokenEnum = require("./Token/TokenEnum")

local Token = {}
Token.Enum = TokenEnum

export type Token = {
	Type: string,
	Value: any?,
	__repr: (self: Token) -> string,
}

local function Represent(self: Token): string
	if not self.Value then
		return self.Type
	else
		return `{self.Type}: {self.Value}`
	end
end

function Token.new(type: string, value: any?): Token
	return {
		Type = type,
		Value = value,
		__repr = Represent,
	}
end

return Token
