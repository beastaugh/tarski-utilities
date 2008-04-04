require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'yaml'

CONFIG = YAML::load(File.open("conf/config.yml"))
PUBPATH = CONFIG["pubpath"]
VDATA = YAML::load(File.open("conf/version.yml"))
VERSION = VDATA["version"]
SVN_URL = "http://tarski.googlecode.com/svn"
SSL_SVN_URL = "https://tarski.googlecode.com/svn"

task :default do
  Rake::Task["tarski:update"].invoke
end

namespace :tarski do
  
  desc "Runs a full version update. By default a new release is not tagged in the Subversion repository."
  task :update => [:zip, :feed, :changelog]
  
  desc "Update the version feed to notify Tarski users of the new release."
  task :feed => [:changelog] do
    require 'lib/tarski_version'
    TarskiVersion.new(VDATA).publish_feed("#{PUBPATH}/version.atom")
  end
  
  desc "Generate a new changelog HTML file."
  task :changelog do
    require 'bluecloth'
    require 'rubypants'
    require 'hpricot'
    require 'open-uri'
    
    puts "Reading files..."
    
    struct = File.open("conf/changelog-structure.html", "r") do |file|
      struct = Hpricot(file.read)
    end
    
    doc = open("#{SVN_URL}/trunk/CHANGELOG") do |file|
      # Changelog is provided in Markdown format, so it needs to be passed
      # through BlueCloth before being read into Hpricot.
      Hpricot(BlueCloth::new(file.read).to_html)
    end
    
    vlinks = Array.new
    
    puts "Generating changelog HTML file..."
    
    (doc/"h1").remove
    
    (doc/"h3").each do |header|
      version = header.inner_html.scan(/^Version (\d\.\d\.\d|\d\.\d)/).first
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
  task :zip do
    puts "Downloading Tarski files..."
    %x{svn export #{SVN_URL}/releases/#{VERSION} tarski}
    puts "Creating zip file..."
    %x{zip -rm #{PUBPATH}/downloads/tarski_#{VERSION}.zip tarski}
    puts "done."
  end
  
  desc "Tag a new release in the Subversion repository."
  task :tag do
    puts "Tagging version #{VERSION}..."
    %x{svn copy #{SSL_SVN_URL}/trunk #{SSL_SVN_URL}/releases/#{VERSION} tarski}
    puts "Done."
  end
  
  desc "Create a new branch in the Subversion repository."
  task :branch do
    puts "Creating branch #{VERSION}..."
    %x{svn copy #{SSL_SVN_URL}/trunk #{SSL_SVN_URL}/branches/#{VERSION} tarski}
    puts "Done."
  end
end
