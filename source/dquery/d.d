
module dquery.d;

import std.typetuple;

public import dquery.attribute;
public import dquery.attributes;
public import dquery.element;
public import dquery.helper;
public import dquery.query;

auto query(QueryType)()
{
	alias MapToElement(string Name) = Alias!(
		DQueryElement!(QueryType, Name)()
	);

	enum Elements = __traits(allMembers, QueryType);
	return DQuery!(QueryType, staticMap!(MapToElement, Elements))();
}
