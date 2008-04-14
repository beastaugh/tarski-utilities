require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'yaml'

CONFIG = YAML::load(File.open("conf/config.yml"))
PUBPATH = CONFIG["pubpath"]
VDATA = YAML::load(File.open("conf/version.yml"))
TVERSION = ENV['v'] || VDATA["version"]
SVN_URL = "http://tarski.googlecode.com/svn"
SSL_SVN_URL = "https://tarski.googlecode.com/svn"

desc "Creates a zip archive, and updates the version feed and changelog."
task :update => [:zip, :feed, :changelog]

desc "Update the version feed to notify Tarski users of the new release."
task :feed => [:changelog] do
  require 'lib/tarski_version'
  puts "Generating version feed..."
  TarskiVersion.new(VDATA).publish_feed("#{PUBPATH}/version.atom")
  puts "Done."
end

desc "Generate a new changelog HTML file."
task :changelog do
  require 'bluecloth'
  require 'rubypants'
  require 'hpricot'
  require 'open-uri'
  
  puts "Reading changelog..."
  
  struct = File.open("conf/changelog-structure.html", "r") do |file|
    Hpricot(file.read)
  end
  
  doc = open("#{SVN_URL}/trunk/CHANGELOG") do |file|
    # Changelog is provided in Markdown format, so it needs to be passed
    # through BlueCloth before being read into Hpricot.
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
task :zip do
  puts "Downloading Tarski files..."
  %x{svn export #{SVN_URL}/releases/#{TVERSION} tarski}
  puts "Creating zip file..."
  %x{zip -rm #{PUBPATH}/downloads/tarski_#{TVERSION}.zip tarski}
  puts "Done."
end
