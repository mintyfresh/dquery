
module dquery.d;

import std.typetuple;

public import dquery.attribute;
public import dquery.attributes;
public import dquery.element;
public import dquery.helper;
public import dquery.query;

/++
 + Produces a query over the given type.
 +
 + Returns:
 +     A query over the supplied type.
 ++/
auto query(QueryType)()
{
	alias MapToElement(string Name) = Alias!(
		DQueryElement!(QueryType, Name)()
	);

	enum Elements = __traits(allMembers, QueryType);
	return DQuery!(QueryType, staticMap!(MapToElement, Elements))();
}

/++
 + Produces a query over the type of the supplied parameter.
 +
 + Params:
 +     value = A parameter to type query.
 +
 + Returns:
 +     A query over the parameter's type.
 ++/
auto query(QueryType)(QueryType value)
{
	return query!QueryType;
}
