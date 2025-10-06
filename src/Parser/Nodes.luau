--!strict

local Nodes = {}

type Node = {
	__repr: (self: any) -> string,
}

export type NumberNode = Node & {
	Value: number,
}

local function RepresentNumber(self: NumberNode): string
	return tostring(self.Value)
end

function Nodes.Number(value: number): NumberNode
	return {
		Value = value,
		__repr = RepresentNumber,
	}
end

export type BinaryNode = Node & {
	Left: Node,
	Right: Node,
}

local function MakeBinaryRepresent(operation: string)
	return function(self: BinaryNode): string
		return `({self.Left:__repr()} {operation} {self.Right:__repr()})`
	end
end

local function MakeBinaryNodeConstructor(representFunction: (self: BinaryNode) -> string)
	return function(left: Node, right: Node): BinaryNode
		return {
			Left = left,
			Right = right,
			__repr = representFunction,
		}
	end
end

Nodes.Add = MakeBinaryNodeConstructor(MakeBinaryRepresent("+"))
Nodes.Subtract = MakeBinaryNodeConstructor(MakeBinaryRepresent("-"))
Nodes.Multiply = MakeBinaryNodeConstructor(MakeBinaryRepresent("*"))
Nodes.Divide = MakeBinaryNodeConstructor(MakeBinaryRepresent("/"))

-- -- For debug purposes
-- local expression = Nodes.Add(Nodes.Number(5), Nodes.Multiply(Nodes.Number(2), Nodes.Number(2)))
-- print(expression:__repr())

return Nodes
