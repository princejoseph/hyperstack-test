# Hyperstack Rails 7 Test App

**Live demo: https://hyperstack-demo.fly.dev**

A minimal Rails 7.2 app used to validate [Hyperstack](https://hyperstack.org) compatibility with Rails 7 and Ruby 3.

This app serves as an integration test for the [`rails-7-compatibility` branch](https://github.com/princejoseph/hyperstack/tree/rails-7-compatibility) of the Hyperstack fork.

## Stack

- Ruby 3.1
- Rails 7.2
- Hyperstack (from `princejoseph/hyperstack`, branch `rails-7-compatibility`)
- Opal (Ruby-to-JavaScript via Sprockets)
- SQLite

## Getting started

```bash
bundle install
bin/rails db:create db:migrate
```

Start the server (with Hyperstack hot-loader for development):

```bash
bundle exec foreman start
```

Or just the Rails server without hot-loading:

```bash
bin/rails server
```

Visit http://localhost:3000 — you should see the `Greetings` Hyperstack component rendered by React.

## Running tests

```bash
bin/rails test:system
```

System tests use Selenium + headless Chrome. Make sure `google-chrome` or `google-chrome-stable` is installed.

## Project structure

```
app/
  hyperstack/
    components/
      greetings.rb   # Opal/React component (client-side only)
  views/
    welcome/
      index.html.erb # Mounts the Greetings component via react-rails
```

## What this tests

| Scenario | Status |
|---|---|
| `bundle install` resolves with Rails 7.2 | ✅ |
| `rails hyperstack:install` generator runs | ✅ |
| Server boots without errors | ✅ |
| Greetings component renders | ✅ |
| System tests pass locally | ✅ |
| System tests pass in GitHub Actions CI | ✅ |

## Key fix: Zeitwerk and Hyperstack components

Hyperstack components (`app/hyperstack/components/`) are Opal/client-side code
compiled by Sprockets — they should never be loaded by Rails' server-side
autoloader. In CI, `eager_load = true` causes Zeitwerk to alphabetically
eager-load all files, which loads `greetings.rb` before `HyperComponent` is
defined.

This is fixed upstream in the Hyperstack railtie
(`hyperstack-config/lib/hyperstack/rail_tie.rb`):

```ruby
initializer "hyperstack.ignore_client_only_paths" do
  Rails.autoloaders.main.ignore(Rails.root.join('app/hyperstack/components'))
end
```

This tells Zeitwerk to skip that directory entirely — no manual workaround
needed in application code.

## Related

- [Hyperstack fork (rails-7-compatibility)](https://github.com/princejoseph/hyperstack/tree/rails-7-compatibility)
- [Upstream PR #460](https://github.com/hyperstack-org/hyperstack/pull/460)
- [Hyperstack docs](https://docs.hyperstack.org)
