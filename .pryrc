lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'attr_delegated'

class Bar
  attr_accessor :baz, :quux

  attr_reader :value

  def initialize(value = 9000)
    @value = value

    @baz = value.to_s * 2
    @quux = value.to_s * 3
  end
end

class Foo
  extend AttrDelegated

  attr_delegated :baz, :quux, to: :bar

  attr_reader :bar

  def initialize(new_bar = 9000)
    @bar = Bar.new new_bar
  end
end
