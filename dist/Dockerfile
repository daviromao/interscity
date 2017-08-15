FROM debian:latest

RUN apt-get update
RUN apt-get install -y nodejs npm nodejs-legacy
RUN npm install -g http-server

# Add additional tools
RUN apt-get install -y vim links

CMD http-server .
