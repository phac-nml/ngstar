**Update NGSTAR_Auth Schema Guide**

In the project folder, pull the latest code from the remote repository:

    git pull

Log into mysql:

    mysql -u root -p

Next, we will be updating the database schema for the `NGSTAR_Auth` database. Drop the current `NGSTAR_Auth` database:

    mysql> drop database NGSTAR_Auth;

Running `show databases;` should result in a list of database names that do not include `NGSTAR_Auth`.

Exit out of mysql and change directory to **ng-star/MySQLWorkbench/PopulateDatabaseStatements** and make sure that **NGSTAR_Auth_schema.sql** contain the latest schema.

Log into mysql:

    mysql -u root -p

Execute the SQL scripts to generate the database schema by using the `source` command:

    mysql> source NGSTAR_Auth_schema.sql

You should get multiple `Query OK` messages.

Check that the database was created by running the following command:

    mysql> show databases;

Run sql scripts to populate the `NGSTAR_Auth` database:

    mysql> source insert_users_and_roles.sql
    mysql> source update_password.sql

You should get multiple `Query OK` messages.

Exit out of mysql:

    exit

Change directory to **NGSTAR/lib**. You should see a directory called **NGSTAR_Auth** that contains the database models for the `NGSTAR_Auth` database.

Delete the NGSTAR_Auth database models:

    rm -r NGSTAR_Auth

Change directory to **NGSTAR/**

Regenerate the NGSTAR_Auth database models by running the following command:

    script/ngstar_create.pl model DB DBIC::Schema NGSTAR_Auth::Schema create=static components=TimeStamp,PassphraseColumn dbi:mysql:NGSTAR_Auth 'ngstar' 'password' '{ AutoCommit => 1 }'

(Note: There is a typo in the Catalyst documentation where it says 'component' instead of 'components')

After running the command, you should get output similar to this:

    Dumping manual schema for NGSTAR_Auth::Schema to directory /home/user/ng-star/NGSTAR/script/../lib ...
    Schema dump completed.

Make sure that the `TimeStamp` and `PassphraseColumn` have been loaded in as components in the **NGSTAR_Auth/Schema/Result/User.pm** file:

    __PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

If you do not see the load_components line with `TimeStamp` and `PassphraseColumn`, it is likely that you made a mistake with the command to generate database models. Authentication will not work properly if `PassphraseColumn` is not specified in `load_components`.

Next, we must modify **lib/NGSTAR_Auth/Schema/Result/User.pm** and add the following code below the line `# DO NOT MODIFY THIS OR ANYTHING ABOVE!” but above the line “1;`

    # Have the 'password' column use a SHA-1 hash and 20-byte salt
    # with RFC 2307 encoding; Generate the 'check_password" method
    __PACKAGE__->add_columns(
        'password' => {
            passphrase       => 'rfc2307',
            passphrase_class => 'BlowfishCrypt',
            passphrase_args  => {
                cost        => 14,
                salt_random => 20,
            },
            passphrase_check_method => 'check_password',
        },
    );

Add all your updated code to staging using `git add` and push all your code to the remote repository (so that a `git clone` pulls the latest NGSTAR_Auth database models in the **NGSTAR_Auth** directory).

You have now updated the NGSTAR_Auth database schema!
