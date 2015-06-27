
module dquery.attribute;

import std.typetuple;

struct DQueryAttribute(alias Attribute)
{

	/++
	 + Property that returns the value of the attribute.
	 ++/
	@property
	alias attribute = Attribute;

	// Determine how to get the type.
	static if(isExpression)
	{
		/++
		 + Property that returns the type of the attribute.
		 ++/
		@property
		alias type = typeof(Attribute);
	}
	else
	{
		/++
		 + Property that returns the type of the attribute.
		 ++/
		@property
		alias type = Attribute;
	}

	/++
	 + Proprety that returns true if the attribute is a type.
	 ++/
	@property
	alias isType = Alias!(
		!is(typeof(Attribute))
	);

	/++
	 + Property that returns true if the attribute is an expression.
	 ++/
	@property
	alias isExpression = Alias!(
		is(typeof(Attribute))
	);

	/++
	 + Property that returns true if a given type matches the attribute's
	 + type exactly.
	 ++/
	@property
	alias isTypeOf(Type) = Alias!(
		is(type == Type)
	);

	/++
	 + Property that returns true if a given type can be assigned to a
	 + variable of the attribute's type.
	 ++/
	@property
	alias isTypeAssignableTo(Type) = Alias!(
		__traits(compiles, {
			type t1 = void;
			Type t2 = t1;
		})
	);

	/++
	 + Property that returns true if a given type can be assigned from a
	 + variable of the attribute's type.
	 ++/
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
