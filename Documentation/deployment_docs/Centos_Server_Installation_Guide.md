**CentOS Server Installation Guide**

The following installation instructions are for installing NGSTAR on a CentOS server. If you don't have a CentOS server set up, you will need to consult Bioinformatics IT to set one up for you.

Note that we are installing on a server with the hostname ngstar-uat. If the hostname of the CentOS server you are installing on is different, then replace all instances of ngstar-uat with the hostname of your CentOS server.

Log into the VM remotely:

    ssh my_ldap_username@ngstar-uat.corefacility.ca

Once you have logged in with with your LDAP credentials, upgrade the CentOS system software:

    sudo yum update

It is a good idea to get familiar with tmux. It allows you to open multiple terminal sessions in the VM without requiring you to log in again in a different terminal. Install tmux by running the following command:

    sudo yum install tmux

Check out these tmux tutorials:

https://danielmiessler.com/study/tmux/
http://code.tutsplus.com/tutorials/intro-to-tmux--net-33889

Add the CentOS 7 nginx yum repository. If you are not using CentOS 7, then you will need to find the correct nginx yum repository for your distribution. If the link is broken you will need to find the updated link:

    sudo rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

Install nginx:

    sudo yum install nginx

Start nginx:

    sudo systemctl start nginx.service

Configure nginx to start when the system boots:

    sudo systemctl enable nginx.service

You should be able to see a test page by visiting http://ngstar-uat.corefacility.ca on your browser.
If not, you will need to call up Bioinformatics IT to open up port 80 so that our server can listen to HTTP requests.

Install all required dev tools:

    sudo yum install make automake gcc gcc-c++ kernel-devel
    sudo yum groupinstall "Development Tools"

Install vim:

    sudo yum install vim

Install cpan:

    sudo yum install cpan

Install the Time HiRes perl module:

    sudo yum install perl-Time-HiRes

When you install cpan modules and it asks you for some options, just press enter (without entering anything). This will select the default option. Do this each time cpan prompts you for an option.
When installing cpan modules you will get output from unit tests. Some will be skipped because you don't have some dependencies, which is fine.

Install the following perl modules using cpan:

    sudo cpan local::lib
    sudo cpan autodie
    sudo cpan Module::Install
    sudo cpan Catalyst::Runtime
    sudo cpan Catalyst::Devel
    sudo cpan Task::Plack
    sudo cpan Starman

For local::lib, you may get an error when installing it the first time. Try installing it again using cpan a second time to see if you can get it to work.

In your home directory, create a Catalyst test application called Hello:

    cd ~
    catalyst.pl Hello

Change directory into the main project directory:

    cd Hello

In the project main folder, install app dependencies:

    perl Makefile.PL
    make

Configure **hello.psgi** settings using vim. Add the `use lib` line so that **hello.psgi** looks like this:

    use strict;
    use warnings;

    use lib '/home/myusername/Hello/lib'; #or equivalent
    use MyAppName;

    my $app = Hello->apply_default_middlewares(Hello->psgi_app);
    $app;

Open the nginx settings for editing:

    sudo vim /etc/nginx/nginx.conf

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
            server_name ngstar-uat.corefacility.ca #set server_name to the hostname of your VM
            listen 80;

            location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://localhost:5005;
            }

            location /images/ {
                alias /home/myusername/Hello/root/static/images/; #set alias to the appropriate path of your images folder
                expires 30d;
                access_log off;
            }
        }
    }

You will need to restart nginx to have the changes reflected:

    sudo service nginx restart

You need to install semanage to configure SELinux:

    sudo yum install policycoreutils-python

Set SELinux to allow the webserver to make an outbound connection to port 5005 (you may have to wait a moment for the command to complete):

    sudo semanage port --add --type http_port_t --proto tcp 5005

Verify that port 5005 was added by running:

    sudo semanage port --list | grep '5005'

Change directory to the main project directory and run the following command:

    plackup -s Starman -l :5005 myappname.psgi

You should see a test page of the Hello application on your browser when you go to http://ngstar-uat.corefacility.ca

For now, stop plack and starman by typing `Ctrl-C`

To keep plackup and starman running you need to use tmux. Start a new tmux on the VM with the name `hello` by running the following command:

    tmux new-session -s hello

