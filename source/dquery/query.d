
module dquery.query;

import std.traits;
import std.typetuple;

import dquery.attribute;
import dquery.attributes;
import dquery.element;
import dquery.helper;

struct DQuery(QueryType, QueryElements...)
{

	alias elements this;

	/++
	 + Returns the type being queried.
	 ++/
	@property
	alias type = QueryType;

	/++
	 + Returns the elements in the query.
	 ++/
	@property
	alias elements = QueryElements;

	/++
	 + Returns true if the query has no elements.
	 ++/
	@property
	alias empty = Alias!(length == 0);

	/++
	 + Returns the number of elements in the query.
	 ++/
	@property
	alias length = Alias!(elements.length);

	/++
	 + Returns the query with all duplicate elements removed.
	 ++/
	@property
	alias unique = Alias!(
		DQuery!(QueryType, NoDuplicates!QueryElements)()
	);

	/++
	 + Return an uninitialized value of the query's type.
	 ++/
	@property
	static auto opCall()
	{
		DQuery!(QueryType, QueryElements) query = void;
		return query;
	}

	/++
	 + Returns the query with all filters removed.
	 ++/
	@property
	static auto reset()()
	{
		import dquery.d;
		return query!QueryType;
	}

	/++
	 + Returns the type's attributes.
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
				GetAttributes!QueryType
			)
		)();
	}
 
	/++
	 + Returns the type's allowed attributes.
	 ++/
	@property
	static auto attributes(Allow...)()
	if(Allow.length > 0)
	{
		return attributes.allow!Allow;
	}

	/++
	 + Returns true if the type has all of the given attributes.
	 ++/
	@property
	static auto hasAllOf(TList...)()
	if(TList.length > 0)
	{
		return attributes.hasAllOf!TList;
	}

	/++
	 + Returns true if the type has any of the given attributes.
	 ++/
	@property
	static auto hasAnyOf(TList...)()
	if(TList.length > 0)
	{
		return attributes.hasAnyOf!TList;
	}

	/++
	 + Returns true if the type has none of the given attributes.
	 ++/
	@property
	static auto hasNoneOf(TList...)()
	if(TList.length > 0)
	{
		return attributes.hasNoneOf!TList;
	}

	/++
	 + Filters elements that match the given name.
	 ++/
	@property
	static auto name(string Name)()
	{
		return names!Name;
	}

	/++
	 + Filters elements that match one of the given names.
	 ++/
	@property
	static auto names(Names...)()
	{
		template NameFilter(alias Name)
		{
			alias NameFilter(alias Element) = Alias!(
				Element.isName!Name
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(templateOr!(staticMap!(NameFilter, Names)));
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that match one of the given types.
	 ++/
	@property
	static auto types(Types...)()
	{
		template TypeFilter(Type)
		{
			alias TypeFilter(alias Element) = Alias!(
				Element.isTypeOf!Type
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(templateOr!(staticMap!(TypeFilter, Types)));
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that return one of the given types.
	 ++/
	@property
	static auto returns(Types...)()
	{
		template ReturnFilter(Type)
		{
			alias ReturnFilter(alias Element) = Alias!(
				Element.isReturnTypeOf!Type
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(templateOr!(staticMap!(ReturnFilter, Types)));
		}
		else
		{
			return qeury;
		}
	}

	/++
	 + Filters elements that match the given arity value.
	 ++/
	@property
	static auto arity(int Arity)()
	{
		return arities!Arity;
	}

	/++
	 + Filters elements that match one of the given arity values.
	 ++/
	@property
	static auto arities(Arities...)()
	{
		template ArityFilter(int Arity)
		{
			alias ArityFilter(alias Element) = Alias!(
				Element.isArity!Arity
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(templateOr!(staticMap!(ArityFilter, Arities)));
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that match the given parameter list.
	 ++/
	@property
	static auto parameters(Parameters...)()
	{
		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(f => f.isParameterTypesOf!Parameters);
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that have all of the given attributes.
	 ++/
	@property
	static auto allOf(Attributes...)()
	{
		template AllOfFilter(alias Attribute)
		{
			alias AllOfFilter(alias Element) = Alias!(
				Element.hasAttribute!Attribute
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(templateAnd!(staticMap!(AllOfFilter, Attributes)));
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that have any of the given attributes.
	 ++/
	@property
	static auto anyOf(Attributes...)()
	{
		template AnyOfFilter(alias Attribute)
		{
			alias AnyOfFilter(alias Element) = Alias!(
				Element.hasAttribute!Attribute
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(templateOr!(staticMap!(AnyOfFilter, Attributes)));
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that have none of the given attributes.
	 ++/
	@property
	static auto noneOf(Attributes...)()
	{
		template NoneOfFilter(alias Attribute)
		{
			alias NoneOfFilter(alias Element) = Alias!(
				!Element.hasAttribute!Attribute
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(templateAnd!(staticMap!(NoneOfFilter, Attributes)));
		}
		else
		{
			return query;
		}
	}

	/++
	 + Provides validations regarding the query's length.
	 ++/
	@property
	template ensure(string Attr : "length")
	{
		import std.conv : text;

		@property
		static auto minimum(size_t Min,
			string Message = "Length cannot be less than " ~ Min.text)()
		{
			static assert(length >= Min, Message);
			return DQuery!(QueryType, QueryElements)();
		}

		@property
		static auto maximum(size_t Max,
			string Message = "Length cannot be greater than " ~ Max.text)()
		{
			static assert(length <= Max, Message);
			return DQuery!(QueryType, QueryElements)();
		}

		@property
		static auto between(size_t Min, size_t Max,
			string Message = "Length must be between " ~ Min.text ~ " and " ~ Max.text)()
		{
			static assert(length >= Min && length <= Max, Message);
			return DQuery!(QueryType, QueryElements)();
		}

		@property
		static auto exactly(size_t Length,
			string Message = "Length must be exactly " ~ Length.text)()
		{
			static assert(length == Length, Message);
			return DQuery!(QueryType, QueryElements)();
		}
	}

	/++
	 + Filters elements that are fields.
	 ++/
	@property
	static auto fields()()
	{
		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(f => f.isField);
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that are fields and match any of the given names.
	 ++/
	@property
	static auto fields(Names...)()
	if(Names.length > 0)
	{
		return fields.names!Names;
	}

	/++
	 + Filters elements that are functions.
	 ++/
	@property
	static auto functions()()
	{
		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(f => f.isFunction);
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that are functions and match any of the given names
	 ++/
	@property
	static auto functions(Names...)()
	if(Names.length > 0)
	{
		return functions.names!Names;
	}

	/++
	 + Filters elements that are constructors.
	 ++/
	@property
	static auto constructors()()
	{
		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(f => f.isConstructor);
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that are destructors.
	 ++/
	@property
	static auto destructors()()
	{
		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(f => f.isDestructor);
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that are aggregate types.
	 ++/
	@property
	static auto aggregates()()
	{
		auto query = DQuery!(QueryType, QueryElements)();

		static if(query.length > 0)
		{
			return query.filter!(f => f.isAggregate);
		}
		else
		{
			return query;
		}
	}

	/++
	 + Filters elements that are aggregate types and match any of the given names.
	 ++/
	@property
	static auto aggregates(Names...)()
	if(Names.length > 0)
	{
		return aggregates.names!Names;
	}

	/++
	 + Returns a union between this query and another one.
	 +
	 + Params:
	 +     query = The other query being joined with this one.
	 ++/
	@property
	static auto join(OType, OElements...)(DQuery!(OType, OElements) query)
	{
		return DQuery!(QueryType, TypeTuple!(QueryElements, OElements))();
	}

}

/++
 + Tests if all elements in a query satisfy a predicate template or function.
 ++/
template all(alias Pred)
{
	/++
	 + An empty query always produces true.
	 ++/
	@property
	bool all(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length == 0)
	{
		return true;
	}

	@property
	bool all(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		foreach(Element; QueryElements)
		{
			if(!Pred(Element))
			{
				return false;
			}
		}

		return true;
	}))
	{
		foreach(Element; QueryElements)
		{
			if(!Pred(Element))
			{
				return false;
			}
		}

		return true;
	}

	@property
	bool all(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		foreach(Element; QueryElements)
		{
			static if(!Pred!(Element))
			{
				return false;
			}
		}

		return true;
	}))
	{
		foreach(Element; QueryElements)
		{
			static if(!Pred!(Element))
			{
				return false;
			}
		}

		return true;
	}
}

/++
 + Tests if any elements in a query statisfy a template predicate or function.
 ++/
template any(alias Pred)
{
	/++
	 + An empty query always produces true.
	 ++/
	@property
	bool any(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length == 0)
	{
		return true;
	}

	@property
	bool any(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		foreach(Element; QueryElements)
		{
			if(Pred(Element))
			{
				return true;
			}
		}

		return false;
	}))
	{
		foreach(Element; QueryElements)
		{
			if(Pred(Element))
			{
				return true;
			}
		}

		return false;
	}

	@property
	bool any(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		foreach(Element; QueryElements)
		{
			if(Pred!(Element))
			{
				return true;
			}
		}

		return false;
	}))
	{
		foreach(Element; QueryElements)
		{
			if(Pred!(Element))
			{
				return true;
			}
		}

		return false;
	}
}

/++
 + Iterates over elements in a query using a unary template or function.
 ++/
template each(alias Pred)
{
	@property
	auto each(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length == 0)
	{
		return query;
	}

	@property
	auto each(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		foreach(element; QueryElements)
		{
			Pred(element);
		}
	}))
	{
		foreach(element; QueryElements)
		{
			Pred(element);
		}
		
		return query;
	}

	@property
	auto each(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		foreach(Element; QueryElements)
		{
			Pred!Element;
		}
	}))
	{
		foreach(Element; QueryElements)
		{
			Pred!Element;
		}
		
		return query;
	}
}

/++
 + Applies a map transformation to a query using a unary template or function.
 ++/
template map(alias Pred)
{
	@property
	auto map(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length == 0)
	{
		return [];
	}

	@property
	auto map(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		return [staticMap!(UnaryToPred!Pred, QueryElements)];
	}))
	{
		return [staticMap!(UnaryToPred!Pred, QueryElements)];
	}

	@property
	auto map(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		return [staticMap!(Pred, QueryElements)];
	}))
	{
		return [staticMap!(Pred, QueryElements)];
	}
}

/++
 + Applies a filter transformation to a query using a unary template or function.
 ++/
template filter(alias Pred)
{
	@property
	auto filter(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length == 0)
	{
		return query;
	}

	@property
	auto filter(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		return DQuery!(QueryType, Filter!(UnaryToPred!Pred, QueryElements))();
	}))
	{
		return DQuery!(QueryType, Filter!(UnaryToPred!Pred, QueryElements))();
	}

	@property
	auto filter(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		return DQuery!(QueryType, Filter!(Pred, QueryElements))();
	}))
	{
		return DQuery!(QueryType, Filter!(Pred, QueryElements))();
	}
}
