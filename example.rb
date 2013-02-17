require 'kmeans-clustering'

# specify required operations
KMeansClustering::calcSum = lambda do |elements|
  sum = [0, 0]
  elements.each do |element|
    sum[0] += element[0]
    sum[1] += element[1]
  end
  sum
end

KMeansClustering::calcAverage = lambda do |sum, nb_elements|
  average = [0, 0]
  average[0] = sum[0] / nb_elements.to_f
  average[1] = sum[1] / nb_elements.to_f
  average
end

KMeansClustering::calcDistanceSquared = lambda do |element_a, element_b|
  d0 = element_b[0] - element_a[0]
  d1 = element_b[1] - element_a[1]
  (d0 * d0) + (d1 * d1)
end

# generate random elements
elements = []
10000.times do
  elements << [rand(1000), rand(1000)]
end

# pick 4 random elements to act as initial centers
centers = elements.sample(4)

# apply 10 iterations of the k-means clustering algorithm
# and split each iteration across 2 different processors
new_centers = KMeansClustering::run(centers, elements, 10, 2)
puts new_centers.to_s
