**CentOS Server Release Guide**

The following instructions are for updating the application currently deployed on a CentOS server. These instructions assume that you already have the application deployed on a server. If you are just starting out with a clean server, please refer to **Centos_Server_Installation_Guide.md** in the documentation folder.

First, backup the contents of the `NGSTAR` database in MySQL server (we would like the client to still have access to all of their data even after we have deployed the new version of the software).

We will create a logical backup of the contents of the `NGSTAR` database using a tool called mysqldump. mysqldump generates the corresponding SQL statements (such as `CREATE TABLE` and `INSERT`) which is capable of reproducing the entire database schema and populating the reproduced schema with its contents.

More information on mysqldump can be viewed here: http://dev.mysql.com/doc/refman/5.6/en/mysqldump.html

In the home directory, create a directory that will be used to store logical backups:

    mkdir db_backup

Let's take a look at what output mysqldump produces when you try to dump the `NGSTAR` database:

    mysqldump -u root -p NGSTAR

You will see multiple `CREATE TABLE` and `INSERT` statements that form a logical backup of the `NGSTAR` database.

We want to save the output to a file, so redirect the output produced by mysqldump to a file called **backup.sql**. Run this command in your home directory:

    mysqldump -u root -p NGSTAR > db_backup/NGSTAR_backup.sql
    mysqldump -u root -p NGSTAR_Auth > db_backup/NGSTAR_Auth_backup.sql

If you want, you may also create a backup of the sequences and profiles stored in the database by utilizing the Download Alleles and Download Profiles functionality in the actual application.

You need to stop the tmux session that is running plack and the starman server:

To list your tmux sessions run the following command:

    tmux ls

Attach to the tmux session running plack and starman using the following command:

    tmux a -t my_session_name

Stop the starman server by typing `Ctrl-C`

Detach from the tmux session by typing `Ctrl-b` followed by `d`.

