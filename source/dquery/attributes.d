
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
	alias empty = Alias!(length == 0);

	/++
	 + Returns the number of attributes in the query.
	 ++/
	@property
	alias length = Alias!(Attributes.length);

	/++
	 + Returns a transformed list of attributes with all duplicateds removed.
	 ++/
	@property
	alias unique = Alias!(
		DQueryAttributes!(QueryType, NoDuplicates!Attributes)()
	);

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
		import dquery.query;
		import dquery.element;

		enum QueryElements = __traits(allMembers, QueryType);

		alias MapToElement(string Name) = Alias!(
			DQueryElement!(QueryType, Name)()
		);

		return DQuery!(QueryType, staticMap!(MapToElement, QueryElements))();
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
