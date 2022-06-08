require_relative "sales_engine"
require "BigDecimal"


class SalesAnalyst
  attr_reader :items_path, :merchants_path

  def initialize(items_path, merchants_path)
    @items_path = items_path
    @merchants_path = merchants_path
  end

  def average_items_per_merchant
    # (@items_path.all.count.to_f / @merchants_path.all.count).round(2)
    (items_per_merchant.reduce(:+).to_f / items_per_merchant.count).round(2)
  end

  def all_items_by_merchant
    @items_path.all.group_by do |item|
      item.merchant_id
    end
  end

  def items_per_merchant
    all_items_by_merchant.map do |id, items|
      items.count
    end
  end

  def difference_squared
    items_per_merchant.map do |sum|
      (sum - average_items_per_merchant)**2
    end.sum
  end

  def average_items_per_merchant_standard_deviation
    variance = difference_squared / (items_per_merchant.count - 1)
    return standard_deviation = Math.sqrt(variance).round(2)
  end

  def merchants_with_high_item_count
    high_count = []
    goal = (average_items_per_merchant_standard_deviation + 1)
    all_items_by_merchant.select do |id, items|
      high_count << @merchants_path.find_by_id(id) if items.count > goal
    end
    high_count
  end

  def average_item_price_for_merchant(id)
    items = @items_path.find_all_by_merchant_id(id)
    items.sum { |item| item.unit_price.to_i } / BigDecimal(items.count, 2)
    # items_with_same_merchant = @items_path.find_all_by_merchant_id(id)
    # sum = sum_of_of_item_price(id)
    # total_items = items_with_same_merchant.count
    # average_price = sum / total_items
  end

  def sum_of_of_item_price(id)
    items_with_same_merchant = @items_path.find_all_by_merchant_id(id)
    items_with_same_merchant.sum do |item|
      item.unit_price.to_i
    end
  end

  def average_average_price_per_merchant
    all_prices = @items_path.all.collect { |item| item.unit_price.to_i }
    (all_prices.reduce(:+) / BigDecimal(@merchants_path.all.count, 2))
  end

  def average_item_price
    all_prices = @items_path.all.collect { |item| item.unit_price.to_i }
    (all_prices.reduce(:+) / BigDecimal(@items_path.all.count)).round(2)
  end

  def price_difference_squared
    all_prices = @items_path.all.collect { |item| item.unit_price.to_i }
    all_prices.map do |price|
      (price - average_item_price)**2
    end.sum
  end

  def golden_items
    goal = average_item_price_standard_deviation + 2
    @items_path.all.find_all do |item|
      item if item.unit_price.to_i > goal
    end
  end

  def average_item_price_standard_deviation
    variance = price_difference_squared / BigDecimal(@items_path.all.count - 1)
    return standard_deviation = Math.sqrt(variance).round(2)
  end

  def inspect
    "#<#{self.class} #{@merchants.size} rows>"
  end
end
