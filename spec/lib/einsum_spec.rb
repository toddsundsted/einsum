# typed: false
# frozen_string_literal: true

require 'einsum'

RSpec.describe Einsum do
  it 'has a version number' do
    expect(Einsum::VERSION).not_to be nil
  end

  describe '.einsum' do
    context 'format' do
      it 'comprises one or more input labels strings and an optional output labels string' do
        expect { Einsum.einsum('ij,jk->ik', [[0]], [[0]]) }.not_to raise_error
        expect { Einsum.einsum('ij,jk', [[0]], [[0]]) }.not_to raise_error
      end

      it 'specifies one input labels string for each operand' do
        expect { Einsum.einsum('i,j', []) }.to raise_error(Einsum::FormatError)
        expect { Einsum.einsum('i,j', [], [], []) }.to raise_error(Einsum::FormatError)
        expect { Einsum.einsum('i,j', [], []) }.not_to raise_error
      end

      it 'permits as many labels as axes' do
        expect { Einsum.einsum('ij', []) }.to raise_error(Einsum::FormatError)
        expect { Einsum.einsum('ijk', [[]]) }.to raise_error(Einsum::FormatError)
        expect { Einsum.einsum('ij', [[]]) }.not_to raise_error
      end

      it 'requires consistent dimensions for labels' do
        expect { Einsum.einsum('ii', [[]]) }.to raise_error(Einsum::FormatError)
        expect { Einsum.einsum('i,i', [0], []) }.to raise_error(Einsum::FormatError)
        expect { Einsum.einsum('ii', [[0]]) }.not_to raise_error
        expect { Einsum.einsum('i,i', [], []) }.not_to raise_error
      end

      it 'requires output labels to be a subset of input labels' do
        expect { Einsum.einsum('i->j', []) }.to raise_error(Einsum::FormatError)
        expect { Einsum.einsum('i->i', []) }.not_to raise_error
      end
    end

    it 'multiplies values along axes shared between input labels strings' do
      expect(Einsum.einsum('i,i->i', [1, 2, 3], [1, 2, 3])).to eq([1, 4, 9])
    end

    it 'sums values along axes omitted from the output labels string' do
      expect(Einsum.einsum('i->', [1, 2, 3])).to eq(6)
    end

    it 'works for many test cases' do
      expect(Einsum.einsum('i', [1, 2, 3])).to eq([1, 2, 3])
      expect(Einsum.einsum('i,i', [1, 2], [3, 4])).to eq(11)
      expect(Einsum.einsum('i,j->ij', [1, 2], [3, 4])).to eq([[3, 4], [6, 8]])
      expect(Einsum.einsum('ij', [[3, 4], [6, 8]])).to eq([[3, 4], [6, 8]])
      expect(Einsum.einsum('ji', [[3, 4], [6, 8]])).to eq([[3, 6], [4, 8]])
      expect(Einsum.einsum('ii->i', [[3, 4], [6, 8]])).to eq([3, 8])
      expect(Einsum.einsum('ii', [[3, 4], [6, 8]])).to eq(11)
      expect(Einsum.einsum('ij->', [[1, 2], [3, 4]])).to eq(10)
      expect(Einsum.einsum('ij->j', [[1, 2], [3, 4]])).to eq([4, 6])
      expect(Einsum.einsum('ij->i', [[1, 2], [3, 4]])).to eq([3, 7])
      expect(Einsum.einsum('ij,ij->ij', [[1, 2]], [[3, 4]])).to eq([[3, 8]])
      expect(Einsum.einsum('ij,ji->ij', [[1, 2]], [[3], [4]])).to eq([[3, 8]])
      expect(Einsum.einsum('ij,jk', [[1, 2], [3, 4]], [[1, 2], [3, 4]])).to eq([[7, 10], [15, 22]])
      expect(Einsum.einsum('ij,kj->ik', [[1, 2], [3, 4]], [[1, 2], [3, 4]])).to eq([[5, 11], [11, 25]])
      expect(Einsum.einsum('ij,kj->ikj', [[1, 2], [3, 4]], [[1, 2], [3, 4]])).to eq([[[1, 4], [3, 8]], [[3, 8], [9, 16]]])
      expect(Einsum.einsum('ij,kl->ijkl', [[1, 2], [3, 4]], [[1, 2], [3, 4]])).to eq([[[[1, 2], [3, 4]], [[2, 4], [6, 8]]], [[[3, 6], [9, 12]], [[4, 8], [12, 16]]]])
      expect(Einsum.einsum('ij,jk,kl->il', [[1, 2], [3, 4]], [[1, 2], [3, 4]], [[1, 2], [3, 4]])).to eq([[37, 54], [81, 118]])
    end
  end

  describe '.dim' do
    it 'returns the dimension/length of the specified axis' do
      expect(Einsum.send(:dim, [[1, 2, 3], [4, 5, 6]], 0)).to eq(2)
      expect(Einsum.send(:dim, [[1, 2, 3], [4, 5, 6]], 1)).to eq(3)
      expect(Einsum.send(:dim, [1, 2, 3], 0)).to eq(3)
    end

    it 'returns `nil` if the specified axis is invalid' do
      expect(Einsum.send(:dim, [5], 1)).to be_nil
      expect(Einsum.send(:dim, 5, 0)).to be_nil
    end
  end
end
