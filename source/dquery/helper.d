
module dquery.helper;

import std.functional;
import std.typetuple;

alias GetMember(Type, string Name) = Alias!(
	__traits(getMember, Type, Name)
);

/++
 + Returns a template predicate from a unary function.
 ++/
template UnaryToPred(alias Pred)
{
	alias UnaryToPred(alias Element) = Alias!(unaryFun!Pred(Element));
}
