FROM registry.gitlab.com/interscity/interscity-platform/interscity-platform/base:0.2.0
RUN mkdir -p /data-collector/
ADD . /data-collector/
WORKDIR /data-collector/
RUN gem install rake
RUN bundle install
CMD [ "bundle","exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
