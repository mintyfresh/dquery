
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

	@property
	static auto opCall()
	{
		DQueryAttributes!(QueryType, Attributes) attributes = void;
		return attributes;
	}

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

		auto query = DQueryAttributes!(QueryType, Attributes)();

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

		auto query = DQueryAttributes!(QueryType, Attributes)();

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
	template ensure(string Attr)
	if(Attr == "length")
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
