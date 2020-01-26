# frozen_string_literal: true

require "hack/dependabot-core/common/lib/dependabot/clients/gitea"

module Dependabot
  class PullRequestCreator
    class Labeler
      # override
      def labels
        @labels ||=
          case source.provider
          when "github" then fetch_github_labels
          when "gitlab" then fetch_gitlab_labels
          when "azure" then fetch_azure_labels
          when "gitea" then fetch_gitea_labels
          else raise "Unsupported provider #{source.provider}"
          end
      end

      def fetch_gitea_labels
        gitea_client_for_source.
          labels(source.repo).
          map(&:name)
      end

      def gitea_client_for_source
        @gitea_client_for_source ||=
          Dependabot::Clients::Gitea.for_source(
            source: source,
            credentials: credentials
          )
      end
    end
  end
end