It may be a good idea to replace the application (which is no longer running) with a placeholder that specifies the the site will be down for a while for updating (so that the client doesn't get confused).

We will now pull the latest code in all branches.

Change directory to the top level of the ng-star project.

Make git overwrite any local files when pulling:

    git fetch --all
    git reset --hard origin/my_branch_name

Do this for each branch by checking each branch out and running git pull:

    git checkout my_branch_name
    git pull

Checkout the branch that your server corresponds to. If you are the `ngstar-uat` server then run the following command:

    git checkout master

If you are on the `ngstar-dev` server then run the following command:

    git checkout development

Verify that you are on the correct branch by running the following command:

    git branch

Change directory to **ng-star/NGSTAR** and configure **ngstar.psgi** so that it looks like this:

    use strict;
    use warnings;

    use lib '/home/myusername/ng-star/NGSTAR/lib';
    use NGSTAR;

    my $app = NGSTAR->apply_default_middlewares(NGSTAR->psgi_app);
    $app;

Configure the nginx settings so that the contents of **nginx.conf** look like this:

    user  nginx;
    worker_processes  1;

    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;


    events {
        worker_connections  1024;
    }


    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
        '$status $body_bytes_sent "$http_referer" '
        '"$http_user_agent" "$http_x_forwarded_for"';

        access_log  /var/log/nginx/access.log  main;

        sendfile        on;
        #tcp_nopush     on;

        keepalive_timeout  65;

        #gzip  on;

        include /etc/nginx/conf.d/*.conf;

        server {
            server_name ngstar-uat.corefacility.ca
            listen 80;

            location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://localhost:5005;
            }

            location /images/ {
                alias /home/myusername/ng-star/NGSTAR/root/static/images/;
                expires 30d;
                access_log off;
            }
        }
    }

If you had to make changes, you will need to restart nginx to have the changes reflected:

    sudo service nginx restart

Next, we will be updating the database schema for the `NGSTAR` and `NGSTAR_Auth` database. Drop the current NGSTAR database:

    mysql -u root -p

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


Next, we will have to change some of the hardcoded values in **ng-star/NGSTAR/ngstar.conf** to the following:

    **reset_password_link http://localhost/resetpassword**


    **curator_email curator@localhost**
	**curator_email_host smtp.localhost**
	**curator_email_password curator_email_password**
	**account_services_email accountservices@locahost**
	**allowed_ips admin_access_ips**

    **db_user root**
    **db_password mypassword**

    **auth_db_user root**
    **auth_db_password mypassword**

    **businesslogic_data_path /home/irish_m/ng-star/BusinessLogic/data/**
    **businesslogic_data_stub_path /home/irish_m/ng-star/BusinessLogic/data_stub/**

    **dal_databaseobjects_path /home/irish_m/ng-star/DatabaseObjects**


Install the **BusinessLogic** and **DAL** modules by running the script **install_modules_centos** in the ng-star directory. First, you may need to change some hardcoded paths in the script to what is appropriate:

    vim install_modules_centos

Make any changes and save the file.

Then give the file execute permissions:

    sudo chmod +x install_modules_centos

Next, run the script to install the modules to the default perl module directory:

    ./install_modules_centos

Alternatively, you can install the modules manually (skip this step if you used the **install_modules_centos** script to install the **BusinessLogic** and **DAL** modules automatically):

Change directory to **ng-star/BusinessLogic/lib** and copy the **BusinessLogic** folder and its contents to **/usr/local/share/perl5**:

    sudo cp -r BusinessLogic/ /usr/local/share/perl5

Change directory to **ng-star/DAL/lib** and copy the **DAL** folder and its contents to **/usr/local/share/perl5**:

    sudo cp -r DAL/ /usr/local/share/perl5

Change directory to **/usr/local/share/perl5** and verify that the directories and contents of **BusinessLogic** and **DAL** are present.

    cd /usr/local/share/perl5

If you have any applications (such as a page notifying the client that the site will be down for a while) running on port 5005, stop that now.

List all tmux sessions:

    tmux ls

Attach to the tmux session which you used previously to run the starman server:

    tmux a -t my_session_name

Go to **ng-star/NGSTAR** and start Starman and plack:

    plackup -s Starman -l :5005 ngstar.psgi

Ensure that there are no error messages near the beginning of the output by typing `Ctrl-b` followed by `]` and scrolling up.

Exit tmux scroll mode by pressing Esc multiple times. Make sure that you are out of scroll mode before continuing, otherwise your application will not run.

To persist the Starman server after logging out of the VM, you need to detach from the current tmux session by typing `Ctrl-b` followed by `d`

You should now be detached from the ngstar tmux session.

Verify that you have an ngstar tmux session running:

    tmux ls

You should now see the NGSTAR Catalyst test page at http://ngstar-uat.corefacility.ca/ (or similar)

To go to the main NGSTAR page, go to http://ngstar-uat.corefacility.ca/allele/form

You may need to clear your browsers cache to view design changes. On Firefox, you can clear the cache by going to Preferences, Advanced, Network, clicking on Clear Now in the Cached Web Content section and restarting your browser.

Next, try logging in to test out the application.

**Log out and run all tests to see if they pass.**

We will now restore the previous contents of the database. First, change directory to **db_backup** in your home directory.

Remove any lines of code for creating tables (since we have already generated the updated schema) or inserting values into tables that have already been populated previously, such as sql statements for inserting values into `tbl_IsolateClassification`, `tbl_Loci` and `tbl_MIC`.

If the database schema has changed in anyway (such as a column being added or removed), you may have to update the `INSERT` statements appropriately.

Next, log into mysql and run the following command:

    mysql -u root -p mypassword
    mysql> source NGSTAR_backup.sql

Populate the `NGSTAR_Auth` database to include previous user accounts as specified in **NGSTAR_Auth_backup.sql**

The database should now contain the contents that existed in the database previously.
