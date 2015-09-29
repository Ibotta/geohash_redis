require 'ffi'
require 'ffi-compiler/loader'

# ruby-ffi requires that arguments and the return values of c functions
# must either be primitive types or pointers.
# Therefore many of the structs that are passed as arguments and returned
# were changed to pointers for those functions
# Some of the structs themselves were also changed for easier access by ffi

module GeohashHelper
  
  # GeoHashRadius's members were changed from structs to pointers
  # If I were to keep the members as structs, I would need to write getter methods
  # and the methods would return pointers to the structs anyways
  class GeoHashRadius < FFI::ManagedStruct
    layout :hash,  :pointer,
           :area,  :pointer,
           :neighbors, :pointer

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end

  # GeoHashBits remained the same as before since its members are already primitive types
  class GeoHashBits < FFI::ManagedStruct
    layout :bits,  :__uint64_t,
           :step,  :__uint8_t

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end
  # GeoHashRange remained the same as before since its members are already primitive types
  class GeoHashRange < FFI::ManagedStruct
    layout :min,  :double,
           :max,  :double

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end

  # GeoHashArea's members were changed from structs to pointers for the same reason as GeoHashRadius
  class GeoHashArea < FFI::ManagedStruct
    layout :hash,  :pointer,
           :longitude,  :pointer,
           :latitude, :pointer

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end

  # GeoHashNeighbors's members were changed from structs to pointers for the same reason as GeoHashRadius
  class GeoHashNeighbors < FFI::ManagedStruct
    layout :north,  :pointer,
           :east,  :pointer,
           :west,  :pointer,
           :south,  :pointer,
           :north_east,  :pointer,
           :south_east,  :pointer,
           :north_west,  :pointer,
           :south_west,  :pointer

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end

  extend FFI::Library
  ffi_lib FFI::Compiler::Loader.find('geohash_helper')

  # converts geo coords and a radius into an area
  # inputs are longitude, latitude, and radius (in meters)
  # output is a pointer to a GeoHashArea
  attach_function :geohashGetAreasByRadius, [:double, :double, :double], :pointer
  
  # converts geo coords into a geohash string
  # inputs are longitude, latitude, and string length
  # output is a geohash string
  attach_function :geohashEncodeToStr, [:double, :double, :int], :string
  
  # converts a geohash string to an area
  # input is a geohash string
  # output is a pointer to a GeoHashArea
  attach_function :geohashDecodeToArea, [:string], :pointer
  
  # converts a geohash bits value to a geohash string
  # input is a pointer to a GeoHashBits
  # output is a geohash string
  attach_function :geohashBitsToStr, [:pointer], :string
  
  # converts a geohash stringto a geohash bits value
  # input is a geohash string
  # output is a pointer to a GeoHashBits
  attach_function :geohashStrToBits, [:string], :pointer
  
  # gets the neighbors of a geohash given its string
  # input is a geohash string
  # output is a pointer to a GeoHashNeighbors
  attach_function :geohashNeighborsFromStr, [:string], :pointer

  # frees the memory of the pointer
  # input is a pointer
  # void output
  attach_function :free_object, [:pointer], :void

  # functions from the original c files
  # slight modifications to take in and return pointers instead of structs
  attach_function :geohashEncode, [:pointer, :pointer, :double, :double, :__uint8_t, :pointer], :int
  attach_function :geohashEncodeType, [:double, :double, :__uint8_t, :pointer], :int
  attach_function :geohashEncodeWGS84, [:double, :double, :__uint8_t, :pointer], :int
  attach_function :geohashDecode, [:pointer, :pointer, :pointer, :pointer], :int
  attach_function :geohashDecodeType, [:pointer, :pointer], :int
  attach_function :geohashDecodeWGS84, [:pointer, :pointer], :int
  attach_function :geohashDecodeAreaToLongLat, [:pointer, :pointer], :int
  attach_function :geohashDecodeToLongLatType, [:pointer, :pointer], :int
  attach_function :geohashDecodeToLongLatWGS84, [:pointer, :pointer], :int
  attach_function :geohashNeighbors, [:pointer, :pointer], :void

  attach_function :geohashEstimateStepsByRadius, [:double, :double], :__uint8_t
  attach_function :geohashBitsComparator, [:pointer, :pointer], :int
  attach_function :geohashBoundingBox, [:double, :double, :double, :pointer], :int
  attach_function :geohashGetAreasByRadiusWGS84, [:double, :double, :double], :pointer
  attach_function :geohashAlign52Bits, [:pointer], :__uint64_t
  attach_function :geohashGetDistance, [:double, :double, :double, :double], :double
  attach_function :geohashGetDistanceIfInRadius, [:double, :double, :double, :double, :double, :pointer], :int
  attach_function :geohashGetDistanceIfInRadiusWGS84, [:double, :double, :double, :double, :double, :pointer], :int

  def self.geohashGetAreasByRadiusToStrList(longitude, latitude, radius)
    str_list = []
    radius_ptr = GeohashHelper.geohashGetAreasByRadius(longitude, latitude, radius)
    radius = GeohashHelper::GeoHashRadius.new(radius_ptr)
    hash_str = GeohashHelper.geohashBitsToStr(radius[:hash])
    str_list << hash_str

    neighbors = GeohashHelper::GeoHashNeighbors.new(radius[:neighbors])
    direction_symbols = [:north, :east, :west, :south, :north_east, :south_east, :north_west, :south_west]
    direction_symbols.each do |direction|
      direction_ptr = neighbors[direction]
      direction_bits = GeohashHelper::GeoHashBits.new(direction_ptr)
      if direction_bits[:bits] > 0 && direction_bits[:step] > 0
        direction_str = GeohashHelper.geohashBitsToStr(direction_ptr)
        str_list << direction_str
      end
    end
    str_list
  end

end