In the tmux session, run plack and starman again:

    plackup -s Starman -l :5005 myappname.psgi

Next you need to detach the tmux session by typing `Ctrl-b` and then by pressing the `d` button.

You should be outside of a tmux session. You can now logout of the VM and still have your app running and accessible from http://ngstar-uat.corefacility.ca

If you would like to check the status of the process, log back into the VM and run the following commands to list all tmux sessions and attach to the tmux session again:

    tmux ls
    tmux a -t hello

Detach from the hello session by typing `Ctrl-b` and them by pressing the `d` button.

Next, install BLAST+ dependencies:

    sudo yum install perl-Archive-Tar
    sudo yum install perl-Digest-MD5
    sudo yum install perl-List-MoreUtils
    sudo yum install wget

Download the BLAST+ rpm from the NCBI website using wget (if the link is broken then find the correct rpm file from http://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download):

    wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.2.30+-3.x86_64.rpm

Install the BLAST+ rpm:

    sudo rpm -i ncbi-blast-2.2.30+-3.x86_64.rpm

Check that you have BLAST+ installed. You should see a help guide by running the following command:

    blastn --help

**Install all required perl modules for the NGSTAR project using cpan:**

Here is a list of all required perl modules:
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
	43. Catalyst::Plugin::I18N

To install modules using cpan, you would run:

	sudo cpan put_module_name_here

(for example, sudo cpan Test::More will install the Test::More module)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

There is an issue with starting the mysqld service after updating Centos 7 (using yum upgrade) as of February 5, 2015 (do not proceed with the instructions in this block unless you know this issue has been resolved).

Another person is also having the issue after updating which is currently  unresolved:
https://www.centos.org/forums/viewtopic.php?f=48&t=50921

The main issue is that running `sudo service mysqld start` hangs and doesn't start.

If the issue has been fixed, then you can install the Oracle version of MySQL by following these instructions:

Install the mysql yum repository for Centos 7 (if the link is broken then search for the appropriate link):

    sudo rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm

Install mysql-client and mysql-server:

    sudo yum install mysql-client mysql-server

Start mysql server:

    sudo service mysqld start

If you got MySQL to install and start properly, then skip the instructions for installing MariaDB.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

In this version of installing NGSTAR on the VM, we will use MariaDB which is an open source version of MySQL (MySQL was acquired by Oracle Corporation).

Install MariaDB:

    sudo yum install mariadb mariadb-server

Then start the mariadb service:

    sudo  systemctl start mariadb.service

The following error occurred after installing Oracle MySQL, uninstalling Oracle MySQL (due to the issue described above) and installing MariaDB as an alternative to Oracle MySQL. If you get an error like below then follow the instructions in the next block, otherwise, skip the next block of instructions:

    Job for mariadb.service failed. See 'systemctl status mariadb.service' and 'journalctl -xn' for details.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

You will need to re-install MariaDB:

    sudo yum remove mariadb mariadb-server

Create a **temp** directory in your home directory:

    cd
    mkdir temp

Then backup mysql files in the **temp** directory:

    sudo cp -r /var/lib/mysql/ ~/temp

Remove the mysql files:

    sudo rm -r /var/lib/mysql/

Then reinstall:

    sudo yum install mariadb mariadb-server

Try restarting the service:

    sudo systemctl start mariadb.service

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

If you are using git on the current VM (as of February 2015) then the private and public SSH keys for GitLab have already been setup on this machine with the following credentials:

email: irish.medina@phac-aspc.gc.ca

password: deadbeef

However, if you are setting up git for the first time, then proceed with the following instructions:

Generate a public and private SSH key for GitLab:
https://help.github.com/articles/generating-ssh-keys/

    ssh-keygen -t rsa -C "your_email@example.com"

When it asks you to "Enter file in which to save the key", press enter to select the default which is id_rsa

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa

Output your public key id_rsa:

    cat ~/.ssh/id_rsa.pub

Copy all the text.

Add your SSH public key to your GitLab account by going to:

    Profile Settings ->
    SSH Keys ->
    Add SSH Key ->
    Paste the public key that you copied into the Key text area and give it an appropriate title ->
    Click Add key

Clone the project using SSH (in your home directory):

    git clone git@gitlab.corefacility.ca:irish.medina/ng-star.git

Configure your git:

    git config --global user.name "Your Name"
    git config --global user.email you@example.com

Change directory to **ng-star/MySQLWorkbench/PopulateDatabaseStatements**

If you don't have **NGSTAR_schema.sql** or **NGSTAR_Auth_schema.sql** in **ng-star/MySQLWorkbench/PopulateDatabaseStatements**, you can transfer these files using SFTP (otherwise, skip this step):

    sftp my_ldap_username@ngstar-uat.corefacility.ca

Use the put command to transfer the files from your local to the remote machine:

    put local_path_to_NGSTAR_schema.sql
    put local_path_to_NGSTAR_Auth_schema.sql

You can log in without a password for root using:

    mysql -u root

The files **NGSTAR_schema.sql** and **NGSTAR_Auth_schema.sql** define the schema for NGSTAR. Execute the SQL scripts to generate the database schema by using the `source` command when logged in as root in mysql:

    mysql> source path_to_NGSTAR_schema.sql
    mysql> source path_to_NGSTAR_Auth_schema.sql

If everything goes well, you should get multiple `Query OK` messages.

Check that the databases were created by running the following command:

    mysql> show databases;

You should see the databases `NGSTAR` and `NGSTAR_Auth` on this list.

You should set the mysql root user to have a password by running the following commands:

    mysql> use mysql;
    mysql> update user set password=PASSWORD("mynewpasswordhere") where User='root';
    mysql> flush privileges;
    mysql> quit

Try logging in as the mysql root user using your new password:

    mysql -u root -p

Exit out of mysql:

    exit

Log into mysql as root:

    mysql -u root -p

Run the sql scripts to populate the `NGSTAR` and `NGSTAR_Auth` databases (if you are not in **ng-star/MySQLWorkbench/PopulateDatabaseStatements** then change directory there or specify the full path to the file in the statements below):

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Omit the instructions in this block if you are using MariaDB and not Oracle MySQL.

Install mysql-devel:

    sudo yum install mysql-devel

Clear your mysql root password (because trying to install DBD::mysql will run tests that require NO password access to mysql):

    set password for root@localhost=PASSWORD('');

Install the DBD::mysql perl module:

    sudo cpan DBD::mysql

Ensure that you re-enable your mysql root password:

    mysql -u root
    mysql> use mysql;
    mysql> update user set password=PASSWORD("mynewpasswordhere") where User='root';
    mysql> flush privileges;
    mysql> quit

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Change directory to the top level of the ng-star project where you will find the **generate_db_models** script

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
    Database classes successfully generated and is in the DatabaseObjects directory

Change directory to **ng-star/BusinessLogic** and create a directory called **data**.

    mkdir data


Next, we will have to change some of the hardcoded values in **ng-star/NGSTAR/ngstar.conf** to the following:

    If releasing on the ngstar-uat server:

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

Alternatively, you can install the modules manually (skip this step if you used the install_modules_centos script to install the **BusinessLogic** and **DAL** modules automatically):

Change directory to **ng-star/BusinessLogic/lib** and copy BusinessLogic folder and its contents to **/usr/local/share/perl5**:

    sudo cp -r BusinessLogic/ /usr/local/share/perl5

Change directory to **ng-star/DAL/lib** and copy the DAL folder and its contents to **/usr/local/share/perl5**:

    sudo cp -r DAL/ /usr/local/share/perl5

Change directory to **/usr/local/share/perl5** and verify that the directories and contents of **BusinessLogic** and **DAL** are present.

    cd /usr/local/share/perl5

Make sure that all software is updated:

    sudo yum update

Stop the starman server running your Hello world test project. You will need to reattach to this session on tmux.

List all tmux sessions (if you didn't name your session, then the session name is the number before the colon):

    tmux ls

Attach to a session:

    tmux a -t my_session_name

Then stop starman by typing `Ctrl-C`

Detach from the tmux session:

    Ctrl-b d

Then kill that tmux session:

    tmux kill-session -t session_name

Configure **ngstar.psgi** settings using vim. Add the `use lib` line so that **ngstar.psgi** looks like this:

    use strict;
    use warnings;

    use lib '/home/myusername/ng-star/NGSTAR/lib'; #or equivalent
    use MyAppName;

    my $app = Hello->apply_default_middlewares(Hello->psgi_app);
    $app;

Open the nginx settings for editing:

    sudo vim /etc/nginx/nginx.conf

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
            server_name ngstar-uat.corefacility.ca #set server_name to the hostname of your VM
            listen 80;

            location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://localhost:5005;
            }

            location /images/ {
                alias /home/myusername/ng-star/NGSTAR/root/static/images/; #set alias to the appropriate path of your images folder
                expires 30d;
                access_log off;
            }
        }
    }

