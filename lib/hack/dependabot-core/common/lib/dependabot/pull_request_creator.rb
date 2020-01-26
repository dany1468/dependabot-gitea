# frozen_string_literal: true

require "dependabot/metadata_finders"

module Dependabot
  class PullRequestCreator
    require "hack/dependabot-core/common/lib/dependabot/clients/gitea"
    require "hack/dependabot-core/common/lib/dependabot/pull_request_creator/labeler"
    require "hack/dependabot-core/common/lib/dependabot/pull_request_creator/gitea"
    require "hack/dependabot-core/common/lib/dependabot/pull_request_creator/pr_name_prefixer"

    # override
    def create
      case source.provider
      when "github" then github_creator.create
      when "gitlab" then gitlab_creator.create
      when "azure" then azure_creator.create
      when "gitea" then gitea_creator.create
      when "codecommit" then codecommit_creator.create
      else raise "Unsupported provider #{source.provider}"
      end
    end

    def gitea_creator
      Gitea.new(
        source: source,
        branch_name: branch_namer.new_branch_name,
        base_commit: base_commit,
        credentials: credentials,
        files: files,
        commit_message: message_builder.commit_message,
        pr_description: message_builder.pr_message,
        pr_name: message_builder.pr_name,
        author_details: author_details,
        labeler: labeler
      )
    end
  end
end
