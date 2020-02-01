# Dependabot::Gitea

Companion to Updating dependencies in Gitea repos.

## Usage

```
$ bundle init
```

Add following lines to Gemfile, and run `bunble install`.

```ruby
gem "dependabot-omnibus"
gem 'dependabot-gitea'
```

Download sample updating script.

```
$ wget https://raw.githubusercontent.com/dany1468/dependabot-gitea/master/scripts/generic-update-script.rb
```

Run script. `GITHUB_ACCESS_TOKEN` and `GITEA_ACCESS_TOKEN` environment variables are required.

```
$ GITHUB_ACCESS_TOKEN= GITEA_ACCESS_TOKEN= bundle exec ruby generic-update-script.rb
```

## :warning: Currently not support updating multiple files

https://github.com/dany1468/dependabot-gitea/blob/master/lib/hack/dependabot-core/common/lib/dependabot/clients/gitea.rb#L87

Sorry. Currently updating first file only.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dany1468/dependabot-gitea.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
