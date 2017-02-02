**Update NGSTAR Schema Guide**

In the project folder, pull the latest code from the remote repository:

    git pull

Log into mysql:

    mysql -u root -p

Next, we will be updating the database schema for the `NGSTAR` database. Drop the current `NGSTAR` database:

    mysql> drop database NGSTAR;

Running `show databases;` should result in a list of database names that do not include `NGSTAR`.

Exit out of mysql and change directory to **ng-star/MySQLWorkbench/PopulateDatabaseStatements** and make sure that **NGSTAR_schema.sql** contain the latest schema.

Log into mysql:

    mysql -u root -p

Execute the SQL scripts to generate the database schema by using the source command:

    mysql> source NGSTAR_schema.sql

You should get multiple `Query OK` messages.

Check that the database was created by running the following command:

    mysql> show databases;

Run sql scripts to populate the `NGSTAR` database:

    mysql> source insert_classification_codes.sql
    mysql> source insert_loci.sql
    mysql> source insert_mic.sql
    mysql> source insert_onishi.sql
    mysql> source insert_amino_acids.sql

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

You have now updated the the NGSTAR database schema!
