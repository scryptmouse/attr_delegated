require 'active_support/all'
require 'attr_delegated/options'
require 'attr_delegated/version'

module AttrDelegated
  # Delegate an ActiveModel attribute and all its meta methods to another model,
  # e.g. in addition to the reader: the writer, predicate, and "changed?" methods as well.
  #
  # @param [Array] attrs
  # @param [Hash] options (see AttrDelegated::Options#initialize)
  # @return [void]
  def attr_delegated(*attrs, **options)
    opts = AttrDelegated::Options.new attrs, options 

    delegate *opts
  end
end

ActiveSupport.on_load(:active_record) do
  extend AttrDelegated
end
