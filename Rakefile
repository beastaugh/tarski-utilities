require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'yaml'

CONFIG = YAML::load(File.open("conf/version_data.yml"))
VERSION = CONFIG["version"]

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
    
    puts "Downloading Tarski files..."
    %x{svn export http://tarski.googlecode.com/svn/releases/#{VERSION} tarski}
    
    puts "Building changelog file..."
    File.open("tarski/CHANGELOG", "r") do |file|
      doc = Hpricot(BlueCloth::new(file.read).to_html)
      vlinks = Array.new
    
      (doc/"h3").each do |header|
        version = header.inner_html.scan(/^Version (\d\.\d\.\d|\d\.\d)/).first
        header.set_attribute('id', "v#{version}")
        vlinks << "<li><a href=\"#v#{version}\">Version #{version}</a></li>"
      end
    
      vlinks = "<ul id=\"version-links\"></ul>\n" + vlinks.join("\n") + "\n</ul>\n\n"
      html = vlinks + doc.to_html
    
      changelog = File.open("public_html/changelog.html", "w+")
      changelog.puts(RubyPants.new(html).to_html)
    end
    
    print "Removing Tarski files..."
    %x{rm -rf tarski}
    puts " Done!"
  end
  
  desc "Create a zip file of the lastest release in the downloads directory."
  task :zip_release do
    file = "tarski_#{VERSION}.zip"
    %x{svn export http://tarski.googlecode.com/svn/releases/#{VERSION} tarski}
    %x{zip -rm #{file} tarski}
    %x{mv #{file} public_html/downloads/#{file}}
  end
  
  desc "Tag a new release in the Subversion repository."
  task :tag_release do
    %x{svn copy https://tarski.googlecode.com/svn/trunk https://tarski.googlecode.com/svn/releases/#{VERSION} tarski}
  end
end
