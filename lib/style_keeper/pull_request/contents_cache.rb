require 'active_record'
module StyleKeeper
  class ContentsCache < ActiveRecord::Base
    def self.create_table_if_not_exists(connection)
      return if connection.data_source_exists?(:contents_caches)
      connection.create_table :contents_caches do |t|
        t.column :repo, :string, null: false
        t.column :name, :string, null: false
        t.column :path, :string, null: false
        t.column :sha, :string, null: false
        t.column :content, :text, null: false
        t.timestamps
      end
    end

    @@cache_lifetime = -1

    def self.cache_lifetime
      @@cache_lifetime
    end

    def self.cache_lifetime=(val)
      @@cache_lifetime = val
    end

    def self.find_contents_cache(repo, path, sha)
      if cache_lifetime >= 0
        ContentsCache.where('repo = ? AND path = ? AND sha = ? AND updated_at > ?', repo, path, sha, Time.now - cache_lifetime).first
      else
        ContentsCache.where(repo: repo, path: path, sha: sha).first
      end
    rescue StandardError
      nil
    end

    def self.clean_contents_old_cache
      # puts "clean cache: lifetime #{cache_lifetime}"
      ContentsCache.where('updated_at < ?', Time.now - cache_lifetime).destroy_all if cache_lifetime >= 0
    end

    def self.create_contents_cache(repo, name, path, sha, content)
      puts "create_contents_cache path:#{path}, sha:#{sha}"
      ContentsCache.create!(repo: repo, name: name, path: path, sha: sha, content: content).reload
    end
  end
end
