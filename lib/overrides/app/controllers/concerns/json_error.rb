class JsonError
  attr_reader :path, :pointer, :detail

  def initialize(args)
    @path = args.fetch(:path, "/data/attributes/")
    @pointer = args.fetch(:pointer, "")
    @detail = args.fetch(:detail, "")
  end

  def create_error
    {
      source: { pointer: "#{path}#{pointer}" },
      detail: detail
    }
  end

  def create_404
    create_error.merge(
      status: "404",
      title: "Not Found"
    )
  end

  def create_422
    create_error.merge(
      status: "422",
      title: "Validation Failed"
    )
  end

  def create_401
    create_error.merge(
      status: "401",
      title: "Unauthorized"
    )
  end
end
