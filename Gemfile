source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in superbot.gemspec
gemspec

unless ENV['SUPERBOT_USE_RUBYGEMS'] == "yes"
  gem "superbot-selenium-webdriver", path: "../superbot-selenium-webdriver"
  gem "superbot-teleport", path: "../superbot-teleport"
  gem "superbot-cloud", path: "../superbot-cloud"
  gem "superbot-local", path: "../superbot-local"
end
