# frozen_string_literal: true

require "hack/dependabot-core/common/lib/dependabot/clients/gitea"
require "dependabot/pull_request_creator"

module Dependabot
  class PullRequestCreator
    class Gitea
      attr_reader :source, :branch_name, :base_commit, :credentials,
                  :files, :commit_message, :pr_description, :pr_name,
                  :author_details, :labeler

      def initialize(source:, branch_name:, base_commit:, credentials:,
                     files:, commit_message:, pr_description:, pr_name:,
                     author_details:, labeler:)
        @source         = source
        @branch_name    = branch_name
        @base_commit    = base_commit
        @credentials    = credentials
        @files          = files
        @commit_message = commit_message
        @pr_description = pr_description
        @pr_name        = pr_name
        @author_details = author_details
        @labeler        = labeler
      end

      def create
        return if branch_exists? && pull_request_exists?

        # For Azure we create or update a branch in the same request as creating
        # a commit (so we don't need create or update branch logic here)
        create_commit

        create_pull_request
      end

      private

      def gitea_client_for_source
        @gitea_client_for_source ||=
          Dependabot::Clients::Gitea.for_source(
            source: source,
            credentials: credentials
          )
      end

      def branch_exists?
        @branch_ref ||= gitea_client_for_source.branch(branch_name)

        @branch_ref
      rescue
        false
      end

      def pull_request_exists?
        gitea_client_for_source.pull_requests(
          branch_name,
          source.branch || default_branch
        ).any?
      end

      def create_commit
        author = author_details&.slice(:name, :email, :date)
        author = nil unless author&.any?

        gitea_client_for_source.create_commit(
          branch_name,
          base_commit,
          commit_message,
          files,
          author
        )
      end

      def create_pull_request
        gitea_client_for_source.create_pull_request(
          pr_name,
          branch_name,
          source.branch || default_branch,
          pr_description,
          labeler.labels_for_pr
        )
      end

      def default_branch
        @default_branch ||=
          gitea_client_for_source.fetch_default_branch(source.repo)
      end
    end
  end
end
