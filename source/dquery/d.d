
module dquery.d;

import std.traits;
import std.typetuple;

public import dquery.attribute;
public import dquery.attributes;
public import dquery.element;
public import dquery.helper;
public import dquery.overload;
public import dquery.query;

/++
 + Produces a query over the given type.
 +
 + Returns:
 +     A query over the supplied type.
 ++/
auto query(QueryType)()
{
	template MapToElement(string Name)
	{
		// Check for functions; each overload is kept as an element.
		static if(is(typeof(GetMember!(QueryType, Name)) == function))
		{
			alias MapToOverload(alias Overload) = Alias!(
				DQueryElement!(
					QueryType, Name, DQueryOverload!(
						arity!Overload, ReturnType!Overload, ParameterTypeTuple!Overload
					)()
				)()
			);

			alias MapToElement = staticMap!(
				MapToOverload, __traits(getOverloads, QueryType, Name)
			);
		}
		// Normal members.
		else
		{
			alias MapToElement = Alias!(DQueryElement!(QueryType, Name)());
		}
	}

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
