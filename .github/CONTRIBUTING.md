# Contributing to Boxcar

If you find an issue, or would like to request a new feature, please do so in the Github issue
tracker for this repo.

If you'd like to fix an issue, or implement a new feature, please submit a pull request, following
the guidelines below.

## Boxcar architecture

In the following documentation, the term **generated app** refers to the rails app that is created
by Boxcar.

The code for Boxcar is broken into two major parts: the **command classes**, and the **builder class**

### Command classes

The **command classes** are the top-level classes that get used when running the command line. For
example, when running `boxcar new`, the `Boxcar::Commands::New` handles that functionality. Those
classes should be as high-level as possible, and call out to the methods in the builder class
(via `build`) when actual making changes to the generated project.

For more info about how the command classes work, see the comment at the top of the class file.

### Builder class

The **builder class** provides the implementation details about how each item is implemented. For
instance, the `readme` method defines the logic for how the readme is generated. Lots of methods
are provided by `Rails::AppBuilder` and `Thor::Actions`. Here are some of the most often used ones:

| Method Name | Usage Example | Description |
| --- | --- | --- |
| copy_file | copy_file "boxcar_file", "app_file" | Copies a file from the `templates` directory of boxcar, into the generated app |
| template | template "boxcar_template, "app_file" | Given a boxcar_template erb template file in the boxcar `templates` directory, it generates a file in the generated app |
| remove_file | remove_file "app_file" | Removes a file from the generated app |
| gsub_file | gsub_file "app_file", /regex/, "replacement" | In the given application file, find strings matching the given regex, and replace with the replacement string |
| generate | generate "model User ..." | Runs the given `rails generate` command inside the generated rails app |
| run | run "echo 'hello' > world.txt" | Runs the given command inside the generated rails app

For a more complete list, see [this page](http://www.rubydoc.info/github/wycats/thor/Thor/Actions).

## Tests

Every new features should have tests to go with it. Boxcar's tests are written in RSpec. Here are
a few things to be aware of with our test suite:

- In the [/spec/boxcar/new](/spec/boxcar/new) directory, we have specs for the `boxcar new` command.
  Each file is testing the behavior for a specific flag that can be given to Boxcar. The flags are
  used as an alternative to the interactive prompts, for easier testing.
- Specs that are common to all flags (e.g. generating the Gemfile) are in
  [/spec/support/shared_examples/basic_setup_steps.rb](/spec/support/shared_examples/basic_setup_steps.rb)
- Boxcar takes a while to run. To minimize test build times, we optimize for running Boxcar as
  few times as possible. Boxcar gets set up and run via the `setup_and_run_boxcar_new` method.
  We call that method (and its related setup steps) in a `before(:all)` block, rather than the
  normal `subject` or `before(:each)`.
- The `expect_prompt_and_answer` method is available for testing and stubbing
  interactive prompts. All of the calls to that method need to be set up before
  boxcar runs, otherwise the tests will hang, waiting for input from the user.
  `setup_and_run_boxcar_new` supports passing a block, which is designed for this purpose.
  See `no_flags_spec.rb` for an example.
- If you're wondering how to test something, take a look at similar specs in other files. If you're
  still having trouble, feel free to ask for help in your PR or elsewhere.
- IMPORTANT! You must have Postgres running; otherwise, some specs will fail.
