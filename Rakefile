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
    
    puts "Building HTML..."
    File.open("CHANGELOG", "r") do |file|
      doc = Hpricot(BlueCloth::new(file.read).to_html)
      vlinks = Array.new
    
      (doc/"h3").each do |header|
        version = header.inner_html.scan(/^Version (\d\.\d\.\d|\d\.\d)/).first
        header.set_attribute('id', "v#{version}")
        vlinks << "<li><a href=\"#v#{version}\">Version #{version}</a></li>"
      end
      
      updated_at = "\n\n<p class=\"metadata\">Last updated #{Time.now.strftime("%B %d %Y")}</p>"
      vlinks = "\n\n<h3>Contents</h3>
      
      <ul id=\"version-links\">
          #{vlinks.join("\n")}
      </ul>\n\n"
      
      (doc/"h1").set('class', 'title').wrap(%{<div id="changelog-header" class="meta"></div>})
      doc.at("h1").after(updated_at)
      doc.at("#changelog-header").after(vlinks)
    
      changelog = File.open("public_html/changelog.html", "w+")
      changelog.puts(RubyPants.new(doc.to_html).to_html)
    end
    
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
