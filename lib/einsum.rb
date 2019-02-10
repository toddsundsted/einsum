# frozen_string_literal: true

##
# Unoptimized, pure-Ruby implementation of a subset of Numpy `einsum`.
#
# See: https://docs.scipy.org/doc/numpy/reference/generated/numpy.einsum.html
#
class Einsum
  FormatError = Class.new(StandardError)

  Label = Struct.new(:dimension, :count) do
    def initialize(dimension, count = 0)
      super(dimension, count)
    end

    def increment
      self.count += 1
    end
  end

  class << self
    ##
    # Evaluates the (extended) Einstein summation convention on the operands.
    #
    # Operands must be `Array` like. Array elements must respond to `*` and `+`.
    #
    # Examples:
    #
    #   In implicit mode:
    #
    #     `Einsum.einsum('ij,jk', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => dot product: [[7, 10], [15, 22]]`
    #     `Einsum.einsum('ij,kj', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => inner product: [[ 5, 11], [11, 25]]`
    #
    #   In explicit mode:
    #
    #     `Einsum.einsum('ij,jk->ik', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => dot product: [[7, 10], [15, 22]]`
    #     `Einsum.einsum('ij,kj->ik', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => inner product: [[ 5, 11], [11, 25]]`
    #     `Einsum.einsum('ij,jk->', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => 54`
    #     `Einsum.einsum('ij,kj->', [[1, 2], [3, 4]], [[1, 2], [3, 4]]) # => 52`
    #
    def einsum(format, *operands)
      labels = {}

      # check syntax of format string
      unless format.match?(/\A([a-z]+(,[a-z]+)*)(->[a-z]*)?\z/)
        raise FormatError, "invalid format: #{format}"
      end

      # chop up format string
      inputs, explicit, output = format.partition('->')
      inputs = inputs.split(',')
      if operands.length != inputs.length
        raise FormatError, "provides #{operands.length} operands for #{inputs.length} input labels strings"
      end

      # check labels and operands
      inputs.zip(operands).each.with_index do |(input, operand), pos|
        input.split('').each.with_index do |label, axis|
          unless (dim = dim(operand, axis))
            raise FormatError, "no axis in operand #{pos} corresponds to label #{label}"
          end
          if labels[label] && labels[label].dimension != dim
            raise FormatError, "inconsistent dimension for label #{label}: #{labels[label].dimension} and #{dim}"
          end

          labels[label] ||= Label.new(dim)
          labels[label].increment
        end
      end

      # if implicit mode, generate output labels string from all
      # labels mentioned only once in the input labels strings
      if explicit.empty? && (groups = labels.group_by { |_, l| l.count }[1])
        output = groups.map(&:first).sort.join
      end

      # compute shape of the result
      shape = []
      output.split('').each do |label|
        unless labels[label]
          raise FormatError, "output label #{label} not present in input labels"
        end

        shape << labels[label].dimension
      end

      # generate template for result
      result = 0
      unless shape.empty?
        result = empty(shape, result)
      end

      # generate code for the specified operations. first, loop over
      # each output axis in the order specified by the output labels.
      # then, loop over the remaining input axes and compute the
      # result for each cell in the output matrix.

      code = []
      internal = inputs.join.split('').sort.uniq - output.split('')
      external = output.split('')

      external.each do |label|
        code.push("#{labels[label].dimension}.times do |#{label}|")
      end

      internal.each do |label|
        code.push("#{labels[label].dimension}.times do |#{label}|")
      end

      external_labels = external.map { |l| "[#{l}]" }.join
      code.push("result#{external_labels} +=")

      inputs.each.with_index do |input, i|
        input_labels = input.split('').map { |l| "[#{l}]" }.join
        suffix = i < inputs.length - 1 ? ' *' : ''
        code.push("operands[#{i}]#{input_labels}#{suffix}")
      end

      internal.each do
        code.push('end')
      end

      external.each do
        code.push('end')
      end

      # evaluate the generated code in the current context. this would
      # be considered dangerous, except we are in control of generated
      # code except loop variable names, which are derived from input
      # and output labels, which are constrained to be individual,
      # lowercase characters, which are bound in their respective
      # loops.

      # rubocop:disable Security/Eval
      binding.eval(code.join("\n"))
      # rubocop:enable Security/Eval

      result
    end

    private

    def dim(array, axis)
      array =
        if axis.positive?
          array.dig(*Array.new(axis, 0))
        else
          array
        end
      begin
        array.length
      rescue NoMethodError
        nil
      end
    end

    def clone(array)
      if array.respond_to?(:each)
        array.map { |item| clone(item) }
      else
        array
      end
    end

    def empty(shape, seed)
      i, *shape = shape
      seed = empty(shape, seed) unless shape.empty?
      Array.new(i) { clone(seed) }
    end
  end
end
