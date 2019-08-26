# Base image used for InterSCity services
#
# For service specific images, check the subdirectories

FROM ruby:2.3.8

RUN apt update -qy && apt install libxml2 libsqlite3-dev zlib1g-dev liblzma-dev libpq-dev postgresql postgresql-contrib git -yq
RUN gem install bundler:2.0.1

RUN mkdir -p /gems/
ADD ./gems /gems/
