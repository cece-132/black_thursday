require 'csv'
require_relative 'invoice'
require_relative 'merchant'
require_relative 'repositable'

class InvoiceRepository
  include Repositable
  attr_reader :all, :file_path

  def initialize(file_path)
    @file_path = file_path
    @all = []
      if @file_path
        CSV.foreach(@file_path, headers: true, header_converters: :symbol) do |row|
          @all << Invoice.new({
            :id => row[:id].to_i,
            :customer_id => row[:customer_id].to_i,
            :merchant_id => row[:merchant_id].to_i,
            :status => row[:status].to_sym,
            :created_at => row[:created_at],
            :updated_at => row[:updated_at]})
          end
        end
  end

  def find_all_by_customer_id(id)
    @all.find_all do |customer|
      customer.customer_id == id
    end
  end

  def find_all_by_status(status)
    @all.find_all do |invoice|
      invoice.status == status
    end
  end

  def create(attributes)
    new_id = attributes[:id] = @all.last.id + 1
    @all << Invoice.new({
      :id => new_id,
      :customer_id => attributes[:customer_id].to_i,
      :merchant_id => attributes[:merchant_id].to_i,
      :status => attributes[:status].to_sym,
      :created_at => attributes[:created_at],
      :updated_at => attributes[:updated_at]
      })
  end

  def update(id, attributes)
    invoice = find_by_id(id)
    if attributes[:status] == "shipped".downcase  || "pending".downcase || "returned".downcase
      invoice.status = attributes[:status].to_sym
    end
  end

  def inspect
    "#<#{self.class} #{@invoices.all} rows>"
  end

end
