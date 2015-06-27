
module dquery.attribute;

import std.typetuple;

struct DQueryAttribute(alias Attribute)
{

	@property
	alias attribute = Attribute;

	// Determine how to get the type.
	static if(isExpression)
	{
		@property
		alias type = typeof(Attribute);
	}
	else
	{
		@property
		alias type = Attribute;
	}

	@property
	alias isType = Alias!(
		!is(typeof(Attribute))
	);

	@property
	alias isExpression = Alias!(
		is(typeof(Attribute))
	);

	@property
	alias isTypeOf(Type) = Alias!(
		is(type == Type)
	);

	@property
	alias isTypeAssignableTo(Type) = Alias!(
		__traits(compiles, {
			type t1 = void;
			Type t2 = t1;
		})
	);

	@property
	alias isTypeAssignableFrom(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			type t2 = t1;
		})
	);

	@property
	static auto opCall()
	{
		DQueryAttribute!(Attribute) attribute = void;
		return attribute;
	}

}
