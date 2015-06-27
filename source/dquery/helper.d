
module dquery.helper;

import std.functional;
import std.typetuple;

alias GetMember(Type, string Name) = Alias!(
	__traits(getMember, Type, Name)
);

alias GetProtection(Type, string Name) = Alias!(
	__traits(getProtection, __traits(getMember, Type, Name))
);

alias GetAttributes(alias Target) = Alias!(
	__traits(getAttributes, Target)
);

alias GetAttributes(Type, string Name) = Alias!(
	__traits(getAttributes, __traits(getMember, Type, Name))
);

/++
 + Returns a template predicate from a unary function.
 ++/
template UnaryToPred(alias Pred)
{
	alias UnaryToPred(alias Element) = Alias!(unaryFun!Pred(Element));
}

template Compare(XList...)
{
	template With(YList...)
	if(XList.length > 0 && XList.length == YList.length)
	{
		enum With = (
			__traits(compiles, {
				static assert(is(XList[0] == YList[0]));
			}) ||
			__traits(compiles, {
				static assert(XList[0] == YList[0]);
			})
		) &&
		Compare!(XList[1 .. $]).With!(YList[1 .. $]);
	}

	template With(YList...)
	if(XList.length == 0 && YList.length == 0)
	{
		enum With = true;
	}

	template With(YList...)
	if(XList.length != YList.length)
	{
		enum With = false;
	}
}
