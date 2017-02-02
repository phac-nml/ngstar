# NGSTAR Catalyst Project

The NGSTAR Catalyst project acts more like a presentation layer and has a very thin model. It makes calls to the business logic layer by utilizing an Adaptor (design pattern).

## Run Development Server

To run the development server for local Linux development only, run the following command:

    script/ngstar_server.pl -r

## Run Production Server

To run the production server using Plack (a PSGI protocol implementation) and Starman on a Linux server, run the following command:

    plackup -s Starman -l :5005 ngstar.psgi

For more information on server deployment, please consult the documentation located in **Documentation/deployment_docs**
