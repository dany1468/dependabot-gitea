# frozen_string_literal: true

require "dependabot/shared_helpers"
require "excon"
require 'ostruct'

module Dependabot
  module Clients
    class Gitea
      class NotFound < StandardError; end

      #######################
      # Constructor methods #
      #######################

      def self.for_source(source:, credentials:)
        credential =
          credentials.
          select { |cred| cred["type"] == "git_source" }.
          find { |cred| cred["host"] == source.hostname }

        new(source, credential)
      end

      ##########
      # Client #
      ##########

      def initialize(source, credentials)
        @source = source
        @credentials = credentials
      end

      def fetch_commit(_repo, branch)
        response = get(source.api_endpoint + "repos/" +
                         "#{source.repo}/" + "branches/" + branch)

        JSON.parse(response.body).fetch("commit").fetch("id")
      end

      def labels(_repo)
        response = get(source.api_endpoint + "repos/" +
                         "#{source.repo}/" + "labels")

        JSON.parse(response.body, object_class: OpenStruct)
      end

      def fetch_default_branch(_repo)
        response = get(source.api_endpoint + "repos/" +
                         source.repo)

        JSON.parse(response.body).fetch("default_branch")
      end

      def fetch_repo_contents(commit = nil, path = nil)
        response = get(source.api_endpoint + "repos/" +
                         "#{source.repo}/" + "contents/" + path, {ref: commit})

        JSON.parse(response.body)
      end

      def fetch_repo_contents_treeroot(commit = nil, path = nil)
        raise # not-implemented
      end

      def fetch_file_contents(commit, path)
        fetch_repo_contents(commit, path)
      end

      def commits(branch_name = nil)
        response = get(source.api_endpoint + "repos/" +
                         "#{source.repo}/" + "commits")

        JSON.parse(response.body, object_class: OpenStruct)
      end

      def branch(branch_name)
        raise
      end

      def pull_requests(source_branch, target_branch)
        raise
      end

      def create_commit(branch_name, base_commit, commit_message, files,
                        author_details)
        head_file = files.first
        tail_files = files.drop(1)

        res = fetch_repo_contents(base_commit, head_file.path)

        content = {
          new_branch: branch_name,
          content: Base64.encode64(head_file.content),
          message: commit_message,
          sha: res.fetch('sha'),
          branch: 'master'
        }

        response = put(source.api_endpoint + "repos/" +
                         "#{source.repo}/" + "contents" + head_file.path, content.to_json)
      end

      def create_pull_request(pr_name, source_branch, target_branch,
                              pr_description, labels)
        content = {
          base: target_branch,
          head: source_branch,
          title: pr_name,
          body: pr_description,
        }

        response = post(source.api_endpoint + "repos/" +
                         "#{source.repo}/" + "pulls", content.to_json)
      end

      def get(url, extra_query = {})
        response = Excon.get(
          url,
          query: {access_token: credentials&.fetch("password")}.merge(extra_query),
          idempotent: true,
          **SharedHelpers.excon_defaults
        )
        raise NotFound if response.status == 404

        response
      end

      def post(url, json)
        response = Excon.post(
          url,
          headers: {
            "Content-Type" => "application/json"
          },
          body: json,
          query: {access_token: credentials&.fetch("password")},
          idempotent: true,
          **SharedHelpers.excon_defaults
        )
        raise NotFound if response.status == 404

        response
      end

      def put(url, json)
        response = Excon.put(
          url,
          headers: {
            "Content-Type" => "application/json"
          },
          body: json,
          query: {access_token: credentials&.fetch("password")},
          idempotent: true,
          **SharedHelpers.excon_defaults
        )
        raise NotFound if response.status == 404

        response
      end

      private

      attr_reader :credentials
      attr_reader :source
    end
  end
end
