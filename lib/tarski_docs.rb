require 'find'

class TarskiDocs
  
  def initialize(src_dir)
    locate_src_files(src_dir)
  end
  
  def read
    @hooks = @files.map do |file|
      comments = File.readlines(file).inject([0]) do |comments, line|
        comments[0] = 0 if line =~ /^\s+\*\/\s*$/m
        comments.last << line if comments.first === 1
        
        if line =~ /^\s*\/\*\*\s*$/m
          comments[0] = 1
          comments << []
        end
        
        comments
      end
      
      comments[1..-1]
    end.inject([]) {|f, comments| comments.concat(f) }.
    inject([0]) do |hooks, comment|
      hooks[0] = 0
      comment.each do |line|
        hooks[0] = 0 if line =~ /^\s+\*\s+@/m
        
        if line =~ /^\s+\*\s+@hook/
          hooks[0] = 1
          hooks << []
        end
        
        if hooks.first === 1
          hooks.last << line.gsub(/^\s*\*\s*/, "").gsub(/^@[a-z]+/, "").strip
        end
      end
      
      hooks
    end[1..-1].inject({:actions => [], :filters => []}) do |hooks, hook|
      name = hook.shift.split(/\s+/)
      type = name.shift
      hook = {:name => name.first, :description => hook.join(" ")}
      (name.first == "action" ? hooks[:actions] : hooks[:filters]) << hook
      hooks
    end
  end
  
  def write
    # ...
  end
  
  private
  
  def locate_src_files(dir)
    @src_dir, @files = dir, []
    
    Find.find(@src_dir) do |path|
      if FileTest.directory?(path)
        File.basename(path)[0] == ?. ? Find.prune : next
      elsif File.basename(path) =~ /\.php$/
        @files << path
      end
    end
    
    @files
  end  
end
