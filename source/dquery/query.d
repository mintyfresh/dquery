
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

	/++
	 + Hidden constructor. No touchie.
	 ++/
	@disable this();

	@property
	static auto fields()()
	{
		DQuery!(QueryType, QueryElements) query = void;
		return query.filter!(f => f.isField);
	}

	/++
	 +
	 ++/
	@property
	static auto functions()()
	{
		DQuery!(QueryType, QueryElements) query = void;
		return query.filter!(f => f.isFunction);
	}

	@property
	static auto aggregates()()
	{
		DQuery!(QueryType, QueryElements) query = void;
		return query.filter!(f => f.isAggregate);
	}

}

template map(alias Pred)
{
	@property
	auto map(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(__traits(compiles, {
		DQuery!(QueryType, staticMap!(UnaryToPred!Pred, QueryElements)) result = void;
	}))
	{
		DQuery!(QueryType, staticMap!(UnaryToPred!Pred, QueryElements)) result = void;
		return result;
	}

	@property
	auto map(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(__traits(compiles, {
		DQuery!(QueryType, staticMap!(Pred, QueryElements)) result = void;
	}))
	{
		DQuery!(QueryType, staticMap!(Pred, QueryElements)) result = void;
		return result;
	}
}

template filter(alias Pred)
{
	@property
	auto filter(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(__traits(compiles, {
		DQuery!(QueryType, Filter!(UnaryToPred!Pred, QueryElements)) result = void;
	}))
	{
		DQuery!(QueryType, Filter!(UnaryToPred!Pred, QueryElements)) result = void;
		return result;
	}

	@property
	auto filter(QueryType, QueryElements...)(DQuery!(QueryType, QueryElements) query)
	if(__traits(compiles, {
		DQuery!(QueryType, Filter!(Pred, QueryElements)) result = void;
	}))
	{
		DQuery!(QueryType, Filter!(Pred, QueryElements)) result = void;
		return result;
	}
}
