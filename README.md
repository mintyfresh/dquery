
dquery - Chainable compile-time metaprogramming
===============================================

dquery is a light helper for processing types, traits, and other information at compile time. It provides filtering, mapping, iteration, and validation functions for queried types and members.

Example Code
------------

Here's a little demo class we're going to query in these examples. Assume the types for `@Id` and `@Column` are structs defined elsewhere. 

```d
class User
{
    @Id
    @Column
    ulong id;

    @Column
    string username;

    @Column("email_address")
    string email;
}
```

### Queries

The `query!()` template function produces a query for a type. This is the starting point for every dquery chain.

```d
auto elements = query!User;
```

You can also query a type from a value via the `query()` function, shown here using UFCS.

```d
User user = new User;

auto elements = user.query;
```

### Simple Filters

dquery provides filters for the 5 common types of members defined in types; fields, functions, constructors, destructors, and aggregates.

```d
// Filter fields in User.
auto fields = query!User.fields;

// Filter functions in User.
auto functions = query!User.functions;

// Filter constructors in User.
auto constructors = query!User.constructors;

// Filter destructors in User.
auto destructors = query!User.destructors;

// Filter inner types in User.
auto aggregates = query!User.aggregates;
```

You also get a number of filters for common information about elements of a types, such as filters for names, types, return types, arity, parameter lists, etc.

```
    query!Type

        // Filter only names,
        .names!("foo", "bar")

        // Filter types,
        .types!(int, string, bool)

        // Filter return types,
        .returns!(int, string, bool)

        // Filter accessible elements,
        .accessible

        // Filter arities,
        .arities!(0, 1, 2)

        // Filter functions that take (int, string, bool),
        .parameters!(int, string, bool)

        // Filter elements that have @A and @B and @C,
        .allOf!(A, B, C)

        // Filter elements that have @A or @B or @C,
        .anyOf!(A, B, C)

        // Filter elements that don't have @A or @B or @C,
        .noneOf!(A, B, C);
```

### Simple Attribute Information

Easily check for attributes on any type or element.

```d
auto userQuery = query!User;

// True if type User has @A and @B and @C.
bool hasAll = userQuery.hasAllOf!(A, B, C);

// True if type User has @A or @B or @C.
bool hasAny = userQuery.hasAnyOf!(A, B, C); 

// True if type User has none of @A or @B or @C.
bool hasNone = userQuery.hasNoneOf!(A, B, C);

// Returns attributes attached to the User type.
auto attributes = query!User.attributes;
```

### Transformations

dquery includes a `filter!()` for custom or advanced filtering in chains.

```d
auto elements =
    query!User

        // Custom filter.
        .filter!(element =>
            element.isTypeOf!string ||
            element.hasAttribute!Id
        );
```

dquery also includes a `map!()` transform function for transforming the result of a chain.

```d
string[] names =
    query!User

        // Filter fields,
        .fields

        // That have @Id or @Column,
        .anyOf!(Id, Column)

        // Map to their names.
        .map!(field => field.name);
```

All dquery transform functions can take a function or delegate, or a template.

### Simple Validations

dquery also provides simple functions to perform validations without breaking chains.

```d
auto elements =
    query!User

        // Filter fields,
        .fields

        // That have @Id and @Column,
        .allOf!(Id, Column)

        // Ensure exactly 1 exists.
        .ensure!"length"
            .exactly!(1, "User needs exactly 1 @Id.");
```

### Chaining Logic

dquery focuses on chaining so that complex logic can be broken down into simple sequences like, 

```d
auto elements =
    query!User

        // Filter constructors,
        .constructors

        // With arity 0,
        .arity!(0)

        // Ensure at least 1 exists,
        .ensure!"length"
            .minimum!(1, "User needs a 0 argument constructor.")

        // Clear filters,
        .reset

        // Filter constructors,
        .constructors

        // That accept User,
        .parameters!(User)

        // Ensure none exist.
        .ensure!"length"
            .maximum!(0, "User must not define a copy constructor.");
```

### Loops and Iteration

Query results can be iterated over with a `foreach`.

```d
foreach(element; elements)
{
    static if(element.isTypeOf!string)
    {
        // Handle fields.
    }
    else
    {
        // Do something else.
    }
}
```

You can also use the `each!()` template function to iterate over results without breaking a chain.

```d
auto elements =
    query!User

        // Filter fields,
        .fields

        // That have @Id or @Column,
        .anyOf!(Id, Column)

        // Ensure at least 1 exists.
        .ensure!"length"
            .minimum!(1, "User needs at least 1 @Id or @Column.")

        // Do something for each,
        .each!(
            field => doSomething(field)
        )

        // Keep going...
        .reset;
```

### Joining Results

Mutliple chains can be joined together to produce even more complex queries easily.

```d
auto elements =
    query!User

        // Filter fields,
        .fields

        // That have @Id or @Column,
        .anyOf!(Id, Column)

        // And are a string,
        .types!string

        // Join with,
        .join(
            query!User

                // Filter functions,
                .functions

                // With both @Column and @Mappable,
                .allOf!(Column, Mappable)

                // And arity 0,
                .arity!0

                // That return a string.
                .returns!string
        );
```

You can also use a query's `unique` property to remove any duplicate elements.

### Attributes

dquery also provides functions for handling attributes attached to queried types and elements.

```d
// Iterate over the list of elements,
foreach(element; elements)
{
    // Iterate over each attribute that is a @Column,
    foreach(attribute; element.attributes!Column)
    {
        // Get value of attribute, or use a fallback if it's a type.
        Column column = attribute.getOrElse!(Column(element.name));

        // . . .
    }
}
```

In addition to `getOrElse!(Default)`, attributes provide a `get` method (defined only for expressions), and a `getOrThrow!(Exception)` which throws an exception at runtime if the attribute is not an expression.

Limitations
-----------

Because of how traits are setup in D, dquery can't operate on private or protected types, fields, or functions. Inaccessible members only provide limited information.

License
-------

MIT
