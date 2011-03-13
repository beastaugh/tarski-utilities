# Standard library
require 'yaml'
require 'time'
require 'pathname'

# Project libraries
require './lib/setup'

VERSION_DATA   = TarskiUtils::version_info("conf/version.yml")
TARSKI_VERSION = ENV['v'] || VERSION_DATA.first.first

TARSKI_DIRNAME = "tarski"
UTIL_DIR       = Pathname.new(File.dirname(__FILE__)).expand_path
LIB_DIR        = UTIL_DIR + "lib"
SRC_DIR        = UTIL_DIR + "src"
CONF_DIR       = UTIL_DIR + "conf"
BUILD_DIR      = UTIL_DIR + "build"
PUBLIC_DIR     = UTIL_DIR + "../public"

GIT_REPO       = "git://github.com/beastaugh/tarski.git"

FEED_INFO      = {
  :url         => "http://tarskitheme.com/",
  :title       => "Tarski update notification",
  :author      => ["Benedict Eastaugh", "Chris Sternal-Johnson"]}

desc "Creates a zip archive and publicises version update."
task :update => [:zip, :version]

desc "Updates the changelog and API documentation."
task :docs => [:changelog, :hooks]

desc "Updates the version on the feed and website."
task :version => [:feed_version, :site_version]

# Update the version feed to notify Tarski users of the new release
task :feed_version do
  require LIB_DIR + 'tarski_version'
  
  TarskiVersion.new(VERSION_DATA, FEED_INFO).publish_feed(PUBLIC_DIR + "version.atom")
end

# Add version data to the Tarski website
task :site_version do
  File.open(PUBLIC_DIR + "version.php", "w+") do |f|
    f.print "<?php

define('TARSKI_RELEASE_VERSION', '#{TARSKI_VERSION}');
define('TARSKI_RELEASE_LINK', '#{VERSION_DATA.first[1]['link']}');
define('TARSKI_RELEASE_BRANCH', '#{TARSKI_VERSION}');

?>"
  end
end

# Generate the hooks documentation page
task :hooks => [:co_working_copy, :pull_master] do
  require 'erb'
  require LIB_DIR + 'tarski_docs'
  
  TarskiDocs.new(SRC_DIR + TARSKI_DIRNAME).read.write(PUBLIC_DIR + "hooks.html")
end

# Generate a new changelog HTML file
task :changelog => [:co_working_copy, :pull_master] do
  # Required libraries
  ['rdiscount', 'rubypants', 'hpricot', 'open-uri'].each {|lib| require_lib(lib) }
  
  struct = File.open(UTIL_DIR + "conf/changelog-structure.html", "r") do |file|
    Hpricot(file.read)
  end
  
  doc = open(SRC_DIR + TARSKI_DIRNAME + "changelog.txt") do |file|
    # The changelog is provided in Markdown format, so it needs to be
    # passed through BlueCloth before being read into Hpricot.
    Hpricot(Markdown.new(file.read).to_html)
  end
  
  vlinks = Array.new
  
  (doc/"h1").remove
  
  (doc/"h3").each do |header|
    name = header.inner_html.scan(/^[\w\s\.]+/).first.strip
    matches = name.scan(/^Version ([\d\.]+)$/)[0]
    version = matches ? matches[0] : name
    id = "v" + version.downcase
    header.set_attribute('id', id)
    vlinks << "<li><a href=\"##{id}\">#{version}</a></li>"
  end
  
  struct.at("#changelog-updated").inner_html = "Last updated #{Time.now.strftime("%B %d %Y")}"
  struct.at("#version-links").inner_html = vlinks.join("\n")
  struct.search("#version-links").after(doc.to_html)
  
  File.open(PUBLIC_DIR + "changelog.html", "w+") do |changelog|
    changelog.puts(RubyPants.new(struct.to_html).to_html)
  end
end

task :co_working_copy do
  if Dir.glob(SRC_DIR + TARSKI_DIRNAME).empty?
    `cd #{SRC_DIR}; git clone #{GIT_REPO} #{TARSKI_DIRNAME}`
  end
end

task :pull_master do
  `cd #{SRC_DIR + TARSKI_DIRNAME}; git pull -q origin master`
end

task :export do
  src   = SRC_DIR   + TARSKI_DIRNAME
  build = BUILD_DIR + TARSKI_DIRNAME
  
  FileUtils.rm_rf build
  FileUtils.cp_r  src, build
  FileUtils.rm_rf build + ".git"
  FileUtils.rm    [build + "Rakefile"]
end

desc "Create a zip file of the lastest release in the downloads directory."
task :zip => [:co_working_copy, :pull_master, :export] do
  src_path    = BUILD_DIR  + TARSKI_DIRNAME
  target_path = PUBLIC_DIR + "downloads/tarski_#{TARSKI_VERSION}.zip"
  
  `cd #{src_path}; zip -rq #{target_path} .`
end
