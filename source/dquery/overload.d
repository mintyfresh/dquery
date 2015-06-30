
module dquery.overload;

import std.typetuple;

struct DQueryOverload(size_t Arity, ReturnType, ParamTypes...)
{

	@property
	alias arity = Arity;

	@property
	alias returnType = ReturnType;

	@property
	alias parameters = ParamTypes;

	@property
	static auto opCall()
	{
		DQueryOverload!(Arity, ReturnType, ParamTypes) overload = void;
		return overload;
	}

}
