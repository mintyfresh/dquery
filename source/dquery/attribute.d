
module dquery.attribute;

import std.typetuple;

struct DQueryAttribute(alias Attribute)
{

	/++
	 + Property that returns the value of the attribute.
	 ++/
	@property
	alias attribute = Attribute;

	/++
	 + Property that returns the value of the attribute.
	 ++/
	@property
	alias get = Attribute;

	/++
	 + Proprety that returns true if the attribute is a type.
	 ++/
	@property
	enum isType = !is(typeof(Attribute));

	/++
	 + Property that returns true if the attribute is an expression.
	 ++/
	@property
	enum isExpression = is(typeof(Attribute));

	// Determine how to get the type.
	static if(isExpression)
	{
		/++
		 + Property that returns the type of the attribute.
		 ++/
		@property
		alias type = typeof(Attribute);

		/++
		 + Property that return the value of the attributes.
		 + Only defined for attributes that can produce a value.
		 ++/
		@property
		alias value = Attribute;

		/++
		 + Property that returns the value of the attribute, or a default.
		 ++/
		@property
		alias valueOr(alias Default) = Attribute;
	}
	else
	{
		/++
		 + Property that returns the type of the attribute.
		 ++/
		@property
		alias type = Attribute;

		/++
		 + Property that returns the value of the attribute, or a default.
		 ++/
		@property
		alias valueOr(alias Default) = Default;
	}

	/++
	 + Property that returns true if a given type matches the attribute's
	 + type exactly.
	 ++/
	@property
	enum isTypeOf(Type) = is(type == Type);

	/++
	 + Property that returns true if a given type can be assigned to a
	 + variable of the attribute's type.
	 ++/
	@property
	enum isTypeAssignableTo(Type) = __traits(compiles, {
		type t1 = void;
		Type t2 = t1;
	});

	/++
	 + Property that returns true if a given type can be assigned from a
	 + variable of the attribute's type.
	 ++/
	@property
	enum isTypeAssignableFrom(Type) = __traits(compiles, {
		Type t1 = void;
		type t2 = t1;
	});

	@property
	static auto opCall()
	{
		DQueryAttribute!(Attribute) attribute = void;
		return attribute;
	}

	@property
	static auto query()()
	{
		import dquery.d;
		return query!type;
	}

	static string toString()
	{
		return Attribute.stringof;
	}

}
