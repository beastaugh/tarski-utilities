# Standard library
require 'yaml'
require 'time'
require 'pathname'

# Gem libraries
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

# Project libraries
require './lib/setup'

VERSION_DATA   = TarskiUtils::version_info("conf/version.yml")
TARSKI_VERSION = ENV['v'] || VERSION_DATA.first.first

TARSKI_DIRNAME = "tarski"
UTIL_DIR       = Pathname.new(__FILE__).dirname
LIB_DIR        = UTIL_DIR + "lib"
SRC_DIR        = UTIL_DIR + "src"
CONF_DIR       = UTIL_DIR + "conf"
BUILD_DIR      = UTIL_DIR + "build"
PUBLIC_DIR     = UTIL_DIR + "../public"
PLUGIN_DIR     = PUBLIC_DIR + "wp/wp-content/plugins/tarskisite"

SVN_URL        = "http://tarski.googlecode.com/svn"
GIT_REPO       = "git://github.com/ionfish/tarski.git"

FEED_INFO      = {
  :url         => "http://tarskitheme.com/",
  :title       => "Tarski update notification",
  :author      => ["Benedict Eastaugh", "Chris Sternal-Johnson"]}

desc "Creates a zip archive, and updates the version feed and changelog."
task :update => [:zip, :feed, :changelog]

desc "Update the version feed to notify Tarski users of the new release."
task :feed do
  require LIB_DIR + 'tarski_version'
  
  TarskiVersion.new(VERSION_DATA, FEED_INFO).publish_feed(PUBLIC_DIR + "version.atom")
end

desc "Generate the hooks documentation page."
task :hooks => [:co_working_copy, :pull_master] do
  require 'erb'
  require LIB_DIR + 'tarski_docs'
  
  TarskiDocs.new(SRC_DIR + TARSKI_DIRNAME).read.write(PUBLIC_DIR + "hooks.html")
  
  `rm -rf tarski/`
end

desc "Generate a new changelog HTML file."
task :changelog => [:co_working_copy, :pull_master] do
  require 'rdiscount'
  require 'rubypants'
  require 'hpricot'
  require 'open-uri'
  
  struct = File.open(UTIL_DIR + "conf/changelog-structure.html", "r") do |file|
    Hpricot(file.read)
  end
  
  doc = open(SRC_DIR + TARSKI_DIRNAME + "CHANGELOG") do |file|
    # The changelog is provided in Markdown format, so it needs to be
    # passed through BlueCloth before being read into Hpricot.
    Hpricot(Markdown.new(file.read).to_html)
  end
  
  vlinks = Array.new
  
  (doc/"h1").remove
  
  (doc/"h3").each do |header|
    version = header.inner_html.scan(/^Version (\d(?:\.\d)+)/)[0][0]
    header.set_attribute('id', "v#{version}")
    vlinks << "<li><a href=\"#v#{version}\">Version #{version}</a></li>"
  end
  
  struct.at("#changelog-updated").inner_html = "Last updated #{Time.now.strftime("%B %d %Y")}"
  struct.at("#version-links").inner_html = vlinks.join("\n")
  struct.search("#version-links").after(doc.to_html)
  
  File.open(PUBLIC_DIR + "changelog.html", "w+") do |changelog|
    changelog.puts(RubyPants.new(struct.to_html).to_html)
  end
end

desc "Add version data to the Tarski website plugin."
task :plugin_version do
  File.open(PLUGIN_DIR + "version.php", "w+") do |f|
    f.print "<?php

define('TARSKI_RELEASE_VERSION', ''#{TARSKI_VERSION}');
define('TARSKI_RELEASE_LINK', '#{VERSION_DATA.first[1]['link']}');
define('TARSKI_RELEASE_BRANCH', '#{TARSKI_VERSION}');

?>"
  end
end

task :co_working_copy do
  Dir.chdir(SRC_DIR)
  `git clone #{GIT_REPO} #{TARSKI_DIRNAME}` if Dir.glob(TARSKI_DIRNAME).empty?
end

task :pull_master do
  Dir.chdir(SRC_DIR + TARSKI_DIRNAME)
  `git pull origin master`
end

task :export do
  src   = SRC_DIR   + TARSKI_DIRNAME
  build = BUILD_DIR + TARSKI_DIRNAME
  
  `rm -rf #{build}`        # Clean up any old exports
  `cp -R #{src} #{build}`  # Copy working tree to build directory
  `rm #{build}/Rakefile`   # Remove Rakefile
  `rm -rf #{build}/.git`   # Remove repository
  `rm #{build}/.gitignore` # Remove dotfile
end

desc "Create a zip file of the lastest release in the downloads directory."
task :zip => [:co_working_copy, :pull_master, :export] do
  filename = "tarski_" + TARSKI_VERSION + ".zip"
  
  Dir.chdir(BUILD_DIR)
  `zip -rm #{PUBLIC_DIR + "downloads/" + filename} \
    #{TARSKI_DIRNAME}`
end
