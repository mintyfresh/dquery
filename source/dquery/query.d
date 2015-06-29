
module dquery.query;

import std.traits;
import std.typetuple;

import dquery.element;
import dquery.helper;

struct DQuery(QueryType, QueryElements...)
{

	alias elements this;

	/++
	 + Property that returns the type being queried.
	 ++/
	@property
	alias type = QueryType;

	/++
	 + Property that returns the elements in the query.
	 ++/
	@property
	alias elements = QueryElements;

	/++
	 + Property that returns true if the query has no elements.
	 ++/
	@property
	alias empty = Alias!(length == 0);

	/++
	 + Property that returns the number of elements in the query.
	 ++/
	@property
	alias length = Alias!(elements.length);

	@property
	static auto opCall()
	{
		DQuery!(QueryType, QueryElements) query = void;
		return query;
	}

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
		return query.filter!(templateOr!(staticMap!(NameFilter, Names)));
	}

	@property
	static auto types(Types...)()
	{
		template TypeFilter(alias Type)
		{
			alias TypeFilter(alias Element) = Alias!(
				Element.isTypeOf!Type
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(templateOr!(staticMap!(NameFilter, Names)));
	}

	@property
	static auto allow(Attributes...)()
	{
		template AllowFilter(alias Attribute)
		{
			alias AllowFilter(alias Element) = Alias!(
				Element.hasAttribute!Attribute
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(templateOr!(staticMap!(AllowFilter, Attributes)));
	}

	@property
	static auto forbid(Attributes...)()
	{
		template ForbidFilter(alias Attribute)
		{
			alias ForbidFilter(alias Element) = Alias!(
				!Element.hasAttribute!Attribute
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(templateAnd!(staticMap!(ForbidFilter, Attributes)));
	}

	@property
	static auto require(Attributes...)()
	{
		template RequireFilter(alias Attribute)
		{
			alias RequireFilter(alias Element) = Alias!(
				Element.hasAttribute!Attribute
			);
		}

		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(templateAnd!(staticMap!(RequireFilter, Attributes)));
	}

	@property
	static auto fields()()
	{
		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(f => f.isField);
	}

	/++
	 +
	 ++/
	@property
	static auto functions()()
	{
		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(f => f.isFunction);
	}

	@property
	static auto aggregates()()
	{
		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(f => f.isAggregate);
	}

}

template map(alias Pred)
{
	@property
	auto map(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length == 0)
	{
		return query;
	}

	@property
	auto map(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		return DQuery!(QueryType, staticMap!(UnaryToPred!Pred, QueryElements))();
	}))
	{
		return DQuery!(QueryType, staticMap!(UnaryToPred!Pred, QueryElements))();
	}

	@property
	auto map(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(QueryElements.length > 0 && __traits(compiles, {
		return DQuery!(QueryType, staticMap!(Pred, QueryElements))();
	}))
	{
		return DQuery!(QueryType, staticMap!(Pred, QueryElements))();
	}
}

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
