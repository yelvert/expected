# Expected: RSpec Matchers - Extended [![Gem Version][version-badge]][rubygems] [![Total Downloads][downloads-total]][rubygems] [![Downloads][downloads-badge]][rubygems]

[version-badge]: https://img.shields.io/gem/v/expected.svg
[rubygems]: https://rubygems.org/gems/expected
[downloads-total]: https://img.shields.io/gem/dt/expected.svg
[downloads-badge]: https://img.shields.io/gem/dtv/expected.svg

Adds several simple matchers to RSpec



## Installation

### Add to Gemfile
```ruby
group :test do
  gem 'expected'
end
```

### Add to RSpec
Add the following to your projects `spec/rails_helper.rb` for Rails apps, or `spec/spec_helper.rb` for non-Rails apps.
```ruby
Expected.configure
```





## Usage



### `be_a_concern`
Used to test that a Module is an ActiveSupport::Concern

```ruby
# Test if the subject is an ActiveSupport::Concern`
it { is_expected.to be_a_concern }
```



### `extend_module`
Used to test that a Class or Module extends the supplied Module

```ruby
# Test if the subject extends the supplied Module
it { is_expected.to extend_module(SomeModule) }
```



### `have_constant`
Used to test constants

```ruby
# Test if a constant exists
it { is_expected.to have_constant(:FOO) }

# Test if a constant has a specific value
it { is_expected.to have_constant(:FOO).with_value("bar") }

# Test if a constant's value is a specific type
it { is_expected.to have_constant(:FOO).of_type(String) }
```



### `have_attr_reader`
Used to test inclusion of `attr_reader :attribute`

```ruby
# Test if the subject has `attr_reader :attribute`
it { is_expected.to have_attr_reader(:attribute) }
```



### `have_attr_writer`
Used to test inclusion of `attr_writer :attribute`

```ruby
# Test if the subject has `attr_writer :attribute`
it { is_expected.to have_attr_writer(:attribute) }
```



### `have_attr_accessor`
Used to test inclusion of `attr_accessor :attribute`

```ruby
# Test if the subject has `attr_accessor :attribute`
it { is_expected.to have_attr_accessor(:attribute) }
```



### `include_module`
Used to test that a Class or Module includes the supplied Module

```ruby
# Test if the subject includes the supplied Module
it { is_expected.to include_module(SomeModule) }
```



### `inherit_from`
Used to test inheritance

```ruby
# Test if the subject inherits from the supplied Class
it { is_expected.to inherit_from(SomeClass) }
```



## License
Expected is copyright © 2019-2020 Taylor Yelverton.
It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
