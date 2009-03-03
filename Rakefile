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

CONFIG = YAML::load(File.open("conf/config.yml"))
VDATA = TarskiUtils::version_info("conf/version.yml")

PUBPATH = CONFIG["pubpath"]
TVERSION = ENV['v'] || VDATA.first.first
TDIR = "tarski"
SVN_URL = CONFIG["svn_url"]
GIT_REPO = CONFIG["git_repo"]

desc "Creates a zip archive, and updates the version feed and changelog."
task :update => [:zip, :feed, :changelog]

desc "Update the version feed to notify Tarski users of the new release."
task :feed do
  require 'lib/tarski_version'
  puts "Generating version feed..."  
  TarskiVersion.new(VDATA, CONFIG["feed"]).publish_feed("#{PUBPATH}/version.atom")
  puts "Done."
end

desc "Generate the hooks documentation page."
task :hooks do
  require 'erb'
  require 'lib/tarski_docs'
  
  Dir.chdir(Dir.pwd + '/' + TDIR)
  
  TarskiDocs.new(Dir.pwd).read
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
    Hpricot(BlueCloth::new(file.read).to_html)
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
  
  File.open("#{PUBPATH}/changelog.html", "w+") do |changelog|
    changelog.puts(RubyPants.new(struct.to_html).to_html)
  end
  
  puts "Done."
end

desc "Create a zip file of the lastest release in the downloads directory."
task :zip => :download do
  puts "Creating zip file..."
  %x{zip -rm #{PUBPATH}/downloads/tarski_#{TVERSION}.zip #{TDIR}}
  puts "Done."
end

desc "Export the latest release files."
task :download do
  %x{rm -rf #{TDIR}}
  Rake::Task['git_export'].invoke
end

desc "Export the latest release from the Subversion repository."
task :svn_export do
  puts "Downloading Tarski files..."
  %x{svn export #{SVN_URL}/releases/#{TVERSION} #{TDIR}}
end

desc "Export the latest release from a Git repository."
task :git_export do
  here = Dir.pwd
  there = "#{here}/#{TDIR}"
  puts "Cloning Git repository..."
  %x{git clone #{GIT_REPO} #{there}}
  Dir.chdir(there)
  %x{git checkout -b #{TVERSION} #{TVERSION}}
  puts "Pruning .git directory..."
  %x{rm -rf #{there}/.git/}
  Dir.chdir(here)
end
