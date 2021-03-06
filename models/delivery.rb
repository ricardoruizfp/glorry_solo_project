require_relative('../db/sql_runner')
require('date')
class Delivery

  attr_reader :id
  attr_accessor :customer_id, :driver_id, :contents, :time
  def initialize(option)
    @id = option['id'].to_i
    @customer_id = option['customer_id']
    @driver_id = option['driver_id']
    @contents = option['contents']
    @time = option['time']
  end

  def save()
    @time = Date.today
    sql = "INSERT INTO deliveries
    (
      customer_id, driver_id, contents, time
    )
    VALUES
    (
      $1, $2, $3, $4
    )
    RETURNING id;"
    values = [@customer_id, @driver_id, @contents, @time]
    results = SqlRunner.run(sql, values)
    @id = results.first()['id'].to_i
  end

  def save_for_seed()
    sql = "INSERT INTO deliveries
    (
      customer_id, driver_id, contents, time
    )
    VALUES
    (
      $1, $2, $3, $4
    )
    RETURNING id;"
    values = [@customer_id, @driver_id, @contents, @time]
    results = SqlRunner.run(sql, values)
    @id = results.first()['id'].to_i
  end

  def driver
    sql = "SELECT * FROM drivers
    WHERE id = $1"
    values = [@driver_id]
    results = SqlRunner.run( sql, values )
    return Driver.new( results.first )
  end

  def customer
    sql = "SELECT * FROM customers
    WHERE id = $1"
    values = [@customer_id]
    results = SqlRunner.run( sql, values )
    return Customer.new( results.first )
  end

  def self.latest_five
    sql = "SELECT * FROM deliveries
    ORDER BY time DESC
    limit 5"
    results = SqlRunner.run(sql)
    return results.map {|delivery| Delivery.new(delivery)}
  end

  def self.all()
    sql = "SELECT * FROM deliveries"
    results = SqlRunner.run( sql )
    return results.map { |delivery| Delivery.new( delivery ) }
  end

  def self.unique_years
    dates_string = all.map { |delivery| delivery.time }
    dates = []
    for date in dates_string
      dates.push(Date.parse(date).year)
    end
    return dates.uniq
  end

  def self.year_all(chosen_year)
    deliveries = Delivery.all()
    year_deliveries = []
    for delivery in deliveries
      if Date.parse(delivery.time).year == chosen_year
        year_deliveries.push(delivery)
      end
    end
    return year_deliveries
  end

  def self.month_all(chosen_month, chosen_year)
    all_deliveries = Delivery.all()
    month_deliveries = []
    for delivery in all_deliveries
      if Date.parse(delivery.time).mon == chosen_month && Date.parse(delivery.time).year == chosen_year.to_i
        month_deliveries.push(delivery)
      end
    end
    return month_deliveries
  end

  def self.find( id )
    sql = "SELECT * FROM deliveries
    WHERE id = $1"
    values = [id]
    results = SqlRunner.run( sql, values )
    return Delivery.new( results.first )
  end

  def update()
    sql = "UPDATE deliveries
    SET
    (
      customer_id, driver_id, contents
      ) =
      (
        $1, $2, $3
      )
      WHERE id = $4"
      values = [@customer_id, @driver_id, @contents, @id]
      SqlRunner.run( sql, values )
    end

    def delete()
      sql = "DELETE FROM deliveries
      WHERE id = $1"
      values = [@id]
      SqlRunner.run( sql, values )
    end

    def self.delete(id)
      sql = "DELETE FROM deliveries
      WHERE id = $1"
      values = [id]
      SqlRunner.run( sql, values )
    end

    def self.delete_all
      sql = "DELETE FROM deliveries"
      SqlRunner.run( sql )
    end

    def self.search(query)
      query = query.downcase
      sql = "SELECT * FROM deliveries
      WHERE lower(deliveries.contents) LIKE $1"
      values = ['%'+query+'%']
      results = SqlRunner.run( sql, values )
      return results.map { |delivery| Delivery.new( delivery ) }
    end

    def self.year_all_search(chosen_year, query)
      deliveries = Delivery.search(query)
      year_deliveries = []
      for delivery in deliveries
        if Date.parse(delivery.time).year == chosen_year
          year_deliveries.push(delivery)
        end
      end
      return year_deliveries
    end

    def self.month_all_search(chosen_month, chosen_year, query)
      deliveries = Delivery.search(query)
      month_deliveries = []
      for delivery in deliveries
        if Date.parse(delivery.time).mon == chosen_month && Date.parse(delivery.time).year == chosen_year.to_i
          month_deliveries.push(delivery)
        end
      end
      return month_deliveries
    end



  end
