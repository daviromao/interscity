# Base image used for InterSCity services
#
# For service specific images, check the subdirectories

FROM ruby:2.7.1

RUN apt update -qy && apt install libxml2 libsqlite3-dev zlib1g-dev liblzma-dev libpq-dev postgresql postgresql-contrib git -yq
RUN gem install bundler:2.0.2

RUN mkdir -p /gems/
ADD ./gems /gems/
