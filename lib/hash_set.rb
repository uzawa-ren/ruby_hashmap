require_relative './linked_list'

class HashSet
  attr_reader :buckets, :capacity, :load_factor

  def initialize
    @buckets = Array.new(16) { LinkedList.new }
    @capacity = buckets.length
    @load_factor = 0.75
  end

  # Returns index of given key, i.e. hash.
  def hash(key)
    return 'Error: only strings are supported.' unless key.is_a?(String)

    string_to_number(key)
  end

  # Converts a string to a number for hashing.
  def string_to_number(string)
    hash_code = 0
    prime_number = 31

    string.each_char { |char| hash_code = prime_number * hash_code + char.ord }

    hash_code
  end

  # Adds a new value for the key.
  def set(key)
    filled_percentage = filled_buckets_percentage
    grow_buckets if filled_percentage >= load_factor

    index = get_index(key)

    buckets[index].append(key)
  end

  # Calculates percentage of filled buckets.
  def filled_buckets_percentage
    filled_buckets = length
    # divide by 100 at the end to preserve the style of the load factor
    (filled_buckets / capacity.to_f * 100) / 100
  end

  # Returns the number of stored keys in the hash set.
  def length
    buckets.sum(&:size)
  end

  # Increases the hash set capacity by 2.
  def grow_buckets
    old_buckets = buckets
    new_buckets = Array.new(capacity * 2) { LinkedList.new }

    old_buckets.each_with_index do |bucket, index|
      next if bucket.size.nil?

      new_buckets[index] = bucket
    end

    @buckets = new_buckets
    @capacity = buckets.length
  end

  # Gets the value at the given key.
  def get(key)
    index = get_index(key)
    return nil if buckets[index].empty?

    buckets[index].find_enum { |node| node.value == key }.value
  end

  # Checks whether the key is in the hash set.
  def key?(key)
    !!get(key)
  end

  # Removes and returns the key if it exists.
  def remove(key)
    index = get_index(key)
    return nil if buckets[index].empty?

    buckets[index].each do |node, i|
      break buckets[index].remove_at(i) if node.value == key
    end
  end

  # Removes all entries in the hash set.
  def clear
    initialize
  end

  # Returns an array containing all the keys inside the hash set.
  def keys
    buckets.reduce([]) do |all, bucket|
      next all if bucket.empty?

      this_bucket_keys = []

      bucket.each do |node|
        this_bucket_keys << node.value
      end

      all + this_bucket_keys
    end
  end

  private

  # Returns index of the key.
  def get_index(key)
    index = hash(key) % capacity
    raise IndexError if index.negative? || index >= @buckets.length

    index
  end
end
