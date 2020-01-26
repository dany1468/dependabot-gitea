# frozen_string_literal: true

module Dependabot
  class Source
    # override
    def url_with_directory
      return url if [nil, ".", "/"].include?(directory)

      case provider
      when "github", "gitlab"
      when "github", "gitlab", "gitea"
        path = Pathname.new(File.join("tree/#{branch || 'HEAD'}", directory)).
          cleanpath.to_path
        url + "/" + path
      when "bitbucket"
        path = Pathname.new(File.join("src/#{branch || 'default'}", directory)).
          cleanpath.to_path
        url + "/" + path
      when "azure"
        url + "?path=#{directory}"
      when "codecommit"
        raise "The codecommit provider does not utilize URLs"
      else raise "Unexpected repo provider '#{provider}'"
      end
    end

    # override
    def default_hostname(provider)
      case provider
      when "github" then "github.com"
      when "bitbucket" then "bitbucket.org"
      when "gitlab" then "gitlab.com"
      when "azure" then "dev.azure.com"
      when "gitea" then "localhost:3000"
      when "codecommit" then "us-east-1"
      else raise "Unexpected provider '#{provider}'"
      end
    end

    # override
    def default_api_endpoint(provider)
      case provider
      when "github" then "https://api.github.com/"
      when "bitbucket" then "https://api.bitbucket.org/2.0/"
      when "gitlab" then "https://gitlab.com/api/v4"
      when "azure" then "https://dev.azure.com/"
      when "gitea" then "http://localhost:3000/api/v1"
      when "codecommit" then nil
      else raise "Unexpected provider '#{provider}'"
      end
    end
  end
end
