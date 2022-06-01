FROM ruby:3.0.2

#RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY . .

#RUN gem install io-wait:0.1.0 --default
RUN gem install bundler:2.3.14
#&& bundle update --bundler
# && bundle install
CMD ["./simulate_releases.sh"]
