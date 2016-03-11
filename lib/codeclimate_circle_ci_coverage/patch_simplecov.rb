require "simplecov"
# Without this change, merging results erroneously marks blank comment lines as
# uncovered.
# https://github.com/colszowka/simplecov/pull/441
module SimpleCov
  module ArrayMergeHelper
    # Merges an array of coverage results with self
    def merge_resultset(array)
      new_array = dup
      array.each_with_index do |element, i|
        pair = [element, new_array[i]]
        new_array[i] = if pair.any?(&:nil?) && pair.map(&:to_i).all?(&:zero?)
                         nil
                       else
                         element.to_i + new_array[i].to_i
                       end
      end
      new_array
    end
  end
end
