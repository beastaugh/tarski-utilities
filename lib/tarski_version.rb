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
  # 
  # It just uses the current time so if your client cares about that, you might
  # want to change it so the date and time are specified in the version data.
  def initialize(version_data)
    @version_data = version_data
    @time = DateTime.now.to_s
  end
  
  # Writes an Atom feed encapsulating the version data to the target location.
  # 
  # Currently it only does one--i.e. the latest--entry. This is just a
  # limitation of my simplistic config file; adding support for multiple
  # entries would be trivial.
  # 
  # TODO: Move some of the configuration details out of the class.
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
