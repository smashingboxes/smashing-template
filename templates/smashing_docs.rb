SmashingDocs.config do |c|
  c.template_file = "smashing_docs/template.erb"
  c.output_file   = "smashing_docs/api_docs.rb"
  c.run_all       = true
  c.auto_push     = false
  c.wiki_folder   = nil
end
