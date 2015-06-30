
module dquery.element;

import std.traits;
import std.typetuple;

import dquery.attribute;
import dquery.attributes;
import dquery.helper;

struct DQueryElement(QueryType, string Name, ParamTypes...)
{

	/++
	 + Returns the type being queried.
	 ++/
	@property
	alias type = QueryType;

	/++
	 + Returns the name of the element.
	 ++/
	@property
	alias name = Name;

	static if(isFunction)
	{
		/++
		 + Returns the parameter types of the element.
		 ++/
		@property
		alias parameters = ParamTypes;
	}

	/++
	 + Returns true if the name matches.
	 ++/
	@property
	alias isName(string Name) = Alias!(
		name == Name
	);

	/++
	 + Returns true if the element has an attribute of the given type.
	 ++/
	@property
	alias hasAttribute(Type) = Alias!(
		attributes.anyOf!Type.length > 0
	);

	/++
	 + Returns the element's access protection.
	 ++/
	@property
	alias protection = Alias!(
		GetProtection!(QueryType, Name)
	);

	/++
	 + Returns true if the element refers to a field.
	 ++/
	@property
	alias isField = Alias!(
		is(typeof(GetMember!(QueryType, Name))) && !isFunction
	);

	/++
	 + Returns true if a given type matches the element's type exactly.
	 ++/
	@property
	alias isTypeOf(Type) = Alias!(
		__traits(compiles, {
			static assert(is(typeof(GetMember!(QueryType, Name)) == Type));
		})
	);

	/++
	 + Returns true if a given type can be assigned to a variable
	 + of the element's type.
	 ++/
	@property
	alias isTypeAssignableTo(Type) = Alias!(
		__traits(compiles, {
			typeof(GetMember!(QueryType, Name)) t1 = void;
			Type t2 = t1;
		})
	);

	/++
	 + Returns true if a given type can be assigned from a variable
	 + of the element's type.
	 ++/
	@property
	alias isTypeAssignableFrom(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			typeof(GetMember!(QueryType, Name)) t2 = t1;
		})
	);

	/++
	 + Returns true if the element refers to a function.
	 ++/
	@property
	alias isFunction = Alias!(
		is(typeof(GetMember!(QueryType, Name)) == function)
	);

	/++
	 + Returns true if the element refers to a constructor.
	 ++/
	@property
	alias isConstructor = Alias!(
		isFunction && isName!"__ctor"
	);

	/++
	 + Returns true if the element refers to a destructor.
	 ++/
	@property
	alias isDestructor = Alias!(
		isFunction && isName!"__dtor"
	);

	/++
	 + Return true if the element's arity matches the given number of parameters.
	 ++/
	@property
	alias isArity(int Count) = Alias!(
		isFunction && ParamTypes.length == Count
	);

	/++
	 + Returns true if a given type matches the element's return type exactly.
	 ++/
	@property
	alias isReturnTypeOf(Type) = Alias!(
		__traits(compiles, {
			static assert(is(ReturnType!(GetMember!(QueryType, Name)) == Type));
		})
	);

	/++
	 + Returns true if a given type can be assigned to a variable of the
	 + element's return type.
	 ++/
	@property
	alias isReturnAssignableTo(Type) = Alias!(
		__traits(compiles, {
			ReturnType!(GetMember!(QueryType, Name)) t1 = void;
			Type t2 = t1;
		})
	);

	/++
	 + Returns true if a given type can be assigned from a variable
	 + of the element's return type.
	 ++/
	@property
	alias isReturnAssignableFrom(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			ReturnType!(GetMember!(QueryType, Name)) t2 = t1;
		})
	);

	/++
	 + Returns true if the element's parameter types match the given type list.
	 ++/
	@property
	alias isParameterTypesOf(TList...) = Alias!(
		isFunction && Compare!(ParamTypes).With!(TList)
	);

	/++
	 + Returns true if the element refers to an aggregate type.
	 ++/
	@property
	alias isAggregate = Alias!(
		__traits(compiles, {
			static assert(isAggregateType!(GetMember!(QueryType, Name)));
		})
	);

	/++
	 + Returns true if a given type matches the element's aggregate type exactly.
	 ++/
	@property
	alias isAggregateTypeOf(Type) = Alias!(
		__traits(compiles, {
			static assert(is(GetMember!(QueryType, Name) == Type));
		})
	);

	/++
	 + Returns true if a given type can be assigned to a variable of the
	 + element's aggregate type.
	 ++/
	@property
	alias isAggregateAssignableTo(Type) = Alias!(
		__traits(compiles, {
			GetMember!(QueryType, Name) t1 = void;
			Type t2 = t1;
		})
	);

	/++
	 + Returns true if a given type can be assigned from a variable of the
	 + element's aggregate type.
	 ++/
	@property
	alias isAggregateAssignableFrom(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			GetMember!(QueryType, Name) t2 = t1;
		})
	);

	/++
	 + Returns true if the element refers to a class.
	 ++/
	@property
	alias isClass = Alias!(
		__traits(compiles, {
			alias Element = Alias!(GetMember!(QueryType, Name));
			static assert(is(Element == class));
		})
	);

	/++
	 + Returns true if the element refers to a struct.
	 ++/
	@property
	alias isStruct = Alias!(
		__traits(compiles, {
			alias Element = Alias!(GetMember!(QueryType, Name));
			static assert(is(Element == struct));
		})
	);

	/++
	 + Returns true is the element is a template of the given type.
	 ++/
	@property
	alias isTemplateOf(alias Template) = Alias!(
		__traits(compiles, {
			alias Element = Alias!(GetMember!(QueryType, Name));
			static assert(is(TemplateOf!Element == Template));
		})
	);

	/++
	 + Returns true if the element's template arguments match.
	 ++/
	@property
	alias isTemplateArgsOf(TemplateArgs...) = Alias!(
		__traits(compiles, {
			alias Element = Alias!(GetMember!(QueryType, Name));
			static assert(Compare!(TemplateArgsOf!Element).With!TemplateArgs);
		})
	);

	/++
	 + Returns an uninitialized value of the element's type.
	 ++/
	@property
	static auto opCall()
	{
		DQueryElement!(QueryType, Name, ParamTypes) element = void;
		return element;
	}

	/++
	 + Returns a query for the type the element refers to.
	 ++/
	@property
	static auto query()()
	if(isAggregate)
	{
		import dquery.d;
		return query!(GetMember!(QueryType, Name));
	}

	/++
	 + Returns a query for the parent type of the element.
	 ++/
	@property
	static auto parent()()
	{
		import dquery.d;
		return query!QueryType;
	}

	/++
	 + Returns the element's attributes.
	 ++/
	@property
	static auto attributes()()
	{
		alias MapToAttribute(alias Attribute) = Alias!(
			DQueryAttribute!Attribute()
		);

		return DQueryAttributes!(
			QueryType,
			staticMap!(
				MapToAttribute,
				GetAttributes!(QueryType, Name)
			)
		)();
	}
 
	/++
	 + Returns the element's allowed attributes.
	 ++/
	@property
	static auto attributes(Allow...)()
	if(Allow.length > 0)
	{
		return attributes.allow!Allow;
	}

	string toString()
	{
		return Name;
	}

}
