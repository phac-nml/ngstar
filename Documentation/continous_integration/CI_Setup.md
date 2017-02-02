                                                    CI Server Setup


Continuous Integration is the practice of merging all developer working copies of code to a shared repository and on which automated build testing is done. This allows us to discover any potential errors introduced into the code base and corrected as soon as possible. We use the Continuous Integration within GitLab for NG-STAR.

The Continuous Integration Server is already setup and provides us with 2 runners. This means that 2 automated builds can happen at the same time.

The test_ngstar.sh script automatically builds NG-STAR on the CI server and the last line within the script runs the selenium test suite.


**The following is contained within .ci/test_ngstar.sh and the following changes are required to ensure that the script works correctly***


CPAN modules list:

    If you have used a new module in NG-STAR from CPAN you must add it to this list so that it will be installed on the CI server.


MySQL:

    Inserts the schema and basic data required by NG-STAR. You will only need to make a change here if you have added another database, another table, or removed a table.


Executes the file and creates the database objects:

    ./generate_db_models -d NGSTAR -u ngstar

    - On the CI server the database is called NGSTAR but the username is ngstar without a password



#1) Update conf files

sed -i -e "s_/path/to/ng-star/BusinessLogic/data_$PWD/BusinessLogic/data_g" NGSTAR/ngstar.conf

sed -i -e "s_/path/to/ng-star/DatabaseObjects_$PWD/DatabaseObjects_g" NGSTAR/ngstar.conf
sed -i -e "s/your_mysql_password//g" NGSTAR/ngstar.conf
sed -i -e "s/your_mysql_username/ngstar/g" NGSTAR/ngstar.conf


**The test_ngstar.sh script is called from the .gitlab-ci.yml file by:**

    job1:
      script: ".ci/test_ngstar.sh"
