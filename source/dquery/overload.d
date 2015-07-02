
module dquery.overload;

import std.typetuple;

struct DQueryOverload(size_t Arity, ReturnType, ParamTypes...)
{

	/++
	 + Returns the arity of the overload.
	 ++/
	@property
	alias arity = Arity;

	/++
	 + Returns the return type of the overload.
	 ++/
	@property
	alias returnType = ReturnType;

	/++
	 + Returns the parameter types of the overload.
	 ++/
	@property
	alias parameters = ParamTypes;

	/++
	 + Returns an uninitialized value of the overload's type.
	 ++/
	@property
	static auto opCall()
	{
		DQueryOverload!(Arity, ReturnType, ParamTypes) overload = void;
		return overload;
	}

}
