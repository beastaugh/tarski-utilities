require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'yaml'

CONFIG = YAML::load(File.open("conf/version_data.yml"))
version = CONFIG["version"]

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
    require 'hpricot'
    
    # %x{svn export http://tarski.googlecode.com/svn/trunk tarski}
    
    File.open("tarski/CHANGELOG", "r") do |f|
      doc = Hpricot(BlueCloth::new(f.read).to_html)
      versions = Array.new
      
      (doc/"h3").each do |header|
        version = header.inner_html.scan(/^Version (\d\.\d\.\d|\d\.\d)/).first
        header.set_attribute('id', version)
        versions << version
      end
      
      puts doc.class
      versions.each {|v| puts v }
      
      changelog = File.open("public_html/changelog.html", "w+")
      changelog.puts(doc.to_html)
    end
    
    # %x{rm -rf tarski}
  end
  
  desc "Create a zip file of the lastest release in the downloads directory."
  task :zip_release do
    file = "tarski_#{version}.zip"
    %x{svn export http://tarski.googlecode.com/svn/releases/#{version} tarski}
    %x{zip -rm #{file} tarski}
    %x{mv #{file} public_html/downloads/#{file}}
  end
  
  desc "Tag a new release in the Subversion repository."
  task :tag_release do
    %x{svn copy https://tarski.googlecode.com/svn/trunk https://tarski.googlecode.com/svn/releases/#{version} tarski}
  end
end
