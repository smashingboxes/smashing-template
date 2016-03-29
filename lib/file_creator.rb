$path = File.expand_path(File.dirname(__FILE__))

def render_file(path)
  IO.read(path)
end
