**Ubuntu Desktop Update Guide**

The following instructions are for updating the application currently installed on your local machine for development purposes. These instructions assume that you already have the application installed on your local machine. If your are just starting out with a clean machine, please refer to **Ubuntu_Desktop_Installation_Guide.md** in the documentation folder.

In the project folder, pull the latest code from the remote repository:

    git pull

Log into mysql by typing:

	mysql -u root -p

Next, we will be updating the database schema for the `NGSTAR` and `NGSTAR_Auth` database. Drop the current `NGSTAR` database:

    mysql> drop database NGSTAR;
    mysql> drop database NGSTAR_Auth;

Running `show databases;` should result in a list of database names that do not include `NGSTAR` and `NGSTAR_Auth`.

Exit out of mysql and change directory to **ng-star/MySQLWorkbench/PopulateDatabaseStatements** and make sure that **NGSTAR_schema.sql** and **NGSTAR_Auth_schema.sql** contain the latest schema for the databases.

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

Change directory to the top level of the ng-star project where you will find the **generate_db_models** script.

We will now generate database classes used by DBIx::Class. Set the script to have execute permissions:

    sudo chmod +x generate_db_models

Run the script:

    ./generate_db_models -d NGSTAR -u root -p mypassword

You should get output similar to this:

    NGSTAR::Schema::Result::TblSequenceType->has_many(
      "tbl_allele_sequence_types",
        "NGSTAR::Schema::Result::TblAlleleSequenceType",
          { "foreign.seq_type_id" => "self.seq_type_id" },
            { cascade_copy => 0, cascade_delete => 0 },
            );
    NGSTAR::Schema::Result::TblSequenceType->many_to_many("alleles", "tbl_allele_sequence_types", "allele");
    Dumping manual schema for NGSTAR::Schema to directory ./TestObjects ...
    Schema dump completed.
    Done

Change directory to **ng-star/BusinessLogic** and create a directory called **data** if it's not already there.

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

This will install the directory **DAL** and its contents to **/usr/local/share/perl/x.y.z/**
The NGSTAR Catalyst project will look for **DAL** packages in the **/usr/local/share/perl/x.y.z/** directory.

Now we will try running the NG-STAR development server. To do this, change directory to **ng-star/NGSTAR** and run the development server:

	script/ngstar_server.pl -r

Running the development server will also inform you of any errors. It will inform you of any missing perl modules. Install missing perl modules using cpanm.

Try out [localhost:3000](http://localhost:3000) in your web browser to see the main page of Catalyst.
Next, try out [localhost:3000/allele/form](http://localhost:3000/allele/form) to try out the NG-STAR project.

You can try logging in by using the credentials specified in **ng-star/MySQLWorkbench/PopulateDatabaseStatements/insert_users_and_roles.sql**

Congratulations! NG-STAR has now been updated on your local machine.
