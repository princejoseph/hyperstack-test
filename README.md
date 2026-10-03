# Hyperstack Rails 8 Test App

**Live demo: https://hyperstack-demo.fly.dev**

A minimal Rails 8.0 app used to validate [Hyperstack](https://hyperstack.org) compatibility with Rails 8 and Ruby 3.4, including HyperModel real-time sync over ActionCable (the guestbook).

This app serves as an integration test for the [`rails-8-compatibility` branch](https://github.com/princejoseph/hyperstack/tree/rails-8-compatibility) of the Hyperstack fork.

## Stack

- Ruby 3.4.9
- Rails 8.0
- Hyperstack (from `princejoseph/hyperstack`, branch `rails-8-compatibility`)
- Opal 1.8 (Ruby-to-JavaScript via Sprockets, through `opal-sprockets` -- not `opal-rails`)
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
bin/rails test:all
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
| `bundle install` resolves with Rails 8.0 | ✅ |
| `rails hyperstack:install` generator runs | ✅ |
| Server boots without errors | ✅ |
| Greetings component renders | ✅ |
| Guestbook entry syncs to a second browser in real time | ✅ |
| System tests pass locally | ✅ |
| System tests pass in GitHub Actions CI | ✅ |

## Rails 8 / Ruby 3.4 notes

- `opal-sprockets` instead of `opal-rails` (2.x caps rails < 7.3; 3.x dropped the
  Sprockets integration that `//= require hyperstack-loader` needs).
  `config/application.rb` does `require "opal/sprockets"`, adds `Opal.paths` to
  the asset paths, and sets `config.opal.entrypoints = {}` (with an empty
  `app/opal/`) so opal-rails 3's `opal:build` step is a no-op.
- `json < 3.0` (Rails 8.0 passes `quirks_mode:`, which json 3 removed) and
  `connection_pool < 3.0` (react-rails 2.7 passes a positional options hash).
- `opal` pinned to 1.8.3 so Bundler doesn't pick a prerelease.
- The Dockerfile keeps the git-sourced gems' `.git` directories and sets
  `safe.directory '*'`: Bundler re-reads those gemspecs on every boot.
- `test/test_helper.rb` forces `Hyperstack.on_server?` to true and builds the
  transport tables, or broadcasts never reach the browser under tests.

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

- [Hyperstack fork (rails-8-compatibility)](https://github.com/princejoseph/hyperstack/tree/rails-8-compatibility)
- [Upstream PR #460](https://github.com/hyperstack-org/hyperstack/pull/460)
- [Hyperstack docs](https://docs.hyperstack.org)
