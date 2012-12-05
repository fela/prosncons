require 'rotten'
require 'gnuplot'
require 'distribution'

# monkey patching existing classes
module Rotten
  class << self
    def all_dvd_releases
      new_releases + upcoming_releases + current_releases
          #in_theaters + search('love')
    end

    def search query
      add_till_no_more do |i|
        Rotten::Movie.search query, page: i
      end
    end

    def new_releases
      add_till_no_more do |i|
        Rotten::Movie.dvd_releases page: i
      end
    end

    def upcoming_releases
      add_till_no_more do |i|
        Rotten::Movie.upcoming_dvd_releases page: i
      end
    end

    def current_releases
      add_till_no_more do |i|
        Rotten::Movie.current_dvd_releases page: i
      end
    end

    def upcoming
      add_till_no_more do |i|
        Rotten::Movie.upcoming page: i
      end
    end

    def opening
      add_till_no_more do |i|
        Rotten::Movie.opening page: i
      end
    end

    def in_theaters
      add_till_no_more do |i|
        Rotten::Movie.in_theaters page: i
      end
    end

    def add_till_no_more
      m = []
      10.times do |i|
        new_m = yield(i+1)
        m += new_m.to_a
        break if m.size == new_m.total
      end
      m
    end
  end
end

class Rotten::Movie
  def critics_score
    ratings['critics_score']
  end
  def audience_score
    ratings['audience_score']
  end
  class << self
    def current_dvd_releases options={}
      fetch "lists/dvds/current_releases", options
    end
    def upcoming_dvd_releases options={}
      fetch "lists/dvds/upcoming", options
    end
  end

  def to_s
    "#{id}\t#{critics_score}\t#{audience_score}\t#{title}"
  end

  def n_reviews
    puts "fetching #{reviews.total} reviews for #{title}..."
    reviews.total
  end
end

class Array
  def sum
    inject(0.0) { |result, el| result + el }
  end

  def mean
    sum / size
  end

  def variance
    map{|x| x**2}.sum / size
  end
end



# custom classes
class MovieList < Array
  def initialize(movies=nil)
    movies ||= self.class.initial_movies
    super(movies)
    # remove duplicates
    cleanup!
  end

  def cleanup!
    i = size
    uniq!{|m|m.id}
    puts "#{i-size} duplicate movies" unless i == size
    select!{|m| m.critics_score > 1 }
    select!{|m| m.n_reviews > 12}
  end

  def critics_histogram
    #map{|m| m.critics_score}
    display_histogram :critics_score
  end

  def audience_histogram
    display_histogram :audience_score
  end

  def display_histogram sym, bin_size=5
    n_bins = 100/bin_size
    hist = map(&sym)
    hist.select!{|x| x < 100} # exclude 100
    scores = hist
    hist = hist.group_by do |x|
      start = x/bin_size*bin_size
      start
    end
    0.upto(n_bins) do |i|
      hist[i*bin_size] ||= []
    end
    p hist.to_a
    hist = hist.to_a.map{|bin, vals| [bin, vals.size.to_f]}
    hist.sort!{|x, y| x.first <=> y.first}
    p hist

    a, b = estimate_beta_params(scores.map{|e| e/100.0})
    Gnuplot.open do |gp| Gnuplot::Plot.new(gp) do |plot|

      #plot.output File.expand_path("../hist.eps", __FILE__)
      #plot.term 'postscript eps color blacktext "Helvetica" 12'
      plot.title  "% of positive votes"
      plot.style  "histogram clustered gap 0"
      plot.style  "data histogram"
      plot.style  "fill solid 0.7"
      #plot.xtics  "nomirror rotate by -45"

      x = hist.map{|x| x.first}
      y = hist.map{|x| x.last}
      plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
        ds.with = 'histogram'
        ds.using = '2:xtic(1)'
        ds.title = 'films'
      end

      max = 100
      x = (1..max-1).map { |v| v.to_f/max*n_bins }
      y = x.map { |v| Distribution::Beta.pdf((v)/n_bins, a, b)/n_bins*scores.size }
      puts '----------'
      y.inject(0.0){|sum, el|sum+ el}
      puts y.variance
      puts '-----------------'

      plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
        ds.with = "line"
        ds.notitle
      end

    end end
  end

  # points should be between 0 and 1
  def estimate_beta_params points
    # sample mean
    avg = points.mean
    # sample variance
    var = points.map{|x|(x-avg)**2}.sum/(points.size-1)
    puts "var: #{var}; should be < than #{avg*(1-avg)}"
    puts '----------'
    puts avg
    puts var
    puts '----------'
    mu = avg*(1-avg)/var - 1
    puts "mu: #{mu}"
    #mu = 9
    a = avg*mu
    b = (1-avg)*mu
    p [a, b]
    [a, b]
  end

  def print
    each do |m|
      puts m
    end
    nil
  end

private
  def self.initial_movies
    Rotten.all_dvd_releases + Rotten.in_theaters +
        Rotten.search('love') + Rotten.search('war')
  end
end

# hack to make enable_cache work
require 'yaml'
YAML::ENGINE.yamler = 'syck'
#Rotten::Movie.enable_cache!

#Rotten.api_key = ARGV[0] || abort('please supply a key as argument')
#MovieList.new.print

