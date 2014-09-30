module AttrDelegated
  class Options
    METHODS = {
      reader:           "%s",
      writer:           "%s=",
      predicate:        "%s?",
      type_cast:        "%s_before_type_cast",
      dirty: %w[
        %s_change
        %s_changed?
        %s_will_change!
        %s_was
        reset_%s!
      ]
    }

    GROUPS = METHODS.keys

    DELEGATE_OPTION_KEYS = %i[to allow_nil prefix]

    DEFAULTS = Hash[GROUPS.zip([true] * GROUPS.length)]

    # @!attribute [r] attributes
    # @api private
    # @return [Array<String, Symbol>]
    attr_reader :attributes

    # @!attribute [r] raw_options
    # @api private
    # @return [Hash]
    attr_reader :raw_options

    UNIQUE_KEYS = %i[only skip]

    # @param [Array<String, Symbol>] attributes
    # @param [Hash] raw_options
    # @option raw_options [Symbol, String] :to **Must be set!** Passed to delegate
    # @option raw_options [Boolean] :allow_nil Passed to `delegate`
    # @option raw_options [Boolean, String, Symbol] :prefix Passed to `delegate`
    # @option raw_options [Boolean] :reader (true) Whether to delegate the reader
    # @option raw_options [Boolean] :writer (true) Whether to delegate the writer
    # @option raw_options [Boolean] :predicate (true) Whether to delegate the predicate
    # @option raw_options [Boolean] :type_cast (true) Whether to delegate the `before_type_cast` method
    # @option raw_options [Boolean] :dirty (true) Whether to delegate the "dirty" methods
    # @option raw_options [Array, Symbol] :only Can delegate only certain methods, incompatible with `:without`
    # @option raw_options [Array, Symbol] :skip Can skip delegate only certain methods
    def initialize(attributes, raw_options = {})
      @attributes   = Array( attributes )
      @raw_options  = raw_options.reverse_merge DEFAULTS

      check_for_attributes!
      check_for_to!
      check_for_unique_key_conflict!
    end

    # @!attribute [r] delegated_methods
    # @return [Array<Symbol>]
    def delegated_methods
      @delegated_methods ||= attributes.flat_map do |attribute|
        delegated_method_formats.map do |format|
          format % attribute
        end
      end
    end

    def to_a
      [*delegated_methods, options_for_delegate]
    end

    private
    # @raise [ArgumentError] unless 1 or more attributes provided
    # @return [void]
    def check_for_attributes!
      raise ArgumentError, "must provide attributes to delegate!" if attributes.none?
    end

    # @raise [ArgumentError] unless option `:to` is set
    # @return [void]
    def check_for_to!
      raise ArgumentError, "must define `:to` to delegate!" unless option? :to
    end

    # @raise [ArgumentError] if `:only` and `:skip` are both set
    # @return [void]
    def check_for_unique_key_conflict!
      if unique_keys.many?
        quoted_unique_keys = unique_keys.map { |k| "`%s`" % k }.to_sentence

        raise ArgumentError, "cannot set #{quoted_unique_keys} at the same time"
      end
    end

    # @return [Array<String>]
    def delegated_method_formats
      @delegated_method_formats ||= METHODS.values_at(*delegates).flatten
    end

    # @!attribute [r] delegates
    # @api private
    # @return [Array<Symbol>]
    def delegates
      @delegates ||= detect_delegates!
    end

    # @return [Array]
    def detect_delegates!
      case unique_key
      when :only then GROUPS & unique_key_options
      when :skip then GROUPS - unique_key_options
      else
        GROUPS.select { |group| option? group }
      end
    end

    # @return [Boolean]
    def option?(key)
      raw_options.key?(key) && raw_options[key].presence
    end

    # @!attribute [r] options_for_delegate
    # @api private
    # @return [Hash]
    def options_for_delegate
      raw_options.slice *DELEGATE_OPTION_KEYS
    end

    # @!attribute [r] unique_key_options
    # @api private
    # @return [Array<Symbol>]
    def unique_key_options
      @unique_key_options ||= Array(raw_options[unique_key])
    end

    # @!attribute [r] unique_keys
    # @api private
    # @return [Array<Symbol>]
    def unique_keys
      @unique_keys ||= raw_options.keys & UNIQUE_KEYS
    end

    # @!attribute [r] unique_key
    # @api private
    # @return [Symbol, nil]
    def unique_key
      @unique_key = unique_keys.first unless defined?(@unique_key)

      @unique_key
    end
  end
end
