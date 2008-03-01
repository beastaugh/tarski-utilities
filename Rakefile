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
  
  desc "Runs a full version update. By default a new release is not tagged in svn."
  task :update => [:zip_release, :feed]
  
  desc "Update the version feed to notify Tarski users of the new release."
  task :feed => [:changelog] do
    require 'lib/tarski_version'
    TarskiVersion.new(CONFIG).publish_feed("public_html/version.atom")
  end
  
  desc "Has the changelog been updated?"
  # Just a reminder about something I tend to forget.
  task :changelog do
    howto = "Say \033[1myes\033[0m when you have."
    puts "Have you updated the changelog yet? #{howto}"
    until gets =~ /^[Yy](|es)\s*$/
      puts "Go and update it, then run rake again. #{howto}"
    end
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
