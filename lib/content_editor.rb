# def replace_content(replacement: {}, path: "")
def replace_content(path: "")
  File.open(path, "w") do |f|
    # f.puts render(replacement: replacement)
    f.puts render(path: path)
  end
end

def render(path: "")
  render_file(File.join(File.dirname(__FILE__), "/overrides/#{path}"))
end
