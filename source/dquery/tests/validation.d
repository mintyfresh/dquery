
module dquery.tests.validation;

import dquery.d;

version(unittest)
{
	struct Entity
	{
	}

	struct Id
	{
	}

	struct Column
	{
		string value;
	}

	@Entity
	class User
	{

		@Id
		@Column
		ulong id;

		@Column("user_name")
		string username;

		@Column
		string email;

		this()
		{
		}

		this(User user)
		{

		}

		this(string username, string email)
		{
			this.username = username;
			this.email = email;
		}

		this(ulong id, string username, string email)
		{
			this.id = id;
			this.username = username;
			this.email = email;
		}

		string getCleanUsername()
		{
			import std.string : toUpper;
			return username.toUpper;
		}

	}
}

unittest
{
	auto query = query!User

		.attributes
		.anyOf!Entity
		.ensure!"length"
		.exactly!(1)
		.parent

		.fields
		.anyOf!Id
		.ensure!"length"
		.exactly!(1)
		.reset

		.fields
		.noneOf!Id
		.anyOf!Column
		.ensure!"length"
		.exactly!(2)
		.reset

		.constructors
		.parameters!()
		.ensure!"length"
		.exactly!(1)
		.reset

		.constructors
		.parameters!User
		.ensure!"length"
		.exactly!(1)
		.reset;
}
