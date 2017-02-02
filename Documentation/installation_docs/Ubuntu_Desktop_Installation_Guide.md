**Ubuntu Desktop Installation Guide**

The following installation instructions are for performing a clean local install of the NGSTAR project on your Ubuntu machine.

Before installing any packages, run:

	sudo apt-get update

You must have all required dev tools (gcc, make, ...). To do this, run:

	sudo apt-get install build-essential

You will also need BLAST+. To install BLAST+, run the following command:

    sudo apt-get install ncbi-blast+

To install Catalyst, you will need:
(for version numbers, you will need that version number or higher)

	1. perl 5.8.6 or higher
	2. Catalyst::Runtime (5.90082)
	3. Catalyst::Devel (1.39)

Additional perl modules that are required and must be installed:

	1. Bio::Perl (1.6.924)
	2. Catalyst::Authentication::Store::DBIx::Class (0.1506)
	3. Catalyst::Controller::DBIC::API::REST (2.006002)
	4. Catalyst::Controller::REST (1.18)
	5. Catalyst::Helper::Model::Email (0.04)
	6. Catalyst::Model::Adaptor (0.10)
	7. Catalyst::Plugin::Authentication (0.10023)
	8. Catalyst::Plugin::Authorization::Roles (0.09)
	9. Catalyst::Plugin::Authorization::ACL (0.16)
	10. Catalyst::Plugin::AutoRestart (0.96)
	11. Catalyst::Plugin::ConfigLoader (0.34)
	12. Catalyst::Plugin::Session (0.40)
	13. Catalyst::Plugin::Session::State::Cookie (0.17)
	14. Catalyst::Plugin::Session::Store::FastMmap (0.16)
	15. Catalyst::Plugin::Session::Store::File (0.18)
	16. Catalyst::Plugin::Session::Store::DBI (0.16)
	17. Catalyst::Plugin::StackTrace (0.12)
	18. Catalyst::Plugin::Static::Simple (0.33)
	19. Catalyst::View::Email::Template (0.35)
	20. Catalyst::View::TT (0.42)
	21. Config::General (2.56)
	22. Crypt::CBC (2.33)
	23. DBIx::Class (0.082810)
	24. DBIx::Class::PassphraseColumn (0.02)
	25. DBIx::Class::Schema::Loader (0.07042)
	26. DBIx::Class::TimeStamp (0.14)
	27. Email::MIME (1.928)
    28. Email::Template (0.02)
	29. HTML::FormHandler (0.40057)
	30. Moose (2.1403)
	31. MooseX::NonMoose (0.26)
	32. namespace::autoclean (0.24)
	33. Readonly (2.00)
	34. String::Random (0.28)
	35. Template (2.26)
    36. Term::Size::Any (0.002)
	37. Test::Class (0.48)
	38. Test::More (1.001014)
	39. Session::Token (1.008)
	40. Catalyst::Helper::Model::Email (0.04)
	41. Mail::Builder::Simple (0.16)
	42. Text::Sprintf::Named (0.0402)
	43. Catalyst::Plugin::I18N (0.10)


These modules can easily be installed by using cpanm. If you don't have cpanm, install it by running:

	sudo apt-get install cpanminus

To install modules using cpanm, you would run:

	sudo cpanm put_module_name_here

(for example, sudo cpanm Test::More will install the Test::More module)

Install cpan-outdated:

    sudo cpanm cpan-outdated

Update any other cpan modules:

    cpan-outdated -p | sudo cpanm