You will need to restart nginx to have the changes reflected:

    sudo service nginx restart

Next, start a new tmux session and call it ngstar:

    tmux new-session -s ngstar

Go to **ng-star/NGSTAR** and start Starman and plack:

    plackup -s Starman -l :5005 ngstar.psgi

To persist the Starman server after logging out of the VM, you need to detach from the current tmux session by typing `Ctrl-b` followed by `d`

You should now be detached from the ngstar tmux session.

Verify that you have an ngstar tmux session running:

    tmux ls

You should now see the NGSTAR Catalyst test page at http://ngstar-uat.corefacility.ca/

To go to the main NGSTAR page, go to http://ngstar-uat.corefacility.ca/allele/form

Next, try logging in to test out the application.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Instructions on using SFTP

To transfer files to VM, use SFTP:

    sftp my_ldap_username@ngstar-uat.corefacility.ca

After logging in, you will want to transfer your local file (from your local machine) to the remote machine (the VM) using the put command:

    put path_to_local_file

This will transfer the file from your local machine to the current remote directory.

To transfer a remote file (from the VM) to your local machine, use the get command:

    get path_to_remote_file

This will transfer the file from your remote machine to the current local directory.

A good SFTP tutorial:
https://www.digitalocean.com/community/tutorials/how-to-use-sftp-to-securely-transfer-files-with-a-remote-server

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Instructions for resolving issue with adding blank values to Oracle MySQL database

