# GitAnalyze

Analyzes a repository on Github, outputting information about each authors and
the overall repositories commit messages.

It will output information about sentiment of messages, length of messages,
and keywords found in messages.

Do this it uses [AlchemyAPI](http://www.alchemyapi.com/api) with my own [custom
SDK](https://github.com/Aaronneyer/alchemy-api) written on top of it.

## Installation

Add this line to your application's Gemfile:

    gem 'git_analyze'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install git_analyze

## Usage
```bash
git_analyze --api-key=ALCHEMYAPIKEY --oauth=GITHUBPERSONALTOKEN github_user github_repo
```

```ruby
require git_analyze
GitAnalyze.pull_stats('alchemyapikey', 'githuboauthtoken', github_user, github_repo)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
