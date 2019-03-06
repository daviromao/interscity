FROM debian:unstable
RUN apt update -qy && apt install ruby bundler libxml2 libsqlite3-dev zlib1g-dev liblzma-dev libpq-dev -yq
RUN mkdir -p /resource-discoverer/
ADD . /resource-discoverer/
WORKDIR /resource-discoverer/
RUN gem install rake
RUN bundle install
CMD [ "bundle","exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
