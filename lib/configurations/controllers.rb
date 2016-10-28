require_relative '../content_editor'

class Controllers
  attr_reader :path, :controllers, :name_ending

  def initialize(args)
    @path = args.fetch(:path, "")
    @controllers = args.fetch(:controllers, [])
    @name_ending = "_controller"
  end

  def override
    replace_controllers
  end

  private

  def replace_controllers
    controllers.each do |controller|
      controller_path = "#{path}/#{controller}_controller.rb"
      replace_content(
        path: controller_path
      )
    end
  end
end
