--!strict

local TokenEnum = require("./TokenEnum")

local Token = {}
Token.__index = Token

export type Token = typeof(setmetatable({} :: {}, Token))

function Token.new(type: string): Token
	local self = setmetatable({}, Token) :: Token
	return self
end

return Token
