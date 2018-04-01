require 'octokit'

module StyleKeeper
  # PullReGithub APIquest accessor
  class GithubApi
    attr_reader :token, :contents_cache

    def initialize(token)
      @token = token
      @contents_cache = {}
    end

    def pull_request(repo, number)
      client.pull_request(repo, number)
    end

    def pull_request_commits(repo, number)
      client.pull_request_commits(repo, number)
    end

    def pull_request_files(repo, number)
      client.pull_request_files(repo, number)
    end

    def compare(repo, start, endd)
      client.compare(repo, start, endd)
    end

    def pull_request_comments(repo, number)
      client.pull_request_comments(repo, number)
    end

    def create_pull_request_comment(repo, pull_id, body, commit_id, path, position)
      client.create_pull_request_comment(repo, pull_id, body, commit_id, path, position)
    end

    def contents(repo, path, ref)
      contents_cache["#{repo}/#{ref}/#{path}"] ||= client.contents(repo, path: path, ref: ref)
    end

    private

    def client
      @_client ||= Octokit::Client.new(access_token: token, auto_paginate: true)
    end
  end
end
