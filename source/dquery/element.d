
module dquery.element;

import std.traits;
import std.typetuple;

import dquery.attribute;
import dquery.attributes;
import dquery.helper;

alias MapToAttribute(alias Attribute) = Alias!(
	DQueryAttribute!Attribute()
);

struct DQueryElement(QueryType, string Name)
{

	/++
	 + Property that returns the type being queried.
	 ++/
	@property
	alias type = QueryType;

	/++
	 + Property that returns the name of the element.
	 ++/
	@property
	alias name = Name;

	/++
	 + Property that returns the element's attributes.
	 ++/
	@property
	alias attributes = Alias!(
		DQueryAttributes!(
			QueryType,
			staticMap!(
				MapToAttribute,
				GetAttributes!(QueryType, Name)
			)
		)()
	);

	@property
	alias hasAttribute(Type) = Alias!(
		attributes.allow!Type.length > 0
	);

	/++
	 + Property that returns the element's access protection.
	 ++/
	@property
	alias protection = Alias!(
		__traits(getProtection, GetMember!(QueryType, Name))
	);

	/++
	 + Property that returns true if the element refers to a function.
	 ++/
	@property
	alias isField = Alias!(
		is(typeof(GetMember!(QueryType, Name))) && !isFunction
	);

	/++
	 + Property that returns true if the element's type is an exact match.
	 ++/
	@property
	alias isTypeOf(Type) = Alias!(
		__traits(compiles, {
			static assert(is(typeof(GetMember!(QueryType, Name)) == Type));
		})
	);

	@property
	alias isTypeAssignableTo(Type) = Alias!(
		__traits(compiles, {
			typeof(GetMember!(QueryType, Name)) t1 = void;
			Type t2 = t1;
		})
	);

	@property
	alias isTypeAssignableFrom(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			typeof(GetMember!(QueryType, Name)) t2 = t1;
		})
	);

	@property
	alias isFunction = Alias!(
		is(typeof(GetMember!(QueryType, Name)) == function)
	);

	@property
	alias isArity(int Count) = Alias!(
		__traits(compiles, {
			static assert(arity!(GetMember!(QueryType, Name) == Count));
		})
	);

	@property
	alias isReturnType(Type) = Alias!(
		__traits(compiles, {
			static assert(is(ReturnType!(GetMember!(QueryType, Name)) == Type));
		})
	);

	@property
	alias isAggregate = Alias!(
		__traits(compiles, {
			static assert(isAggregateType!(GetMember!(QueryType, Name)));
		})
	);

	@property
	alias isClass = Alias!(
		__traits(compiles, {
			alias Element = Alias!(GetMember!(QueryType, Name));
			static assert(is(Element == class));
		})
	);

	@property
	alias isStruct = Alias!(
		__traits(compiles, {
			alias Element = Alias!(GetMember!(QueryType, Name));
			static assert(is(Element == struct));
		})
	);

	@property
	static auto opCall()
	{
		DQueryElement!(QueryType, Name) element = void;
		return element;
	}

}
