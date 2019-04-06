# Einsum

[![Build Status](https://travis-ci.org/toddsundsted/einsum.svg?branch=master)](https://travis-ci.org/toddsundsted/einsum)
[![Documentation](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://toddsundsted.github.io/einsum/)

Unoptimized, pure-Ruby implementation of a subset of Numpy `einsum`.

See: https://docs.scipy.org/doc/numpy/reference/generated/numpy.einsum.html

## Installation

Add this to your application's Gemfile:

```ruby
gem 'einsum'
```

And then execute:

    $ bundle

Or install it manually:

    $ gem install einsum

## Usage

Evaluates the (extended) Einstein summation convention on the operands.

Operands must be `Array` like. Array elements must respond to `*` and `+`.

Implicit mode:

    Einsum.einsum('ij,jk', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => dot product: [[7, 10], [15, 22]]
    Einsum.einsum('ij,kj', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => inner product: [[ 5, 11], [11, 25]]

Explicit mode:

    Einsum.einsum('ij,jk->ik', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => dot product: [[7, 10], [15, 22]]
    Einsum.einsum('ij,kj->ik', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => inner product: [[ 5, 11], [11, 25]]
    Einsum.einsum('ij,jk->', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => 54
    Einsum.einsum('ij,kj->', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => 52

## Development

After checking out the repository, run `bin/setup` to install
dependencies. Run `bin/console` for an interactive prompt. Run `rake
spec` to run the tests.

To install this gem locally, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb` and
then run `bundle exec rake release`, which will create a git tag for
the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
(https://github.com/toddsundsted/einsum).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
