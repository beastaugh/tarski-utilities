# Standard library
require 'yaml'
require 'time'

# Gem libraries
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

# Project libraries
require 'lib/setup'

VERSION_DATA   = TarskiUtils::version_info("conf/version.yml")
PUBLICPATH     = "../public"
PLUGINPATH     = "#{PUBLIC_PATH}/wp/wp-content/plugins/tarskisite"
TARSKI_VERSION = ENV['v'] || VERSION_DATA.first.first
TARSKI_DIR     = "tarski"

SVN_URL        = "http://tarski.googlecode.com/svn"
GIT_REPO       = "git://github.com/ionfish/tarski.git"

FEED_INFO      = {
  :url         => "http://tarskitheme.com/"
  :title       => "Tarski update notification"
  :author      => ["Benedict Eastaugh", "Chris Sternal-Johnson"]}

desc "Creates a zip archive, and updates the version feed and changelog."
task :update => [:zip, :feed, :changelog, :plugin_version]

desc "Update the version feed to notify Tarski users of the new release."
task :feed do
  require 'lib/tarski_version'
  puts "Generating version feed..."  
  TarskiVersion.new(VERSION_DATA, FEED_INFO).publish_feed("#{PUBLIC_PATH}/version.atom")
  puts "Done."
end

desc "Generate the hooks documentation page."
task :hooks => :download do
  require 'erb'
  require 'lib/tarski_docs'
  
  puts "Generating hooks documentation..."
  TarskiDocs.new(Dir.pwd + '/' + TARSKI_DIR).read.write("#{PUBLIC_PATH}/hooks.html")
  
  puts "Cleaning up checked-out files..."
  `rm -rf tarski/`
  puts "Done."
end

desc "Generate a new changelog HTML file."
task :changelog do
  require 'rdiscount'
  require 'rubypants'
  require 'hpricot'
  require 'open-uri'
  
  puts "Reading changelog..."
  
  struct = File.open("conf/changelog-structure.html", "r") do |file|
    Hpricot(file.read)
  end
  
  doc = open("#{SVN_URL}/trunk/CHANGELOG") do |file|
    # The changelog is provided in Markdown format, so it needs to be
    # passed through BlueCloth before being read into Hpricot.
    Hpricot(Markdown.new(file.read).to_html)
  end
  
  vlinks = Array.new
  
  puts "Generating HTML..."
  
  (doc/"h1").remove
  
  (doc/"h3").each do |header|
    version = header.inner_html.scan(/^Version (\d(?:\.\d)+)/)[0][0]
    header.set_attribute('id', "v#{version}")
    vlinks << "<li><a href=\"#v#{version}\">Version #{version}</a></li>"
  end
  
  struct.at("#changelog-updated").inner_html = "Last updated #{Time.now.strftime("%B %d %Y")}"
  struct.at("#version-links").inner_html = vlinks.join("\n")
  struct.search("#version-links").after(doc.to_html)
  
  File.open("#{PUBLIC_PATH}/changelog.html", "w+") do |changelog|
    changelog.puts(RubyPants.new(struct.to_html).to_html)
  end
  
  puts "Done."
end

desc "Add version data to the Tarski website plugin."
task :plugin_version do
  File.open("#{PLUGINPATH}/version.php", "w+") do |f|
    f.print "<?php

define('TARSKI_RELEASE_VERSION', #{TARSKI_VERSION});
define('TARSKI_RELEASE_LINK', '#{VERSION_DATA.first[1]['link']}');
define('TARSKI_RELEASE_BRANCH', #{TARSKI_VERSION});

?>"
  end
end

desc "Create a zip file of the lastest release in the downloads directory."
task :zip => :download do
  puts "Creating zip file..."
  %x{zip -rm #{PUBLIC_PATH}/downloads/tarski_#{TARSKI_VERSION}.zip #{TARSKI_DIR}}
  puts "Done."
end

desc "Export the latest release files."
task :download do
  %x{rm -rf #{TARSKI_DIR}}
  Rake::Task['git_export'].invoke
end

desc "Export the latest release from the Subversion repository."
task :svn_export do
  puts "Downloading Tarski files..."
  %x{svn export #{SVN_URL}/releases/#{TARSKI_VERSION} #{TARSKI_DIR}}
end

desc "Export the latest release from a Git repository."
task :git_export do
  here = Dir.pwd
  there = "#{here}/#{TARSKI_DIR}"
  puts "Cloning Git repository..."
  %x{git clone #{GIT_REPO} #{there}}
  Dir.chdir(there)
  %x{git checkout -b #{TARSKI_VERSION} #{TARSKI_VERSION}}
  puts "Pruning .git directory..."
  %x{rm -rf #{there}/.git/}
  %x{rm #{there}/.gitignore}
  Dir.chdir(here)
end
