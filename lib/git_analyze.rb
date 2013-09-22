require "git_analyze/version"
require 'alchemy-api'
require 'github_api'
require 'thread/pool'

module GitAnalyze
  class << self
    def get_all_commits(github_oauth, user, repo)
      @github = Github.new(oauth_token: github_oauth, per_page: 100)
      commits = []
      new_commits = @github.repos.commits.all(user, repo, per_page: 100)
      commits.concat(new_commits)
      while new_commits.length == 100
        next_sha = new_commits[-1]['sha']
        new_commits = @github.repos.commits.all(user, repo, sha: next_sha, per_page: 100)
        commits.concat(new_commits[1..-1])
      end
      commits
    end

    def pull_stats(api_key, github_oauth, user, repo)
      commits = get_all_commits(github_oauth, user, repo)
      @alchemy = AlchemyAPI::Client.new(api_key)
      author_commits = {} # Stores commit stats by author
      overall_stats = []

      pool = Thread.pool(100)
      commits.each do |commit|
        pool.process do
          message = commit.commit.message
          sentiment = @alchemy.TextGetTextSentiment(text: message)['docSentiment']
          keywords = @alchemy.TextGetRankedKeywords(text: message)['keywords']
          score = sentiment ? sentiment['score'].to_f : 0.0
          author = commit.commit.author.name
          author_commits[author] ||= []
          commit_stats = {}
          commit_stats[:sentiment] = score
          commit_stats[:lines] = message.lines.count
          commit_stats[:keywords] = keywords.map{|k| k['text']}
          author_commits[author] << commit_stats
          overall_stats << commit_stats
        end
      end

      pool.shutdown

      return overall_stats, author_commits
    end

    def output_overall(overall_stats)
      total_commits = overall_stats.count
      total_lines = overall_stats.map{|cstat| cstat[:lines]}.inject(:+).to_f
      sentiments = overall_stats.map{|cstat| cstat[:sentiment]}
      overall_sentiment = sentiments.inject(:+)
      all_keywords = overall_stats.flat_map{|cstat| cstat[:keywords]}.group_by{|x|x}
      all_keywords = all_keywords.sort_by{|k,v| v.length}.reverse
      puts "Total commits: #{total_commits}"
      puts "Total lines: #{total_lines}"
      puts "Average lines per commit: #{total_lines/total_commits}"
      puts "#{sentiments.select{|x|x>0}.count} positive messages vs #{sentiments.select{|x|x<0}.count} negative messages"
      puts "Total sentiment: #{overall_sentiment.round(3)}"
      puts "Average sentiment: #{(overall_sentiment/total_commits).round(3)}"
      puts "Keywords:"
      all_keywords.take(10).each do |k,v|
        puts "\t\"#{k}\" * #{v.length}"
      end
    end

    def output_author(author_commits)
      author_commits = Hash[author_commits.sort_by{|k,v| v.length}.reverse.take(10)]
      puts "Most frequent committers:"
      author_commits.each do |k,v|
        lines = v.map{|x| x[:lines]}.inject(:+).to_f
        sentiment = v.map{|x| x[:sentiment]}.inject(:+)
        all_keywords = v.flat_map{|x| x[:keywords]}
        big_keyword = all_keywords.sort_by{|keyword| all_keywords.count(keyword)}.last
        puts "\t#{k} has #{v.length} commits. #{(lines/v.length).round(3)} lines"+
        " per message, and an average sentiment of #{(sentiment/v.length).round(3)}."+
        " Their most common keyword is \"#{big_keyword || "N/A"}\""
      end
    end
  end
end
