# typed: strict

class Einsum
  class << self
    sig { params(format: String, operands: T::Enumerable[T.untyped]).returns(T.untyped) }
    def einsum(format, *operands)
    end

    private

    sig { params(array: T.untyped, axis: Integer).returns(T.untyped) }
    def dim(array, axis)
    end

    sig { params(array: T.untyped).returns(T.untyped) }
    def clone(array)
    end

    sig { params(shape: T::Array[T.untyped], seed: T.untyped).returns(T::Array[T.untyped]) }
    def empty(shape, seed)
    end
  end
end
