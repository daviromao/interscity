# Base image used for InterSCity services
#
# For service specific images, check the subdirectories

FROM debian:unstable

RUN apt update -qy && apt install ruby bundler libxml2 libsqlite3-dev zlib1g-dev liblzma-dev libpq-dev postgresql postgresql-contrib git -yq

RUN mkdir -p /gems/
ADD ./gems /gems/
