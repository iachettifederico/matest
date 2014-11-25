# Matest

Tests Gasoleros (Very cheap tests)

## Disclaimer

This gem is still in an experimental version. It currently has some scoping issues and it's not yet suited for production.

But don't despair ... they will be fixed =)

## Description

Matest is a very small testing library.

It doesn't use the usual assertion style (`assert(1, 1)`) nor the rspec style(`1.should == 1` or `1.must_equal(1)`).

It uses natural assertions.

This means that:
- A test will pass if it returns true
- A test will fail if it returns false

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'matest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install matest

## Usage

To run Matest, you just need to execute the `mt` command, passing as arguments the desired test files.

```bash
$ mt spec/my_spec.rb
```

You can also use wildcards.

For example, to run all the specs in a directory:
```bash
$ mt spec/*_spec.rb
```

Or to run recursively
```bash
$ mt spec/**/*_spec.rb
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

If the return value of the `spec` block is `true`, the spec will pass and if it's false it will `fail`.

If you return anithing else, you'll get a `NOT A NATURAL ASSERTION` status.

You can also add descriptions to either the `scope` or the `spec` blocks:

```ruby
scope "a description" do
  spec "another description" do
    true
  end
end
```

## Raising Errors

If your test raises an error during the run, youll get an `ERROR` status and you'll see the backtrace.

## Skipping

You can skip a test in two possible ways: You can declare a spec whithout a block or use the `xspec` method.

```ruby
scope do
  xspec "I'll be skipped" do
    true
  end
  spec "I'll be skipped too"
end
```

This will skip you spec and inform you when you run.

You can skip the whole scope  by using `xscope` instead of `scope`.

Take into account that `xscope` is a no-op so you won't be informed when you skip a scope.

## Let and let!

Matest steals the `let` and `let!` features from `RSpec` and `Minitest`.

With `let` you can declare a lazy variable valid on the current scope and all sub-scopes.

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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/matest/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
