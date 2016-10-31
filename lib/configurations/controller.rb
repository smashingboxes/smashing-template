require_relative '../content_editor'

class Controller
  attr_reader :path, :controller, :name_ending

  def initialize(args)
    @path = args.fetch(:path, "")
    @controller = args.fetch(:controller, "")
    @name_ending = "_controller"
  end

  def override
    controller_path = "#{path}/#{controller}_controller.rb"
    replace_content(path: controller_path)
  end
end
