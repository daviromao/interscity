FROM debian:unstable
RUN apt update -qy && apt install ruby bundler libxml2 zlib1g-dev libsqlite3-dev libpq-dev postgresql postgresql-contrib -yq
RUN mkdir -p /resource-cataloguer/
ADD . /resource-cataloguer/
WORKDIR /resource-cataloguer/
RUN gem install rake
RUN bundle install
CMD [ "bundle","exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
