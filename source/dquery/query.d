
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
	static auto reset()()
	{
		alias MapToElement(string Name) = Alias!(
			DQueryElement!(QueryType, Name)()
		);

		enum Elements = __traits(allMembers, QueryType);
		return DQuery!(QueryType, staticMap!(MapToElement, Elements))();
	}

	/++
	 + Property that returns the type's attributes.
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
	 + Property that returns the type's allowed attributes.
	 ++/
	@property
	static auto attributes(Allow...)()
	if(Allow.length > 0)
	{
		return attributes.allow!Allow;
	}

	@property
	static auto name(string Name)()
	{
		return names!Name;
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

		static if(query.length > 0)
		{
			return query.filter!(templateOr!(staticMap!(NameFilter, Names)));
		}
		else
		{
			return query;
		}
	}

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

	@property
	static auto arity(int Arity)()
	{
		return arities!Arity;
	}

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

	@property
	static auto fields()()
	{
		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(f => f.isField);
	}

	@property
	static auto fields(Names...)()
	if(Names.length > 0)
	{
		return fields.names!Names;
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
	static auto functions(Names...)()
	if(Names.length > 0)
	{
		return functions.names!Names;
	}

	@property
	static auto aggregates()()
	{
		auto query = DQuery!(QueryType, QueryElements)();
		return query.filter!(f => f.isAggregate);
	}

	@property
	static auto aggregates(Names...)()
	if(Names.length > 0)
	{
		return aggregates.names!Names;
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
