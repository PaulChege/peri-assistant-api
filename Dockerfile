# syntax=docker/dockerfile:1

FROM ruby:3.3-alpine

# Install OS packages and build tools
RUN apk add --no-cache \
  build-base \
  git \
  postgresql-client \
  postgresql-dev \
  tzdata \
  nodejs \
  yarn \
  bash \
  yaml-dev

WORKDIR /app

# Set bundler path to persist gems between rebuilds
ENV BUNDLE_PATH=/usr/local/bundle

# Install gems first to leverage Docker layer caching
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the app
COPY . .

EXPOSE 3001

ENV RAILS_ENV=development RACK_ENV=development

# Prepare DB then start the server binding to all interfaces
CMD ["bash", "-lc", "bundle exec rails db:prepare && bundle exec rails s -b 0.0.0.0 -p 3001"]
