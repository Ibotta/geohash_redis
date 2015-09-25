require 'ffi'
require 'ffi-compiler/loader'

module GeohashHelper
  class GeoHashRadius < FFI::ManagedStruct
    layout :hash,  :pointer,
           :area,  :pointer,
           :neighbors, :pointer

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end

  class GeoHashBits < FFI::ManagedStruct
    layout :bits,  :__uint64_t,
           :step,  :__uint8_t

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end

  class GeoHashRange < FFI::ManagedStruct
    layout :min,  :double,
           :max,  :double

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end

  class GeoHashArea < FFI::ManagedStruct
    layout :hash,  :pointer,
           :longitude,  :pointer,
           :latitude, :pointer

    def self.release(ptr)
      GeohashHelper.free_object(ptr)
    end
  end

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
  attach_function :geohashGetAreasByRadius, [:double, :double, :double], :pointer
  attach_function :geohashEncodeToStr, [:double, :double, :int], :string
  attach_function :geohashDecodeToArea, [:string], :pointer
  attach_function :geohashBitsToStr, [:pointer], :string
  attach_function :geohashStrToBits, [:string], :pointer
  attach_function :geohashNeighborsFromStr, [:string], :pointer

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

end
