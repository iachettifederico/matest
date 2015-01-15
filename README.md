# Matest
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/iachettifederico/matest?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Tests Gasoleros (Very cheap tests)

## Description

Matest is a very small testing library.

It doesn't use the usual assertion style (`assert(1, 1)`) nor the rspec style(`1.should == 1` or `1.must_equal(1)`).

It uses natural assertions.

This means that:
- A test will pass if it returns `true`
- A test will fail if it returns `false`

## Usage

To run Matest, you just need to execute the `matest` command, passing as arguments the desired test files.

```bash
$ matest spec/my_spec.rb
```

You can also use wildcards.

For example, to run all the specs in a directory:
```bash
$ matest spec/*_spec.rb
```

Or to run recursively
```bash
$ matest spec/**/*_spec.rb
```

## Specs

To define a test, first you need to set a scope, and inside it, define your spec.
```ruby
scope do
  spec do
    true
  end
end
```

If the return value of the `spec` block is `true`, the spec will pass and if it's `false` it will fail.

If you return anithing else, you'll get a `NOT A NATURAL ASSERTION` status.

You can also add descriptions to either the `scope` or the `spec` blocks:

```ruby
scope "a description" do
  spec "another description" do
    true
  end
end
```

## Constraints

A couple of constraints must b taken into account, and this is extremely important.

### The assertion MUST return a boolean

The assertion is the last statement of the block and it must return either true or false.
This is important, because the assertion will be evaluated and it will provide the status o the test.

### Assertion expression

The assertion can be any expression that returns a boolean value, BUT IT CANNOT CONTAIN LOCAL VARIABLES.
If the assertion contains a local variable and it fails, the code that explains it bit by bit will throw an error.

## Raising Errors

If your test raises an error during the run, youll get an `ERROR` status and you'll see the backtrace.

## Skipping

You can skip a test in two possible ways: You can declare a spec whithout a block or use the `xspec` method.

```ruby
scope do
  spec "I'll be skipped"
  xspec "I'll be skipped too" do
    true
  end
end
```

This will skip you spec and inform you when you run.

You can skip the whole scope  by using `xscope` instead of `scope`.

Take into account that `xscope` is a no-op so you won't be informed when you skip a scope.

## `#let` and `#let!`

Matest steals the `let` and `let!` features from `RSpec` and `Minitest`.

With `let` you can declare a lazy variable valid on the current scope and all sub-scopes. `let!` has the same efect, but it won't be lazy (it wil be loaded when defined).

Here are some examples of what you can do with them:

```ruby
scope do
  let(:m1) { :m1 }
  let!(:m3) { :m3 }
  
  let(:m4) { :m4 }
  let!(:m5) { :m5 }

  spec do
    m1 == :m1
  end

  spec do
    ! defined?(m2)
  end

  spec do
    m3 == :m3
  end

  spec do
    ! defined?(@m4)
  end

  spec do
    !! defined?(@m5)
  end
  
  scope do
    let(:m2) { :m2 }
    spec do
      m1 == :m1
    end

    spec do
      m2 == :m2
    end
  end
end
```

## The output

In case the test fails or is not a natural assertion, you'll get an extensive explanation about why.

To show a trivial example:

```ruby
scope do
  let(:three) { 3 }
  spec "Printing Failing Specs" do
    one = 2
    two = 2
    @one_plus_two_plus_three = one + two + three
    @res = 3
    
    @one_plus_two_plus_three.to_i == @res
  end
end
```

It fails and the output will be

```
F

### Messages ###

[FAILING] Printing Failing Specs
Location:
  spec/matest_specs/printing_assertion_spec.rb:3:
Assertion: 
  @one_plus_two_plus_three.to_i == @res
Variables: 
  @one_plus_two_plus_three: 7
  @res: 3
Lets: 
  three: 3
Explanation:
  "@one_plus_two_plus_three.to_i == @res" =>
    false
  "@one_plus_two_plus_three.to_i" =>
    7
```

## Matchers

Matest doesn't come with predefined matchers, it doesn't need them. In fact, the concept of a matcher is not required, because of the natural assertions nature of the library.

But you can define helper methods to *assert* long, complex or repeated logic:

```ruby
def is_even?(val)
  val % 2 == 0
end

scope do
  spec do
    is_even?(4)
  end

  spec do
    ! is_even?(5)
  end
end
```

## Aliases

You may be used to other keywords provenient from different testing frameworks. Matest has a couple of alias that you may use indistinctly to fit your style.

`scope` has the following aliases:
- `context` (and `xcontext`)
- `describe` (and `xdescribe`)
- `group` (and `xgroup`)

`spec` has the following aliases:
- `it` (and `xit`)
- `test` (and `xtest`)
- `example` (and `xexample`)

## Configuration

You can add some configuration to the way the tests are run, by using the ```Matest.configure``` method.

To use it, you need to pass a block with the configuration instructions inside.

```ruby
Matest.configure do |config|
  config.use_color
end
```

### Color

You can tell Matest to use colored output by calling the ```use_color``` method on the config object

```ruby
Matest.configure do |config|
  config.use_color
end
```

## TODO ... or not TODO
- Before and after callbacks
- matest-given-ish
- Allow seamless transition (separated gems)
  * matest-assert (to move from TestUnit, Minitest::Unit, Cutest)
  * matest-should (to move from RSpec
  * matest-must (to move from Minitest::Spec)
- Run "<file>:<line>"
  Should run the enclosing test or scope

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'matest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install matest

## Known Issues

- If the test contains a here doc and it fails, it raises a Sorcerer error

## Contributing

1. Fork it ( https://github.com/[my-github-username]/matest/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
