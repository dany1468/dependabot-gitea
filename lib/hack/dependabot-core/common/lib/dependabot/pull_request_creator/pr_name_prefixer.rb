# frozen_string_literal: true

require "hack/dependabot-core/common/lib/dependabot/clients/gitea"

module Dependabot
  class PullRequestCreator
    class PrNamePrefixer
      # override
      def recent_commit_messages
        case source.provider
        when "github" then recent_github_commit_messages
        when "gitlab" then recent_gitlab_commit_messages
        when "azure" then recent_azure_commit_messages
        when "gitea" then recent_gitea_commit_messages
        when "codecommit" then recent_codecommit_commit_messages
        else raise "Unsupported provider: #{source.provider}"
        end
      end

      def recent_gitea_commit_messages
        recent_gitea_commits.
          reject { |c| c.author&.type == "Bot" }.
          reject { |c| c.commit&.message&.start_with?("Merge") }.
          map(&:commit).
          map(&:message).
          compact.
          map(&:strip)
      end

      def last_dependabot_commit_message
        @last_dependabot_commit_message ||=
          case source.provider
          when "github" then last_github_dependabot_commit_message
          when "gitlab" then last_gitlab_dependabot_commit_message
          when "azure" then last_azure_dependabot_commit_message
          when "gitea" then last_gitea_dependabot_commit_message
          when "codecommit" then last_codecommit_dependabot_commit_message
          else raise "Unsupported provider: #{source.provider}"
          end
      end

      def last_gitea_dependabot_commit_message
        recent_gitea_commits.
          reject { |c| c.commit&.message&.start_with?("Merge") }.
          find { |c| c.commit.author&.name&.include?("dependabot") }&.
          commit&.
          message&.
          strip
      end

      def recent_gitea_commits
        @recent_gitea_commits ||=
          gitea_client_for_source.commits
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
