
module dquery.attributes;

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

}
