local Lexer = require("./Lexer")
local Nodes = require("./Parser/Nodes")

type TokenList = Lexer.TokenList
export type AST = {} -- Blank for now

local Parser = {}
Parser.__index = Parser

export type Parser = typeof(setmetatable(
	{} :: {
		_tokens: TokenList,
	},
	Parser
))

function Parser.new(tokens: TokenList): Parser
	local self = setmetatable({}, Parser) :: Parser

	self._tokens = tokens

	return self
end

function Parser.Parse(self: Parser): AST
	-- TODO
	return {}
end

return Parser
