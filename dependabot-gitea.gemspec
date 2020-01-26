require_relative 'lib/dependabot/gitea/version'

Gem::Specification.new do |spec|
  spec.name          = 'dependabot-gitea'
  spec.version       = Dependabot::Gitea::VERSION
  spec.authors       = ['dany1468']
  spec.email         = ['dany1468@gmail.com']

  spec.summary       = %q{dependabot Gitea plugin}
  spec.description   = %q{dependabot Gitea plugin}
  spec.homepage      = 'https://github.com/dany1468/dependabot-gitea'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://github.com/dany1468/dependabot-gitea'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/dany1468/dependabot-gitea'
  spec.metadata['changelog_uri'] = 'https://github.com/dany1468/dependabot-gitea'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
