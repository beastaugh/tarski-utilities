module TarskiUtils
  
  def self.version_to_int(version)
    # Cut it down to just numeric characters
    version = version.gsub(/\D/, "")
    
    if version.length > 0
      if version.length == 1
        version += "00"
      elsif version.length == 2
        version += "0"
      elsif version.length > 3
        version = version[1..3]
      end
      
      version = version.to_i
    else
      version = nil
    end
    
    return version
  end
  
  def self.version_info(vfile)
    vdata = YAML::load(File.open(vfile))
    nvdata = {}
  
    vdata.each do |key, value|
      nvdata[key.to_s] = value
      value["datetime"] = value["datetime"].xmlschema unless value["datetime"].nil?
    end
    
    nvdata.to_a.sort do |x,y|
      version_to_int(y[0]) <=> version_to_int(x[0])
    end
  end
end
