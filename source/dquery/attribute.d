
module dquery.attribute;

struct DQueryAttribute(alias Attribute)
{

	@property
	alias attribute = Attribute;

	// Determine how to get the type.
	static if(is(typeof(Attribute)))
	{
		@property
		alias type = typeof(Attribute);
	}
	else
	{
		@property
		alias type = Attribute;
	}

	@property
	alias isTypeOf(Type) = Alias!(
		is(type == Type)
	);

	@property
	alias isTypeAssignableTo(Type) = Alias!(
		__traits(compiles, {
			type t1 = void;
			Type t2 = t1;
		})
	);

	@property
	alias isTypeAssignableTo(Type) = Alias!(
		__traits(compiles, {
			Type t1 = void;
			type t2 = t1;
		})
	);

}
