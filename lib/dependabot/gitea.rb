require 'dependabot/gitea/version'
require 'hack/dependabot-core/common/lib/dependabot/clients/gitea'
require 'hack/dependabot-core/common/lib/dependabot/fire_fetchers/base'
require 'hack/dependabot-core/common/lib/dependabot/pull_request_creator'
require 'hack/dependabot-core/common/lib/dependabot/source'

module Dependabot
  module Gitea
    class Error < StandardError; end
    # Your code goes here...
  end
end
