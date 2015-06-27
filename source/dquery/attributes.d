
module dquery.attributes;

import std.typetuple;

import dquery.attribute;
import dquery.helper;

struct DQueryAttributes(QueryType, Attributes...)
{

	/++
	 + Property that returns the type being queried.
	 ++/
	@property
	alias queryType = QueryType;

	@property
	alias attributes = Attributes;

	@property
	auto allow(TList...)()
	{
		alias AllowFilter(Type) = Alias!(
			UnaryToPred!(attribute => attribute.isTypeOf!Type)
		);

		return this.filter!(templateOr!(staticMap!(AllowFilter, TList)));
	}

	@property
	auto forbid(TList...)()
	{
		alias ForbidFilter(Type) = Alias!(
			UnaryToPred!(attribute => !attribute.isTypeOf!Type)
		);

		return this.filter!(templateAnd!(staticMap!(ForbidFilter, TList)));
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
