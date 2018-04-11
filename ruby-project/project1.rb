# frozen_string_literal: true

require "mongo"
require "benchmark"
require "pry"

class Connection
  def initialize(db_name, db_collection)
    @db_name, @db_collection = db_name, db_collection
  end

  def collection
    @collection ||= client[db_collection.to_sym]
  end

  def client
    @client ||= Mongo::Client.new(["127.0.0.1:27017"], database: db_name)
  end

  private

  attr_reader :db_name, :db_collection
end

class Main
  def initialize(db_name, db_collection)
    @connection = Connection.new(db_name, db_collection)
  end

  def call
    puts "Connection established" if connection

    puts "*** Project 1 - Robert Kostrzewski - 244226 ***"

    puts "Number of places in document - #{collection_count}"
    print_benchmark { collection_count }

    puts "Market with the biggest area - #{biggest_area}"
    print_benchmark { biggest_area }

    centre_point = first_market
    puts "First market full info - #{first_market}"
    print_benchmark { first_market }

    puts "Find first 5 cities of markets - #{five_first_cities}"
    print_benchmark { five_first_cities }

    puts "Count of Markets with bigger area than the first market"
    puts "- #{count_bigger_markets_than_first(centre_point)}"
    print_benchmark { count_bigger_markets_than_first(centre_point) }
  end

  private

  def print_benchmark(&block)
    n = 5
    result = Benchmark.measure { n.times { yield } }
    print_result = {
      real: result.real / n.to_f,
      user: result.cutime / n.to_f,
      system: result.cstime / n.to_f,
      total: result.total / n.to_f,
    }

    puts print_result
  end

  def collection_count
    connection.collection.count
  end

  def biggest_area
    connection.collection.find({}).sort("area" => 1).limit(1).first
  end

  def five_first_cities
    connection.collection.find(city: 1).limit(5)
  end

  def first_market
    connection.collection.find.limit(1).first
  end

  def count_bigger_markets_than_first(centre_point)
    connection.collection.aggregate(
      [
        { "$match" => { area: { "$gte" => centre_point["area"] } } },
      ]
    ).count
  end

  attr_reader :connection
end

db_name = ARGV[0]
db_collection = ARGV[1]

Main.new(db_name, db_collection).call
