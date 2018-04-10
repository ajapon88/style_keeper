require 'style_keeper'
require 'thor'

module StyleKeeper
  class CLI < Thor
    default_command :hound
    class_option :config, type: :string, desc: 'StyleKeeper config file'
    class_option :token, type: :string, desc: 'Github access token'

    desc 'hound REPOSITORY PULL_REQUEST_NUMBER', 'hound linter PullRequest'
    option :sha, type: :string, desc: 'pull request commit sha'
    def hound(repository, pull_request_number)
      style_keeper = StyleKeeper.new(options['config'], options['token'])
      style_keeper.hound(repository, pull_request_number, options['sha'])
    end
  end
end
