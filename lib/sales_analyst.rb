require_relative "sales_engine"
require "BigDecimal"
require 'date'

class SalesAnalyst
  attr_reader :items_path, :merchants_path, :invoices_path, :transactions_path, :invoice_items

  def initialize(items_path, merchants_path, invoices_path,transactions_path,invoice_items)
    @items_path = items_path
    @merchants_path = merchants_path
    @invoices_path = invoices_path
    @transactions_path = transactions_path
    @invoice_items = invoice_items
  end

  def average_items_per_merchant
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

  def all_invoices_by_merchant
   @invoices_path.all.group_by do |invoice|
    invoice.merchant_id
    end
  end

  def average_invoices_per_merchant
    (all_invoices_by_merchant.sum { |merchant_id, invoices| invoices.count}.to_f / all_invoices_by_merchant.count).round(2)
  end

  def difference_squared_merchants
   all_invoices_by_merchant.map do |id, invoices|
      (invoices.count - average_invoices_per_merchant)**2
    end.sum
  end

  def average_invoices_per_merchant_standard_deviation
    variance = difference_squared_merchants / (all_invoices_by_merchant.count - 1)
    return standard_deviation = Math.sqrt(variance).round(2)
  end

  def top_merchants_by_invoice_count
    top_merchants = []
    goal = (average_invoices_per_merchant_standard_deviation + 2)
    all_invoices_by_merchant.find_all do |merchant_id, invoices|
      top_merchants << @merchants_path.find_by_id(merchant_id) if invoices.count > goal 
    end
    top_merchants
  end

  def bottom_merchants_by_invoice_count
    bottom_merchants = []
    goal = (average_invoices_per_merchant_standard_deviation - 2)
    all_invoices_by_merchant.find_all do |merchant_id, invoices|
      bottom_merchants << @merchants_path.find_by_id(merchant_id) if invoices.count > goal 
    end
    bottom_merchants
  end

  def invoice_count_per_merchant
    invoice_count = {}
    frog = all_invoices_by_merchant.collect do |merchant_id, invoices|
      invoice_count[merchant_id] = invoices.count
    end
  invoice_count
  end

  def day_total_invoices
    days = Hash.new(0)
    @invoices_path.all.select do |invoice|
        days[Time.new(invoice.created_at).to_date.strftime("%A")] += 1 
    end
    days
  end

  def top_days_by_invoice_count
    goal = (day_total_invoices.values.sum / day_total_invoices.count) + (average_invoices_per_merchant_standard_deviation + 1)
    day_total_invoices.map do |day, total_invoices|
      day if total_invoices >= goal
    end.compact
  end

  def invoice_status(status)
    sum = day_total_invoices.values.sum.to_f 
    total_status = @invoices_path.find_all_by_status(status).count.to_f
    ((total_status / sum) * 100).round(2)
  end

  def invoice_paid_in_full?(invoice_id)
     results = @transactions_path.find_all_by_invoice_id(invoice_id).collect { |invoice|invoice.result}
    if results.include?('success')
      true
    else 
      false
    end
  end

  def invoice_total(invoice_id)
     total_invoices = @invoice_items.find_all_by_invoice_id(invoice_id)

     total_spent = total_invoices.sum do |invoice|
      invoice.quantity.to_i * invoice.unit_price
     end
     return "Invoice ID:#{invoice_id} Total: $#{total_spent}"
  end

  def inspect
    "#<#{self.class} #{@merchants.size} rows>"
  end
end
