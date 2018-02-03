# Boxcar specs

The specs in this directory test all the possible flags that you can give to boxcar. The
following are a few things to note for how these specs work:

- Boxcar gets set up and run via the `setup_and_run_boxcar_new` method. Running
  boxcar takes a bit of time, so we don't want to do it more often than necessary.
  Because of that, we call that method (and it's related setup steps) in a
  `before(:all)` block, rather than the normal `subject` or `before(:each)`.
- The `expect_prompt_and_answer` method is available for testing and stubbing
  interactive prompts. All of the calls to that method need to be set up before
  boxcar runs, otherwise the tests will hang, waiting for input from the user.
  `setup_and_run_boxcar_new` supports passing a block, which is designed for this purpose.
  See `no_flags_spec.rb` for an example.
- All output from the boxcar run is captured in the `run_boxcar_new` method,
  to reduce the noise in the test output. This might be a hinderance to debugging,
  and can be revisited later, but for now, feel free to comment out those lines when necessary.
