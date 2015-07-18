
module dquery.attributes;

import std.typetuple;

import dquery.attribute;
import dquery.helper;

struct DQueryAttributes(QueryType, Attributes...)
{

	alias attributes this;

	/++
	 + Returns the type being queried.
	 ++/
	@property
	alias type = QueryType;

	/++
	 + Returns a tuple of attributes in the query.
	 ++/
	@property
	alias attributes = Attributes;

	/++
	 + Returns true if the list of attributes is empty.
	 ++/
	@property
	enum empty = length == 0;

	/++
	 + Returns the number of attributes in the query.
	 ++/
	@property
	enum length = Attributes.length;

	/++
	 + Returns a transformed list of attributes with all duplicateds removed.
	 ++/
	@property
	enum unique = DQueryAttributes!(QueryType, NoDuplicates!Attributes)();

	/++
	 + Returns an uninitialized value of the query's type.
	 ++/
	@property
	static auto opCall()
	{
		DQueryAttributes!(QueryType, Attributes) attributes = void;
		return attributes;
	}

	/++
	 + Returns a query for the type that produced this attribute query.
	 ++/
	@property
	static auto parent()()
	{
		import dquery.d;
		return query!QueryType;
	}

	/++
	 + Returns the first attribute in the query.
	 ++/
	@property
	static auto first()()
	{
		static assert(!empty, "Attributes query is empty.");
		return Attributes[0];
	}

	/++
	 + Returns the first attribute in the query, or a fallback if empty.
	 ++/
	@property
	static auto firstOr(alias Fallback)()
	if(!is(typeof(Fallback) == void))
	{
		static if(!empty)
		{
			return Attributes[0];
		}
		else
		{
			return Fallback;
		}
	}

	/++
	 + Returns true if all of the given attributes are present.
	 ++/
	@property
	static auto hasAllOf(TList...)()
	if(TList.length > 0)
	{
		auto query = DQueryAttributes!(QueryType, Attributes)();

		static if(TList.length > 1)
		{
			return query.hasAnyOf!(TList[0]) && query.hasAllOf!(TList[1 .. $]);
		}
		else
		{
			return query.hasAnyOf!(TList[0]);
		}
	}

	/++
	 + Returns true if any of the given attributes are present.
	 ++/
	@property
	static auto hasAnyOf(TList...)()
	if(TList.length > 0)
	{
		auto query = DQueryAttributes!(QueryType, Attributes)();
		return !query.anyOf!TList.empty;
	}

	/++
	 + Returns true if none of the given attributes are present.
	 ++/
	@property
	static auto hasNoneOf(TList...)()
	if(TList.length > 0)
	{
		auto query = DQueryAttributes!(QueryType, Attributes)();
		return query.anyOf!TList.empty;
	}

	/++
	 + Returns a subset of the list of attributes which match
	 + at least one of the given types.
	 ++/
	@property
	static auto anyOf(TList...)()
	if(TList.length > 0)
	{
		alias AnyOfFilter(Type) = Alias!(
			UnaryToPred!(attribute => attribute.isTypeOf!Type)
		);

		auto query = DQueryAttributes!(QueryType, Attributes)();

		static if(Attributes.length > 0)
		{
			alias Pred = templateOr!(staticMap!(AnyOfFilter, TList));
			return query.filter!Pred;
		}
		else
		{
			return query;
		}
	}

	/++
	 + Property that returns a subset of the list of attributes
	 + which match none of the given types.
	 ++/
	@property
	static auto noneOf(TList...)()
	if(TList.length > 0)
	{
		alias NoneOfFilter(Type) = Alias!(
			UnaryToPred!(attribute => !attribute.isTypeOf!Type)
		);

		auto query = DQueryAttributes!(QueryType, Attributes)();

		static if(Attributes.length > 0)
		{
			alias Pred = templateAnd!(staticMap!(NoneOfFilter, TList));
			return query.filter!Pred;
		}
		else
		{
			return query;
		}
	}

	/++
	 + Provides query validation functions tied to length.
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
			return DQueryAttributes!(QueryType, Attributes)();
		}

		@property
		static auto maximum(size_t Max,
			string Message = "Length cannot be greater than " ~ Max.text)()
		{
			static assert(length <= Max, Message);
			return DQueryAttributes!(QueryType, Attributes)();
		}

		@property
		static auto between(size_t Min, size_t Max,
			string Message = "Length must be between " ~ Min.text ~ " and " ~ Max.text)()
		{
			static assert(length >= Min && length <= Max, Message);
			return DQueryAttributes!(QueryType, Attributes)();
		}

		@property
		static auto exactly(size_t Length,
			string Message = "Length must be exactly " ~ Length.text)()
		{
			static assert(length == Length, Message);
			return DQueryAttributes!(QueryType, Attributes)();
		}
	}

}

template filter(alias Pred)
{
	@property
	auto filter(QueryType, Attributes...)(DQueryAttributes!(QueryType, Attributes) attributes)
	if(Attributes.length == 0)
	{
		return attributes;
	}

	@property
	auto filter(QueryType, Attributes...)(DQueryAttributes!(QueryType, Attributes) attributes)
	if(Attributes.length > 0 && __traits(compiles, {
		DQueryAttributes!(QueryType, Filter!(UnaryToPred!Pred, Attributes)) result = void;
	}))
	{
		DQueryAttributes!(QueryType, Filter!(UnaryToPred!Pred, Attributes)) result = void;
		return result;
	}

	@property
	auto filter(QueryType, Attributes...)(DQueryAttributes!(QueryType, Attributes) attributes)
	if(Attributes.length > 0 && __traits(compiles, {
		DQueryAttributes!(QueryType, Filter!(Pred, Attributes)) result = void;
	}))
	{
		DQueryAttributes!(QueryType, Filter!(Pred, Attributes)) result = void;
		return result;
	}
}
