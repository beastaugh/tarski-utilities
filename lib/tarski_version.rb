require 'rubygems'
require 'builder'

# The Tarski update notifier: a simple Atom feed generator.
# 
# You can use this to create an Atom feed for a dead-simple update notifier
# which, unlike the built-in WordPress update notifier, requires no data
# from the client, since all it does is check the version listed in the feed
# and match it against its own version.
class TarskiVersion
  
  # Version data is passed to the constructor so it's not too tightly coupled
  # with the data collection method.
  def initialize(version_data, config)
    @versions = version_data
    @config = config
    @datetime = version_data.first.first["datetime"] || Time.now.xmlschema
  end
  
  # Writes an Atom feed encapsulating the version data to the target location.
  def publish_feed(target)
    @file = File.new(target, "w+")
    xml = Builder::XmlMarkup.new(:target => @file, :indent => 2)
    xml.instruct!
    xml.feed :xmlns => "http://www.w3.org/2005/Atom", "xml:lang" => "en-GB" do
      xml.title     @config["title"]
      xml.link      :rel => "alternate", :href => @config["url"]
      xml.link      :rel => "self", :href => @config["url"] + File.basename(target)
      xml.id        @config["url"]
      xml.updated   @datetime

      @config["author"].each do |name|
        xml.author  { xml.name name }
      end
      
      @versions.each do |vnumber, vdata|
        xml.entry do
          xml.title   vnumber
          xml.link    :rel => "alternate", :href => vdata["link"]
          xml.id      vdata["link"]
          xml.updated vdata["datetime"] || @datetime
          xml.summary { xml.text! vdata["summary"] }
        end
      end
    end
  end
end
