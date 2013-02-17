module KMeansClustering
  require 'cabiri'

  # add static attributes through attr_accessor
  class << self
    attr_accessor :calcSum
    attr_accessor :calcAverage
    attr_accessor :calcDistanceSquared
  end

  # split array into several equal sized parts
  # taken from http://apidock.com/rails/v3.2.8/Array/in_groups
  def self.split_array_into_parts(array, nb_parts)
    start = 0
    groups = []

    modulo = array.size % nb_parts
    division = array.size / nb_parts

    nb_parts.times do |index|
      length = division + (modulo > 0 && modulo > index ? 1 : 0)
      groups << array.slice(start, length)
      start += length
    end
    groups
  end

  def self.run(centers, elements, nb_iterations, nb_jobs)
    nb_iterations.times do
      # create jobs
      jobs = []
      elements_for_jobs = split_array_into_parts(elements, nb_jobs)
      nb_jobs.times do |i|
        jobs << Job.new(centers, elements_for_jobs[i])
      end

      # run jobs in parallel
      queue = Cabiri::JobQueue.new
      nb_jobs.times do |i|
        queue.add(i) { jobs[i].run }
      end
      queue.start(nb_jobs)

      # sort aggregated proximity data by center
      sorted_aggregated_proximity_data = Hash.new { |h,k| h[k] = [] }

      queue.finished_jobs.values.each do |finished_job|
        aggregated_proximity_data = finished_job.result
        aggregated_proximity_data.each do |center, aggregated_data|
          sorted_aggregated_proximity_data[center] << aggregated_data
        end
      end

      # calculate sum and nb elements for each center
      sums = Hash.new { |h,k| h[k] = [] }
      nb_elements = Hash.new { |h,k| h[k] = [] }

      sorted_aggregated_proximity_data.each do |center, aggregated_data|
        sums[center] = KMeansClustering::calcSum.call(aggregated_data.collect { |d| d[:sum] })
        nb_elements[center] = (aggregated_data.collect { |d| d[:nb_elements] }).inject(0, :+)
      end

      # calculate new centers
      centers = []
      sums.keys.each do |center|
        centers << KMeansClustering::calcAverage.call(sums[center], nb_elements[center])
      end
    end

    centers
  end

  # job that will be used for parallelization with Cabiri
  class Job
    attr_accessor :centers
    attr_accessor :elements

    def initialize(centers, elements)
      @centers = centers
      @elements = elements
    end

    def run
      proximity_data = assignElementsToClosestCenter
      aggregated_proximity_data = aggregateProximityData(proximity_data)
      aggregated_proximity_data
    end

    def assignElementsToClosestCenter
      results = Hash.new { |h,k| h[k] = [] }

      @elements.each do |element|
        best_center = nil
        best_distance = nil

        @centers.each do |center|
          distance = KMeansClustering::calcDistanceSquared.call(center, element)
          if best_distance.nil? or distance < best_distance
            best_center = center
            best_distance = distance
          end
        end
        results[best_center] << element
      end

      results
    end

    def aggregateProximityData(data)
      results = {}
      data.each do |center, elements|
        sum = KMeansClustering::calcSum.call(elements)
        results[center] = {:sum => sum, :nb_elements => elements.length}
      end
      results
    end
  end
end
