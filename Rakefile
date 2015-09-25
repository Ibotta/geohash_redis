require 'rubygems'
require 'rubygems/package_task'
require 'ffi-compiler/compile_task'

def gem_spec
  @gem_spec ||= Gem::Specification.load('geohash_helper.gemspec')
end

FFI::Compiler::CompileTask.new('lib/geohash_helper', 'ext', :gem_spec => gem_spec) do |c|
  c.have_header?('geohash.h', 'ext')
  c.have_header?('geohash_helper.h', 'ext')
  c.export('geohash_helper.rb')
end

Gem::PackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
  pkg.package_dir = 'pkg'
end
