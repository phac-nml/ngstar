# Nginx, Starman, Plack Stack

We use a Nginx, Starman and Plack (PSGI) stack to host NGSTAR on a server. Information has been compiled from various sources.

## Visualization

```
Nginx <-----------> Plack <-------> Starman <-----------------> Catalyst App

Front-end           "glue"          Application                 NGSTAR Catalyst App
HTTP                                server
Server                              running
                                    Catalyst app
Proxies to
Starman                             Handles
server                              multiple requests
                                    at a time
Serves
static                              Listen on
files                               port 5005

Listen on
port 80

Send traffic
from port
80 to Starman
server for
processing
```

## Web Server

* A system that processes requests via HTTP
* On a web server, port 80 is the port that the server listens to or expects to receive from a web client

## Nginx

* A lightweight web server
* Acts as a replacement to Apache
* Serves about 10% of web domains
* Advantage of Nginx over Apache is that it is asynchronous and event driven instead of creating a process thread to handle each connection
* In theory this means that Nginx is able to handle a large number of connections without using alot of system resources
* Can handle the serving of static files (such as CSS, Javascript and images)

## PSGI (Perl Web Server Gateway Interface)

* Interface between web servers and Perl based web applications and frameworks
* PSGI is a protocol, not an implementation
* Provides a protocol with which a web server (Nginx) can communicate with a server written in Perl (Starman)
* Easier to test Perl server independently of the web server
* Easy to switch in different PSGI compatible web servers (Apache)

## Plack

* Plack is a PSGI implementation
* A particular implementation of the PSGI protocol that provides the glue between a PSGI compatible web server and a Perl application server
* The "glue" between Nginx and Starman

## Starman

* A Perl based web server that is compatible with the PSGI protocol
* Using Starman allows Nginx to server static files without requiring a Perl process while also allowing the Perl application server to run on a higher port

Catalyst app/Starman needs a way to talk to the Nginx server. The way that they will communicate is through a protocol called PSGI. Plack is an implementation of PSGI and handles this communication.

## Proxy server

* Acts as an intermediary for requests from clients seeking resources from other servers
* Client connects to the proxy server requesting some service or resource
* The proxy evaluates the request as a way to simplify and control its complexity

```
Alice --> Proxy --> Bob
      <--       <--
```
* Bob does not know whom the information is going to
* In our stack, Nginx serves as a Reverse proxy

## Reverse Proxy

* A type of proxy server that retrieves resources on behalf of a client from one or more servers.
* These resources are then returned to the client as though they originated from the proxy server itself.

```
Internet -------->                  ---------> Web Server
         <-------- Proxy           <--------- (Starman)
                   (Nginx)
```

* The diagram shows a reverse proxy (Nginx) taking requests from the internet and forwarding them to servers (Starman) in an internal network.
* Those making requests to the proxy may not be aware of the internal network.
* While a forward proxy acts as an intermediary for its associated clients to contact any server, a reverse proxy acts as an intermediary for its associated servers to be contacted by any client.

## Example

* Any requests to myapp.com at port 80 will be routed to localhost:5005 which is where Plack and Starman are listening
* Any requests to myapp.com/static will be sent to the folder containing the static files for your Catalyst application

## You should have a front-end server (Nginx) proxying to an application server (Starman) for a few reasons:

* So that you can run the Catalyst server on a high port as an ordinary user, while running the front-end server on port 80
* To serve static files (done by Nginx) without tying up a Perl process for the duration of the download
* Load balancing

## Why not use the default Catalyst development server?

* The default Catalyst server can only handle a single request at a time, so it is not appropriate for use in a production environment
* Replace the Catalyst development server with Starman

## What does this command do?

    plackup -s Starman --l :5005 myapp.psgi

* This will make the Starman server run our Catalyst application on port 5005

* `plackup` command will run PSGI application with Plack servers

* `-s` flag will select a specific server implementation to run on, which will be Starman

* `--l` flag (--listen :PORT) specifies the port that Starman binds to and waits for requests

To make Nginx send traffic to the Starman server you need to modify /etc/nginx/nginx.conf:

    location / {
        proxy_pass http://localhost:5005;
    }

This line of codes says that traffic to the web server on port 80 should be sent to the Starman server to handle (since Nginx proxies to Starman)
