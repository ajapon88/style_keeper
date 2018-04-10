require 'style_keeper'
require 'thor'

module StyleKeeper
  class CLI < Thor
    default_command :hound

    desc 'hound REPOSITORY PULL_REQUEST_NUMBER', 'hound linter PullRequest'
    option :sha, type: :string, desc: 'pull request commit sha'
    option :token, type: :string, desc: 'github access token'
    def hound(repository, pull_request_number)
      style_keeper = StyleKeeper.new(repository, pull_request_number, options['sha'], options['token'])
      style_keeper.hound
    end
  end
end
