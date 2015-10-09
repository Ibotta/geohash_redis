Gem::Specification.new "geohash_helper" do |s|
  s.name = 'geohash_helper'
  s.version = '0.0.4'
  s.date = '2015-10-09'
  s.summary = "Geohash Helper Functions from Redis Github Repository"
  s.description = "useful geohash helper functions such as get area by radius from the redis github repository"
  s.authors = ["Salvatore Sanfilippo", "Mengxiang Jiang"]
  s.email = ['antirez@gmail.com', 'mj294@cornell.edu']
  s.files = %w(geohash_helper.gemspec) + Dir.glob("{lib,spec,ext}/**/*")
  s.homepage = 'https://github.com/Ibotta/geohash_helper'
  s.license = 'MIT'
  s.add_dependency 'rake'
  s.add_dependency 'ffi-compiler'
  s.extensions << 'ext/geohash_helper/Rakefile'
end
