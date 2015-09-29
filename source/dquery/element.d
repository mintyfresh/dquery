
module dquery.element;

import std.traits;
import std.typetuple;

import dquery.attribute;
import dquery.attributes;
import dquery.helper;

struct DQueryElement(QueryType, string Name, alias Overload = null)
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
	enum name = Name;

	// Check if the element is accessible.
	static if(__traits(compiles, GetMember!(QueryType, Name)))
	{
		/++
		 + Returns true if the element is accessible.
		 ++/
		@property
		enum isAccessible = true;

		/++
		 + Returns the value of the element.
		 ++/
		@property
		alias value = Alias!(
			GetMember!(QueryType, Name)
		);
	}
	else
	{
		/++
		 + Returns true if the element is accessible.
		 ++/
		@property
		enum isAccessible = false;

		/++
		 + Returns void for inaccessible elements.
		 ++/
		@property
		alias value = Alias!(void);
	}

	/++
	 + Returns true if the name matches.
	 ++/
	@property
	enum isName(string Name) = name == Name;

	/++
	 + Returns true if the element has an attribute of the given type.
	 ++/
	@property
	enum hasAttribute(Type) = attributes.anyOf!Type.length > 0;

	/++
	 + Returns true if the element has all of the given attributes.
	 ++/
	@property
	enum hasAllOf(TList...) = attributes.hasAllOf!TList;

	/++
	 + Returns true if the element has any of the given attributes.
	 ++/
	@property
	enum hasAnyOf(TList...) = attributes.hasAnyOf!TList;

	/++
	 + Returns true if the element has none of the given attributes.
	 ++/
	@property
	enum hasNoneOf(TList...) = attributes.hasNoneOf!TList;

	/++
	 + Returns the element's access protection.
	 ++/
	@property
	enum protection = GetProtection!(QueryType, Name);

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
	enum isTypeOf(Type) = is(typeof(GetMember!(QueryType, Name)) == Type);

	/++
	 + Returns true if a given type can be assigned to a variable
	 + of the element's type.
	 ++/
	@property
	enum isTypeAssignableTo(Type) = __traits(compiles, {
		typeof(GetMember!(QueryType, Name)) t1 = void;
		Type t2 = t1;
	});

	/++
	 + Returns true if a given type can be assigned from a variable
	 + of the element's type.
	 ++/
	@property
	enum isTypeAssignableFrom(Type) = __traits(compiles, {
		Type t1 = void;
		typeof(GetMember!(QueryType, Name)) t2 = t1;
	});

	/++
	 + Returns true if the element refers to a function.
	 ++/
	@property
	enum isFunction =
		is(typeof(GetMember!(QueryType, Name)) == function) &&
		!is(typeof(Overload) == typeof(null));

	/++
	 + Returns true if the element refers to a constructor.
	 ++/
	@property
	enum isConstructor = isFunction && isName!"__ctor";

	/++
	 + Returns true if the element refers to a destructor.
	 ++/
	@property
	enum isDestructor = isFunction && isName!"__dtor";

	/++
	 + Return true if the element's arity matches the given number of parameters.
	 ++/
	@property
	enum isArity(int Count) = isFunction && __traits(compiles, {
		static assert(Overload.arity == Count);
	});

	/++
	 + Returns true if a given type matches the element's return type exactly.
	 ++/
	@property
	enum isReturnTypeOf(Type) = isFunction && is(Overload.returnType == Type);

	/++
	 + Returns true if a given type can be assigned to a variable of the
	 + element's return type.
	 ++/
	@property
	enum isReturnAssignableTo(Type) = isFunction && __traits(compiles, {
		Overload.returnType t1 = void;
		Type t2 = t1;
	});

	/++
	 + Returns true if a given type can be assigned from a variable
	 + of the element's return type.
	 ++/
	@property
	enum isReturnAssignableFrom(Type) = isFunction && __traits(compiles, {
		Type t1 = void;
		Overload.returnType t2 = t1;
	});

	/++
	 + Returns true if the element's parameter types match the given type list.
	 ++/
	@property
	enum isParameterTypesOf(TList...) = isFunction && __traits(compiles, {
		static assert(Compare!(Overload.parameters).With!(TList));
	});

	/++
	 + Returns true if the element refers to an aggregate type.
	 ++/
	@property
	enum isAggregate = __traits(compiles, {
		static assert(isAggregateType!(GetMember!(QueryType, Name)));
	});

	/++
	 + Returns true if a given type matches the element's aggregate type exactly.
	 ++/
	@property
	enum isAggregateTypeOf(Type) = isAggregate && is(GetMember!(QueryType, Name) == Type);

	/++
	 + Returns true if a given type can be assigned to a variable of the
	 + element's aggregate type.
	 ++/
	@property
	enum isAggregateAssignableTo(Type) = isAggregate && __traits(compiles, {
		GetMember!(QueryType, Name) t1 = void;
		Type t2 = t1;
	});

	/++
	 + Returns true if a given type can be assigned from a variable of the
	 + element's aggregate type.
	 ++/
	@property
	enum isAggregateAssignableFrom(Type) = isAggregate && __traits(compiles, {
		Type t1 = void;
		GetMember!(QueryType, Name) t2 = t1;
	});

	/++
	 + Returns true if the element refers to a class.
	 ++/
	@property
	enum isClass = isAggregate && __traits(compiles, {
		alias Element = Alias!(GetMember!(QueryType, Name));
		static assert(is(Element == class));
	});

	/++
	 + Returns true if the element refers to a struct.
	 ++/
	@property
	enum isStruct = isAggregate && __traits(compiles, {
		alias Element = Alias!(GetMember!(QueryType, Name));
		static assert(is(Element == struct));
	});

	/++
	 + Returns true if the element refers to an enum.
	 ++/
	@property
	enum isEnum = isAggregate && __traits(compiles, {
		alias Element = Alias!(GetMember!(QueryType, Name));
		static assert(is(Element == enum));

	});

	/++
	 + Returns true is the element is a template of the given type.
	 ++/
	@property
	enum isTemplateOf(alias Template) = __traits(compiles, {
		alias Element = Alias!(GetMember!(QueryType, Name));
		static assert(is(TemplateOf!Element == Template));
	});

	/++
	 + Returns true if the element's template arguments match.
	 ++/
	@property
	enum isTemplateArgsOf(TemplateArgs...) = __traits(compiles, {
		alias Element = Alias!(GetMember!(QueryType, Name));
		static assert(Compare!(TemplateArgsOf!Element).With!TemplateArgs);
	});

	/++
	 + Returns an uninitialized value of the element's type.
	 ++/
	@property
	static auto opCall()
	{
		DQueryElement!(QueryType, Name, Overload) element = void;
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
		static if(isAccessible)
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
		else
		{
			return DQueryAttributes!(
				QueryType, TypeTuple!()
			)();
		}
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

	/++
	 + Returns the name of element.
	 ++/
	static string toString()
	{
		return Name;
	}

}
