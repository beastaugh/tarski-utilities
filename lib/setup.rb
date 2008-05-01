module TarskiUtils
  
  def self.version_info(vfile)
    vdata = YAML::load(File.open(vfile))
    nvdata = {}
  
    vdata.each do |key, value|
      nvdata[key.to_s] = value
      value["datetime"] = value["datetime"].xmlschema unless value["datetime"].nil?
    end
    
    nvdata.to_a.reverse
  end
end
