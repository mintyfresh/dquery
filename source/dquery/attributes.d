
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

	@property
	alias attributes = Attributes;

	@property
	alias empty = Alias!(length == 0);

	@property
	alias length = Alias!(Attributes.length);

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
