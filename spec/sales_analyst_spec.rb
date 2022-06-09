
require_relative "../lib/sales_engine"
require_relative "../lib/item_repository"
require_relative "../lib/merchant_repository"
require_relative "../lib/sales_analyst"
require_relative "../lib/invoice_item_repository"

RSpec.describe SalesAnalyst do
  before :each do
    @sales_engine = SalesEngine.from_csv({
      :items => './data/items.csv',
      :merchants => './data/merchants.csv',
      :invoices => './data/invoices.csv',
      :transactions => './data/transactions.csv',
      :invoice_items => './data/invoice_items.csv'
    })
    @sales_analyst = @sales_engine.analyst
  end

  it 'exists' do

    expect(@sales_analyst).to be_instance_of SalesAnalyst
  end

  it 'can group all items by merchant id' do

    expect(@sales_analyst.all_items_by_merchant).to be_a Hash
  end

  it 'can return an array of the number of items per merchant' do

    expect(@sales_analyst.items_per_merchant).to be_a Array
    expect(@sales_analyst.items_per_merchant.length).to eq 475
  end

  it 'can calculate the average number of items per merchant' do

    expect(@sales_analyst.average_items_per_merchant).to eq 2.88
  end

  it 'calculates items per merchant standard deviation' do

    expect(@sales_analyst.average_items_per_merchant_standard_deviation).to eq(3.26)
  end

  it 'can find the difference of each number' do

    expect(@sales_analyst.difference_squared).to be_a Float
  end

  it 'can find find merchants with highest item count' do

    expect(@sales_analyst.merchants_with_high_item_count).to be_a Array
    expect(@sales_analyst.merchants_with_high_item_count.first).to be_a Merchant
  end

  it 'can find the sum of a merchants items' do

    expect(@sales_analyst.sum_of_of_item_price(12334159)).to eq 31500.0
  end

  it 'can find the average item price per merchant' do

    expect(@sales_analyst.average_item_price_for_merchant(12334159)).to be_a BigDecimal
    expect(@sales_analyst.average_item_price_for_merchant(12334159)).to eq(0.315e4)
  end

  it 'can find the average of average prices per merchant' do

    expect(@sales_analyst.average_average_price_per_merchant).to be_a BigDecimal
  end

  it 'can find items 2 standard deviations above average item price' do

    expect(@sales_analyst.golden_items).to be_a Array
    expect(@sales_analyst.golden_items.first).to be_a Item
  end

  it 'can find the sum of each merchants invoices' do
    expect(@sales_analyst.all_invoices_by_merchant).to be_a Hash
  end

  it 'can determine the average invoices per merchant' do
    expect(@sales_analyst.average_invoices_per_merchant).to eq 10.49
  end

  it 'can determine the average invoices per merchant' do
    expect(@sales_analyst.average_invoices_per_merchant_standard_deviation).to eq 3.29
  end

  it 'can calcuate the top merchants (more than 2 standard deviations) and return an array' do
    expect(@sales_analyst.top_merchants_by_invoice_count.first).to be_a Merchant
    expect(@sales_analyst.top_merchants_by_invoice_count).to be_a Array
  end

  it 'can calcuate the top merchants (more than 2 standard deviations) and return an array' do
    expect(@sales_analyst.bottom_merchants_by_invoice_count.first).to be_a Merchant
    expect(@sales_analyst.bottom_merchants_by_invoice_count).to be_a Array
  end

  it 'can separate the invoices by days of the week' do
    expect(@sales_analyst.day_total_invoices).to be_a Hash
  end

  it 'calculate invoice count by merchant' do
    expect(@sales_analyst.invoice_count_per_merchant).to be_a Hash
  end

  it 'can return the date for the top DAYS for invoices more than 1 above standard deviation above the mean' do
    expect(@sales_analyst.top_days_by_invoice_count).to be_a Array
    expect(@sales_analyst.top_days_by_invoice_count.first).to be_a String
  end

  it 'can calculate the percentage of status in the argument' do
    expect(@sales_analyst.invoice_status(:pending)).to eq(29.55)
    expect(@sales_analyst.invoice_status(:shipped)).to eq(56.95)
    expect(@sales_analyst.invoice_status(:returned)).to eq(13.5)
  end

  it 'can determine if an invoice is paid in full' do
    expect(@sales_analyst.invoice_paid_in_full?(2179)).to be true
  end

  it 'can determine total revenue by invoice' do
    expect(@sales_analyst.invoice_total(2179)).to be_a String
  end
end
