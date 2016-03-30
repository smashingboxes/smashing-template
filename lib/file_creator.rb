def path(file)
  File.join(File.dirname(__FILE__), "files/", file)
end

def render_file(path)
  IO.read(path)
end
