FROM debian:unstable
RUN apt update -qy && apt install ruby bundler libxml2 libsqlite3-dev libpq-dev postgresql postgresql-contrib -yq
RUN mkdir -p /resource-adaptor/
ADD . /resource-adaptor/
WORKDIR /resource-adaptor/
RUN bundle install
CMD ["bundle","exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
