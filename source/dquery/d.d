
module dquery.d;

import std.typetuple;

public import dquery.attribute;
public import dquery.attributes;
public import dquery.element;
public import dquery.helper;
public import dquery.query;

auto query(QueryType)()
{
	template MapToElement(string Name)
	{
		auto MapToElementImpl()
		{
			DQueryElement!(QueryType, Name) element = void;
			return element;
		}

		alias MapToElement = Alias!(MapToElementImpl());
	}

	DQuery!(QueryType, __traits(allMembers, QueryType)) query = void;
	return query.map!MapToElement;
}