If you try to insert an allele and you don't insert metadata values (which are optional) then will get an error in the StackTrace that says "Incorrect integer value ...". This is because the Ubuntu version of MySQL is version 5.5.41 and the CentOS VM version of MySQL is version 5.6.22

There was an update to MySQL that introduced the option `STRICT_TRANS_TABLES` by default that does not allow blank values to be added to tables automatically.
The short term solution is to remove this option. The long term solution is to fix the DAL code so that this option does not have to be disabled.

In the older version of MySQL, not setting a value would store it as a blank value (if the value is a string) or a zero value (if the value is an int).

To resolve this issue in the short term, edit **my.cnf** and comment out the line with sql_mode:

    sudo vim /etc/my.cnf

Comment out the line `sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES`

Restart mysql:

    sudo service mysqld stop
    sudo service mysqld start

Restart NGSTAR starman server by attaching to tmux session:

    tmux ls
    tmux a -t ngstar

Stop the server by typing `Ctrl-C`

Restart by running the script:

    ./start_starman_server

More information about the issue can be found here:

sql_mode defines what SQL syntax should be supported and what kind of data validation should be performed.
When the sql_mode line is commented out, STRICT mode is no longer applied so MySQL should insert adjusted values (blank or 0) for invalid or missing values.

In MySQL 5.0 two strict sql_mode options were introducted to change behaviour of inserting invalid or out of range values.
STRICT_ALL_TABLES: Behave more like the SQL standard and produce errors when data is out of range.
STRICT_TRANS_TABLES: Behave more like the SQL standard and produce errors when data is out of range, but only on transactional storage engines like InnoDB.

In MySQL 5.6 STRICT_TRANS_TABLES was set by default.

Links about the issue:
http://www.garethalexander.co.uk/tech/mysql-5-incorrect-integer-value-column-id-row-1
http://www.tocker.ca/2014/01/14/making-strict-sql_mode-the-default.html

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Instructions to update cpan modules

Install App::cpanoutdated:

    cpan App::cpanoutdated

The run the following command to udpate all installed cpan modules:

    cpan-outdated -p | sudo cpan
