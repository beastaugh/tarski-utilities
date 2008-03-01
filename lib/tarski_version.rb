# Tarski update notifier - Atom feed generator
require 'rubygems'
require 'builder'

class TarskiVersion
  
  def initialize(version_data)
    @version_data = version_data
    @time = DateTime.now.to_s
  end
    
  def publish_feed(target)
    @file = File.new(target, "w+")
    xml = Builder::XmlMarkup.new(:target => @file, :indent => 2)
    xml.instruct!
    xml.feed :xmlns => "http://www.w3.org/2005/Atom", "xml:lang" => "en-GB" do
      xml.title     "Tarski update notification"
      xml.link      :rel => "alternate", :href => "http://tarskitheme.com/"
      xml.link      :rel => "self", :href => "http://tarskitheme.com/version.atom"
      xml.id        "http://tarskitheme.com/"
      xml.updated   @time
      xml.author    { xml.name "Benedict Eastaugh" }
      xml.author    { xml.name "Chris Sternal-Johnson" }
  
      xml.entry do
        xml.title   @version_data["version"]
        xml.link    :rel => "alternate", :href => @version_data["link"]
        xml.id      @version_data["link"]
        xml.updated @time
        xml.summary { xml.text! @version_data["summary"] }
      end
    end
  end
end