A backup of required cpan modules are also available on [Google Drive](https://drive.google.com/folderview?id=0B9ZQet4QcnOMfkxmU0VCT2l2LV9KeldaLTRvaXl3Y3ZKbzdPWVRJZ19NelpBZFFSZVBFRDA&usp=sharing)

For additional information, see the [Installing Catalyst Guide](http://wiki.catalystframework.org/wiki/installingcatalyst)

Next, pull the latest version of NGSTAR from GitLab.

The main ng-star directory contains:

**BusinessLogic** – a separate Perl module that houses any business logic (such as logic that does BLAST to perform an allele type query. It acts as the BusinessLogic layer and is independent of Catalyst.

**DAL** – short for Data Access Layer, it is a separate Perl module that contains any queries to the database. Instead of using plain SQL to query the database, an ORM called DBIx::Class is used. This layer is independent from Catalyst.

**DatabaseObjects** – a directory that contains all classes for our database (used by DBIx::Class).

**generate_db_models** – is a shell script that runs a command that generates our database classes contained in the DatabaseObjects directory (database objects are needed since we are using the ORM DBIx::Class).

**Documentation** – contains installation guides for installing NGSTAR on a local machine.

**MySQLWorkbench** – contains MySQL Workbench models and SQL files used to update the NGSTAR database schema and its contents on a local machine.

**NGSTAR** – The NGSTAR Catalyst project, it acts more like a Presentation Layer and has a very thin model. It makes calls to the BusinessLogic by utilizing an Adapter pattern.

To begin, we will install the database back-end. You will need both the mysql client and server as well as MySQL Workbench.

First, update the package repository by running the command:

	sudo apt-get update

Next, to install mysql client and mysql server, run the following command:

	sudo apt-get install mysql-client mysql-server

When installing mysql-server, it will prompt you to enter a root password. Make sure to remember this root password.

Change directory to **ng-star/MySQLWorkbench/PopulateDatabaseStatements** and make sure that **NGSTAR_schema.sql** and **NGSTAR_Auth_schema.sql** contain the latest schema for the databases.

Log into mysql:

    mysql -u root -p

Execute the SQL scripts to generate the database schema by using the `source` command:

    mysql> source NGSTAR_schema.sql
    mysql> source NGSTAR_Auth_schema.sql

You should get multiple `Query OK` messages.

Check that the databases were created by running the following command:

    mysql> show databases;

Run sql scripts to populate the `NGSTAR` and `NGSTAR_Auth` databases:

    mysql> source insert_classification_codes.sql
    mysql> source insert_loci.sql
    mysql> source insert_mic.sql
    mysql> source insert_onishi.sql
    mysql> source insert_amino_acids.sql
    mysql> source insert_users_and_roles.sql
    mysql> source update_password.sql

You should get multiple `Query OK` messages.

Exit out of mysql:

    exit

The `NGSTAR` and `NGSTAR_Auth` databases have now been populated with some initial values.

Now that the `NGSTAR` database has been populated, we will now generate the `NGSTAR` database classes used by DBIx::Class.

Ensure that the **generate_db_obj** script in the directory **ng-star/** has execute permissions by running the following command:

	sudo chmod +x generate_db_obj

Run the **generate_db_obj** script by supplying it with the name of the `NGSTAR` database, as well as the username and password that you use for MySQL.

	./generate_db_obj -d mydatabasename -u myusername -p mypassword

In our case, mydatabasename is `NGSTAR` and for myusername and mypassword, you can try `root` and your mysql root password respectively.

After running this command, you should get output similar to this:

	...
	NGSTAR::Schema::Result::TblAlleleSequenceType->belongs_to(
	  "seq_type",
	  "NGSTAR::Schema::Result::TblSequenceType",
	  { seq_type_id => "seq_type_id" },
	  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
	);
	NGSTAR::Schema::Result::TblSequenceType->has_many(
	  "tbl_allele_sequence_types",
	  "NGSTAR::Schema::Result::TblAlleleSequenceType",
	  { "foreign.seq_type_id" => "self.seq_type_id" },
	  { cascade_copy => 0, cascade_delete => 0 },
	);
	NGSTAR::Schema::Result::TblSequenceType->many_to_many("alleles", "tbl_allele_sequence_types", "allele");
	Dumping manual schema for NGSTAR::Schema to directory ./TestObjects ...
	Schema dump completed.

You should now have a directory called **DatabaseObjects** which contains classes pertaining to the `NGSTAR` database on your local machine.

Next, change directory to **ng-star/BusinessLogic** and create a directory called **data** if it doesn't already exist. This **data** directory is used by BLAST+ to temporarily store BLAST database files. These files are automatically deleted by our business logic code after it has finished processing them but we are still required to have this directory.

    mkdir data


Next, we will have to change some of the hardcoded values in **ng-star/NGSTAR/ngstar.conf**:


	**reset_password_link http://localhost:3000/resetpassword**

	**curator_email curator@localhost**
	**curator_email_host smtp.localhost**
	**curator_email_password curator_email_password**
	**account_services_email accountservices@locahost**
	**allowed_ips admin_access_ips**

	**db_user your_sql_username**
	**db_password your_sql_password**

	**auth_db_user your_sql_username**
	**auth_db_password your_sql_password**

	**businesslogic_data_path /pathTo/ng-star/BusinessLogic/data/**
	**businesslogic_data_stub_path /pathTo/ng-star/BusinessLogic/data_stub/**

	**dal_databaseobjects_path /pathTo/ng-star/DatabaseObjects**


Now, you must install the **BusinessLogic** and **DAL** perl modules.

Install the **BusinessLogic** module by changing directory to **ng-star/BusinessLogic/** and running the following commands:

	perl Makefile.PL
	make
	sudo make install

This will install the directory **BusinessLogic** and its contents to **/usr/local/share/perl/x.y.z/**
The NGSTAR Catalyst project will look for **BusinessLogic** packages in the **/usr/local/share/perl/x.y.z/** directory.

Install the **DAL** module by changing directory to **ng-star/DAL/** and running the following commands:

	perl Makefile.PL
	make
	sudo make install

This will install the directory DAL and its contents to **/usr/local/share/perl/x.y.z/**
The NGSTAR Catalyst project will look for DAL packages in the **/usr/local/share/perl/x.y.z/** directory.

Now we will try running the NGSTAR development server. To do this, change directory to **ng-star/NGSTAR** and run the development server:

	script/ngstar_server.pl -r

Running the development server will also inform you of any errors. It will inform you of any missing perl modules. Install missing perl modules using cpanm.

Try out [localhost:3000](http://localhost:3000) in your web browser to see the main page of Catalyst.
Next, try out [localhost:3000/allele/form](http://localhost:3000/allele/form) to try out the NGSTAR project.

You can try logging in by using the credentials specified in **ng-star/MySQLWorkbench/PopulateDatabaseStatements/insert_users_and_roles.sql**

Congratulations! NGSTAR has now been installed on your local machine.
