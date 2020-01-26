# frozen_string_literal: true

require "hack/dependabot-core/common/lib/dependabot/clients/gitea"

module Dependabot
  module FileFetchers
    class Base

      # override
      def _fetch_repo_contents_fully_specified(provider, repo, path, commit)
        case provider
        when "github"
          _github_repo_contents(repo, path, commit)
        when "gitlab"
          _gitlab_repo_contents(repo, path, commit)
        when "azure"
          _azure_repo_contents(path, commit)
        when "bitbucket"
          _bitbucket_repo_contents(repo, path, commit)
        when "gitea"
          _gitea_repo_contents(repo, path, commit)
        when "codecommit"
          _codecommit_repo_contents(repo, path, commit)
        else raise "Unsupported provider '#{provider}'."
        end
      end

      def _gitea_repo_contents(repo, path, commit)
        response = gitea_client.fetch_repo_contents(commit, path)

        response.map do |file|
          OpenStruct.new(
            name: file.fetch('name'),
            path: file.fetch('path'),
            type: file.fetch('type'),
            size: file.fetch('size')
          )
        end
      end

      # override
      def _fetch_file_content_fully_specified(provider, repo, path, commit)
        case provider
        when "github"
          _fetch_file_content_from_github(path, repo, commit)
        when "gitlab"
          tmp = gitlab_client.get_file(repo, path, commit).content
          Base64.decode64(tmp).force_encoding("UTF-8").encode
        when "azure"
          azure_client.fetch_file_contents(commit, path)
        when "gitea"
          tmp = gitea_client.fetch_repo_contents(commit, path)
          Base64.decode64(tmp.fetch('content')).force_encoding("UTF-8").encode
        when "bitbucket"
          bitbucket_client.fetch_file_contents(repo, commit, path)
        when "codecommit"
          codecommit_client.fetch_file_contents(repo, commit, path)
        else raise "Unsupported provider '#{source.provider}'."
        end
      end

      # override
      def client_for_provider
        case source.provider
        when "github" then github_client
        when "gitlab" then gitlab_client
        when "azure" then azure_client
        when "gitea" then gitea_client
        when "bitbucket" then bitbucket_client
        when "codecommit" then codecommit_client
        else raise "Unsupported provider '#{source.provider}'."
        end
      end

      def gitea_client
        @gitea_client ||=
          Dependabot::Clients::Gitea.for_source(source: source, credentials: credentials)
      end
    end
  end
end
