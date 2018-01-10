module ThorHelpers
  # https://bokstuff.com/testing-thor-command-lines-with-rspec/
  #
  # This method allows us to capture the output of thor commands like:
  # let(:output) { capture(:stdout) { subject.command 'foo' } }
  #
  # rubocop:disable Security/Eval
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new", binding, __FILE__, __LINE__
      yield
      result = eval("$#{stream}", binding, __FILE__, __LINE__).string
    ensure
      eval("$#{stream} = #{stream.upcase}", binding, __FILE__, __LINE__)
    end

    result
  end
  # rubocop:enable Security/Eval
end
