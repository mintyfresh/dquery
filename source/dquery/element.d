
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

	/++
	 + Property that returns true if the element 
	 ++/
	@property
	alias hasAttribute(Type) = Alias!(
		attributes.allow!Type.length > 0
	);

	/++
	 + Property that returns the element's access protection.
	 ++/
	@property
	alias protection = Alias!(
		GetProtection!(QueryType, Name)
	);

	/++
	 + Property that returns true if the element refers to a field.
	 ++/
	@property
	alias isField = Alias!(
		is(typeof(GetMember!(QueryType, Name))) && !isFunction
	);

	/++
	 + Property that returns true if a given type matches the element's
	 + type exactly.
	 ++/
	@property
	alias isTypeOf(Type) = Alias!(
		__traits(compiles, {
			static assert(is(typeof(GetMember!(QueryType, Name)) == Type));
		})
	);

	/++
	 + Property that returns true if a given type can be assigned to a
	 + variable of the element's type.
	 ++/
	@property
	alias isTypeAssignableTo(Type) = Alias!(
		__traits(compiles, {
			typeof(GetMember!(QueryType, Name)) t1 = void;
			Type t2 = t1;
		})
	);

	/++
	 + Property that returns true if a given type can be assigned from a
	 + variable of the element's type.
	 ++/
	@property
	alias isTypeAssignableFrom(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			typeof(GetMember!(QueryType, Name)) t2 = t1;
		})
	);

	@property
	alias isTemplateOf(Type) = Alias!(
		__traits(compiles, {
			static assert(is(TemplateOf!(GetMember!(QueryType, Name)) == Type));
		})
	);

	/++
	 + Property that returns true if the element refers to a function.
	 ++/
	@property
	alias isFunction = Alias!(
		is(typeof(GetMember!(QueryType, Name)) == function)
	);

	/++
	 + Property that return true if the element's arity matches the given
	 + number of parameters.
	 ++/
	@property
	alias isArity(int Count) = Alias!(
		__traits(compiles, {
			static assert(arity!(GetMember!(QueryType, Name)) == Count);
		})
	);

	/++
	 + Property that returns true if a given type matches the element's
	 + return type exactly.
	 ++/
	@property
	alias isReturnTypeOf(Type) = Alias!(
		__traits(compiles, {
			static assert(is(ReturnType!(GetMember!(QueryType, Name)) == Type));
		})
	);

	/++
	 + Property that returns true if a given type can be assigned to a
	 + variable of the element's return type.
	 ++/
	@property
	alias isReturnAssignableTo(Type) = Alias!(
		__traits(compiles, {
			ReturnType!(GetMember!(QueryType, Name)) t1 = void;
			Type t2 = t1;
		})
	);

	/++
	 + Property that returns true if a given type can be assigned from a
	 + variable of the element's return type.
	 ++/
	@property
	alias isReturnAssignableFrom(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			ReturnType!(GetMember!(QueryType, Name)) t2 = t1;
		})
	);

	@property
	alias isParameterTypesOf(TList...) = Alias!(
		__traits(compiles, {
			static assert(
				Compare!(ParameterTypeTuple!(GetMember!(QueryType, Name)))
				.With!(TList)
			);
		})
	);

	/++
	 + Property that returns true if the element refers to an aggregate type.
	 ++/
	@property
	alias isAggregate = Alias!(
		__traits(compiles, {
			static assert(isAggregateType!(GetMember!(QueryType, Name)));
		})
	);

	/++
	 + Property that returns true if a given type matches the element's
	 + aggregate type exactly.
	 ++/
	@property
	alias isAggregateTypeOf(Type) = Alias!(
		__traits(compiles, {
			static assert(is(GetMember!(QueryType, Name) == Type));
		})
	);

	/++
	 + Property that returns true if a given type can be assigned to a
	 + variable of the element's aggregate type.
	 ++/
	@property
	alias isAggregateAssignableTo(Type) = Alias!(
		__traits(compiles, {
			GetMember!(QueryType, Name) t1 = void;
			Type t2 = t1;
		})
	);

	/++
	 + Property that returns true if a given type can be assigned from a
	 + variable of the element's aggregate type.
	 ++/
	@property
	alias isAggregateAssignableFrom(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			GetMember!(QueryType, Name) t2 = t1;
		})
	);

	/++
	 + Property that returns true if the element refers to a class.
	 ++/
	@property
	alias isClass = Alias!(
		__traits(compiles, {
			alias Element = Alias!(GetMember!(QueryType, Name));
			static assert(is(Element == class));
		})
	);

	/++
	 + Property that returns true if the element refers to a struct.
	 ++/
	@property
	alias isStruct = Alias!(
		__traits(compiles, {
			alias Element = Alias!(GetMember!(QueryType, Name));
			static assert(is(Element == struct));
		})
	);

	@property
	static auto query()()
	if(isAggregate)
	{
		import dquery.query;

		alias NewType = GetMember!(QueryType, Name);
		enum NewElements = __traits(allMembers, NewType);

		alias MapToElement(string Name) = Alias!(
			DQueryElement!(NewType, Name)()
		);

		return DQuery!(NewType, staticMap!(MapToElement, NewElements))();
	}

	@property
	static auto opCall()
	{
		DQueryElement!(QueryType, Name) element = void;
		return element;
	}

}
