require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'yaml'

CONFIG = YAML::load(File.open("conf/version.yml"))
TVERSION = CONFIG["version"]

task :default do
  Rake::Task["tarski:update"].invoke
end

namespace :tarski do
  
  desc "Runs a full version update. By default a new release is not tagged in the Subversion repository."
  task :update => [:zip_release, :feed]
  
  desc "Update the version feed to notify Tarski users of the new release."
  task :feed => [:changelog] do
    require 'lib/tarski_version'
    TarskiVersion.new(CONFIG).publish_feed("public_html/version.atom")
  end
  
  desc "Generate a new changelog HTML file."
  task :changelog do
    require 'bluecloth'
    require 'rubypants'
    require 'hpricot'
    
    puts "Downloading changelog..."
    %x{svn export http://tarski.googlecode.com/svn/trunk/CHANGELOG}
    
    puts "Reading files..."
    
    sf = File.open("conf/changelog-structure.html", "r")
    struct = Hpricot(sf.read)
    sf.close
    
    df = File.open("CHANGELOG", "r")
    doc = Hpricot(BlueCloth::new(df.read).to_html)
    df.close
    
    vlinks = Array.new
    
    puts "Generating HTML..."
    
    (doc/"h1").remove
    
    (doc/"h3").each do |header|
      version = header.inner_html.scan(/^Version (\d\.\d\.\d|\d\.\d)/).first
      header.set_attribute('id', "v#{version}")
      vlinks << "<li><a href=\"#v#{version}\">Version #{version}</a></li>"
    end
    
    struct.at("#changelog-updated").inner_html = "Last updated #{Time.now.strftime("%B %d %Y")}"
    struct.at("#version-links").inner_html = vlinks.join("\n")
    struct.search("#version-links").after(doc.to_html)
    
    changelog = File.open("public_html/changelog.html", "w+")
    changelog.puts(RubyPants.new(struct.to_html).to_html)
    changelog.close
    
    print "Removing changelog..."
    %x{rm CHANGELOG}
    puts " Done!"
  end
  
  desc "Create a zip file of the lastest release in the downloads directory."
  task :zip_release do
    file = "tarski_#{TVERSION}.zip"
    %x{svn export http://tarski.googlecode.com/svn/releases/#{TVERSION} tarski}
    %x{zip -rm #{file} tarski}
    %x{mv #{file} public_html/downloads/#{file}}
  end
  
  desc "Tag a new release in the Subversion repository."
  task :tag_release do
    %x{svn copy https://tarski.googlecode.com/svn/trunk https://tarski.googlecode.com/svn/releases/#{TVERSION} tarski}
  end
  
  desc "Create a new branch in the Subversion repository."
  task :branch do
    %x{svn copy https://tarski.googlecode.com/svn/trunk https://tarski.googlecode.com/svn/branches/#{TVERSION} tarski}
  end
end
