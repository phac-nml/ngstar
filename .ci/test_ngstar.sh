#!/bin/bash -e

#################################
#Purpose: CI server setup.#######
#################################

perl execute_sql.pl -u root -p password -h mysql --port=3306 MySQLWorkbench/PopulateDatabaseStatements/NGSTAR_schema.sql
perl execute_sql.pl -u root -p password -h mysql --port=3306 MySQLWorkbench/PopulateDatabaseStatements/NGSTAR_Auth_schema.sql
perl execute_sql.pl -u root -p password -h mysql --port=3306 MySQLWorkbench/PopulateDatabaseStatements/insert_classification_codes.sql
perl execute_sql.pl -u root -p password -h mysql --port=3306 MySQLWorkbench/PopulateDatabaseStatements/insert_loci.sql
perl execute_sql.pl -u root -p password -h mysql --port=3306 MySQLWorkbench/PopulateDatabaseStatements/insert_mic.sql
perl execute_sql.pl -u root -p password -h mysql --port=3306 MySQLWorkbench/PopulateDatabaseStatements/insert_amino_acids.sql
perl execute_sql.pl -u root -p password -h mysql --port=3306 MySQLWorkbench/PopulateDatabaseStatements/insert_onishi.sql
perl execute_sql.pl -u root -p password -h mysql --port=3306 MySQLWorkbench/PopulateDatabaseStatements/insert_user_roles.sql

#Sets excecute permissions
chmod +x generate_db_models

#Creates directory
mkdir TestObjects

#Removes folders/file recursively
rm -rf BusinessLogic/data
rm -rf DatabaseObjects

#Creates DatabaseObjects
perl -MDBIx::Class::Schema::Loader=make_schema_at,dump_to_dir:./DatabaseObjects -e 'make_schema_at("NGSTAR::Schema",{debug=>1},["dbi:mysql:dbname=NGSTAR;host=mysql;port=3306","root","password"])'

#Creates data directory used for blast data
mkdir BusinessLogic/data

#search and replace hardcoded paths with correct ones for CI server:

PWD=`pwd`

#1) Update conf files

cp NGSTAR/ngstar.conf.sample NGSTAR/ngstar.conf
sed -i -e "s_/opt/ng-star/BusinessLogic/data_$PWD/BusinessLogic/data_g" NGSTAR/ngstar.conf

sed -i -e "s_/opt/ng-star/DatabaseObjects_$PWD/DatabaseObjects_g" NGSTAR/ngstar.conf
sed -i -e "s/host=localhost/host=mysql/g" NGSTAR/ngstar.conf
sed -i -e "s/port=3000/port=3306/g" NGSTAR/ngstar.conf

sed -i -e 's/DB_HOST = "localhost"/DB_HOST = "mysql"/g' SeleniumWebDriverTests/constants.py
sed -i -e "s#/usr/lib/chromium-browser/chromedriver#/usr/bin/chromedriver#" SeleniumWebDriverTests/constants.py



#Install the DAL and BusinessLogic layers:

cd DAL
perl Makefile.PL && make && make install

cd ../BusinessLogic
perl Makefile.PL && make && make install

cd ../

export DBIC_OVERWRITE_HELPER_METHODS_OK=1

#Runs the selenium tests stored in SeleniumWebDriverTests/suite.py
xvfb-run --auto-servernum --server-num=1 python SeleniumWebDriverTests/suite.py
