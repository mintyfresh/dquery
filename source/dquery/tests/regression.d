
module dquery.tests.regression;

import dquery.d;

struct Attr
{
}

struct Limit
{
	int value;
}

struct None
{
}

struct Coord
{

	@Attr
	@Limit(10)
	int x;

	@Attr
	@Limit(10)
	int y;

	@Attr
	@Limit(10)
	int z;

	int tmp;

	this(int x, int y, int z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	int[3] getCoords()
	{
		return [x, y, z];
	}
}

unittest
{
	auto query = query!Coord;

	// Should not be empty.
	static assert(!query.empty);

	// Should have 6 elements.
	static assert(query.length == 6);

	auto fields = query.fields;

	// Should match parent type.
	static assert(is(fields.type == query.type));

	// Should not be empty.
	static assert(!fields.empty);

	// Should have 4 elements.
	static assert(fields.length == 4);

	foreach(element; fields)
	{
		// Should match parent type.
		static assert(is(element.type == fields.type));

		static if(element.name != "tmp")
		{
			// Should have attribute Attr.
			static assert(element.hasAttribute!Attr);

			// Should have attribute Limit.
			static assert(element.hasAttribute!Limit);

			// Should not have attribute None.
			static assert(!element.hasAttribute!None);

			// Should not have nonexistent elements.
			static assert(element.attributes.allow!None.empty);

			// Should not have forbidden elements.
			static assert(element.attributes.forbid!(Attr, Limit).empty);

			foreach(attribute; element.attributes.allow!Attr)
			{
				// Should be a type attribute.
				static assert(attribute.isType);

				// Should not be an expression attribute.
				static assert(!attribute.isExpression);

				// Should be type Attr.
				static assert(attribute.isTypeOf!Attr);

				// Should not be type None.
				static assert(!attribute.isTypeOf!None);

				// Should be assignable to Attr.
				static assert(attribute.isTypeAssignableTo!Attr);

				// Should not be assignable to None.
				static assert(!attribute.isTypeAssignableTo!None);

				// Should be assignable from Attr.
				static assert(attribute.isTypeAssignableFrom!Attr);

				// Should not be assignable from None.
				static assert(!attribute.isTypeAssignableFrom!None);
			}

			foreach(attribute; element.attributes.allow!Limit)
			{
				// Should be a type attribute.
				static assert(!attribute.isType);

				// Should not be an expression attribute.
				static assert(attribute.isExpression);

				// Should be type Limit.
				static assert(attribute.isTypeOf!Limit);

				// Should not be type None.
				static assert(!attribute.isTypeOf!None);

				// Should be assignable to Limit.
				static assert(attribute.isTypeAssignableTo!Limit);

				// Should not be assignable to None.
				static assert(!attribute.isTypeAssignableTo!None);

				// Should be assignable from Limit.
				static assert(attribute.isTypeAssignableFrom!Limit);

				// Should not be assignable from None.
				static assert(!attribute.isTypeAssignableFrom!None);
			}
		}
		else
		{
			// Should not have attribute Attr.
			static assert(!element.hasAttribute!Attr);

			// Should not have attribute Limit.
			static assert(!element.hasAttribute!Limit);

			// Should not have attribute None.
			static assert(!element.hasAttribute!None);

			// Should not have nonexistent elements.
			static assert(element.attributes.allow!None.empty);

			// Should not have allowed but nonexistent elements.
			static assert(element.attributes.allow!(Attr, Limit).empty);

			// Should not have forbidden elements.
			static assert(element.attributes.forbid!(Attr, Limit).empty);
		}

		// Should have public protection.
		static assert(element.protection == "public");

		// Should be a field.
		static assert(element.isField);

		// Should be an int.
		static assert(element.isTypeOf!int);

		// Should be not a ulong.
		static assert(!element.isTypeOf!ulong);

		// Should be assignable to int.
		static assert(element.isTypeAssignableTo!int);

		// Should be assignable to ulong.
		static assert(element.isTypeAssignableTo!ulong);

		// Should be assignable from int.
		static assert(element.isTypeAssignableFrom!int);

		// Should not be assignable from ulong.
		static assert(!element.isTypeAssignableFrom!ulong);

		// Should not be a function.
		static assert(!element.isFunction);

		// Should compile but not have arity 0.
		static assert(__traits(compiles, {
			static assert(!element.isArity!0);
		}));

		// Should compile but not return an int.
		static assert(__traits(compiles, {
			static assert(!element.isReturnType!int);
		}));

		// Should not be an aggregate.
		static assert(!element.isAggregate);

		// Should not be a class.
		static assert(!element.isClass);

		// Should not be a struct.
		static assert(!element.isStruct);
	}

	auto namedFields = fields.names!("x", "z");

	// Should match parent type.
	static assert(is(namedFields.type == fields.type));

	// Should not be empty.
	static assert(!namedFields.empty);

	// Should have 2 elements.
	static assert(namedFields.length == 2);

	foreach(element; namedFields)
	{
		// Should match parent type.
		static assert(is(element.type == namedFields.type));

		// Should not be field y.
		static assert(element.name != "y");

		// Should be one of fields x or z.
		static assert(element.name == "x" || element.name == "z");
	}

	auto allowedFields = fields.allow!Attr;

	// Should match parent type.
	static assert(is(allowedFields.type == fields.type));

	// Should not be empty.
	static assert(!allowedFields.empty);

	// Should have 3 elements.
	static assert(allowedFields.length == 3);

	foreach(element; allowedFields)
	{
		// Should match parent type.
		static assert(is(element.type == allowedFields.type));

		// Should not be field tmp.
		static assert(element.name != "tmp");

		// Should have attribute Attr.
		static assert(element.hasAttribute!Attr);
	}

	auto forbiddenFields = fields.forbid!Limit;

	// Should match parent type.
	static assert(is(forbiddenFields.type == fields.type));

	// Should not be empty.
	static assert(!forbiddenFields.empty);

	// Should have 1 element.
	static assert(forbiddenFields.length == 1);

	foreach(element; forbiddenFields)
	{
		// Should match parent type.
		static assert(is(element.type == forbiddenFields.type));

		// Should be field tmp.
		static assert(element.name == "tmp");

		// Should have attribute Other.
		static assert(!element.hasAttribute!Limit);

		// Should have no attributes.
		static assert(element.attributes.empty);
	}

	auto functions = query.functions;

	// Should not be empty.
	static assert(!functions.empty);

	// Should have 2 elements.
	static assert(functions.length == 2);

	foreach(element; functions)
	{
		// Should match parent type.
		static assert(is(element.type == fields.type));

		// Should not have attribute Attr.
		static assert(!element.hasAttribute!Attr);

		// Should not have attribute Limit.
		static assert(!element.hasAttribute!Limit);

		// Should not have attribute None.
		static assert(!element.hasAttribute!None);

		// Should not have nonexistent elements.
		static assert(element.attributes.allow!None.empty);

		// Should not have forbidden elements.
		static assert(element.attributes.forbid!(Attr, Limit).empty);

		// Should have public protection.
		static assert(element.protection == "public");

		// Should not be a field.
		static assert(!element.isField);

		// Should be an int.
		static assert(!element.isTypeOf!int);

		// Should be not a ulong.
		static assert(!element.isTypeOf!ulong);

		// Should be assignable to int.
		static assert(!element.isTypeAssignableTo!int);

		// Should be assignable to ulong.
		static assert(!element.isTypeAssignableTo!ulong);

		// Should be assignable from int.
		static assert(!element.isTypeAssignableFrom!int);

		// Should not be assignable from ulong.
		static assert(!element.isTypeAssignableFrom!ulong);

		// Should be a function.
		static assert(element.isFunction);

		static if(element.name == "__ctor")
		{
			// Should compile and have arity 3.
			static assert(__traits(compiles, {
				static assert(!element.isArity!3);
			}));
		}
		else static if(element.name == "getCoords")
		{
			// Should compile and have arity 0.
			static assert(__traits(compiles, {
				static assert(!element.isArity!0);
			}));
		}
		else
		{
			// Should not have any other elements.
			static assert(0, "Unexpected element " ~ element.name);
		}

		static if(element.name == "__ctor")
		{
			// Should compile but not return an int.
			static assert(__traits(compiles, {
				static assert(!element.isReturnType!int);
			}));

			// Should compile but and return a Coord.
			static assert(__traits(compiles, {
				static assert(element.isReturnType!Coord);
			}));
		}
		else static if(element.name == "getCoords")
		{
			// Should compile but not return an int.
			static assert(__traits(compiles, {
				static assert(!element.isReturnType!int);
			}));

			// Should compile but and return an int array.
			static assert(__traits(compiles, {
				static assert(element.isReturnType!(int[3]));
			}));
		}
		else
		{
			// Should not have any other elements.
			static assert(0, "Unexpected element " ~ element.name);
		}

		// Should not be an aggregate.
		static assert(!element.isAggregate);

		// Should not be a class.
		static assert(!element.isClass);

		// Should not be a struct.
		static assert(!element.isStruct);
	}

	auto aggregates = query.aggregates;

	// Should be empty.
	static assert(aggregates.empty);
}
