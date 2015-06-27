
module dquery.attributes;

import std.typetuple;

import dquery.attribute;
import dquery.helper;

struct DQueryAttributes(QueryType, Attributes...)
{

	alias attributes this;

	/++
	 + Property that returns the type being queried.
	 ++/
	@property
	alias type = QueryType;

	/++
	 + Property that returns the list of attributes.
	 ++/
	@property
	alias attributes = Attributes;

	/++
	 + Property that returns true if the list of attributes is empty.
	 ++/
	@property
	alias empty = Alias!(length == 0);

	/++
	 + Property that returns the number of attributes.
	 ++/
	@property
	alias length = Alias!(Attributes.length);

	/++
	 + Proprety that returns a transformed list of attributes with
	 + all duplicateds removed.
	 ++/
	@property
	alias unique = Alias!(
		DQueryAttributes!(QueryType, NoDuplicates!Attributes)()
	);

	/++
	 + Property that returns a subset of the list of attributes
	 + which match at least one of the given types.
	 ++/
	@property
	static auto allow(TList...)()
	if(TList.length > 0)
	{
		alias AllowFilter(Type) = Alias!(
			UnaryToPred!(attribute => attribute.isTypeOf!Type)
		);

		DQueryAttributes!(QueryType, Attributes) query = void;

		static if(Attributes.length > 0)
		{
			alias Pred = templateOr!(staticMap!(AllowFilter, TList));
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
	static auto forbid(TList...)()
	if(TList.length > 0)
	{
		alias ForbidFilter(Type) = Alias!(
			UnaryToPred!(attribute => !attribute.isTypeOf!Type)
		);

		DQueryAttributes!(QueryType, Attributes) query = void;

		static if(Attributes.length > 0)
		{
			alias Pred = templateAnd!(staticMap!(ForbidFilter, TList));
			return query.filter!Pred;
		}
		else
		{
			return query;
		}
	}

	@property
	static auto opCall()
	{
		DQueryAttributes!(QueryType, Attributes) attributes = void;
		return attributes;
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
