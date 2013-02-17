Gem::Specification.new do |s|
  s.name          = 'kmeans-clustering'
  s.version       = '1.0.0'
  s.date          = '2013-02-17'
  s.summary       = "A simple Ruby gem for parallelized k-means clustering."
  s.description   = "A simple Ruby gem for parallelized k-means clustering."
  s.authors       = ["Tom Van Eyck"]
  s.email         = 'tomvaneyck@gmail.com'
  s.homepage      = 'https://github.com/vaneyckt/kmeans-clustering'

  s.files         = Dir["{lib}/**/*.rb"]
  s.require_path  = 'lib'

  s.add_runtime_dependency 'cabiri', '>= 0.0.7'
end
