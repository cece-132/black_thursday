require 'csv'
require_relative 'item'
require_relative 'repositable'

class ItemRepository
  include Repositable
  attr_reader :all

  def initialize(file_path)
    @file_path = file_path
    @all = []

      if @file_path
        CSV.foreach(@file_path, headers: true, header_converters: :symbol) do |row|
          @all << Item.new({
            :id => row[:id],
            :name => row[:name],
            :description => row[:description],
            :unit_price => row[:unit_price],
            :created_at => row[:created_at],
            :updated_at => row[:updated_at],
            :merchant_id => row[:merchant_id]})
        end
      end
  end

    def find_all_with_description(description)
      @all.find_all do |item|
        item.description.downcase.include?(description.downcase)
      end
    end


    def find_all_by_price(price)
       frog = @all.find_all do |item|
        BigDecimal(item.unit_price, 2) == price
      end
    end

    def find_all_by_price_in_range(range)
        @all.find_all do |item|
            item.unit_price.to_i.between?(range.first + 1, range.last - 1)
        end
    end

    def update(id,attributes)
        item = find_by_id(id)
        item.name = attributes[:name] if attributes[:name] != nil
        item.description = attributes[:description] if attributes[:description] != nil
        item.unit_price = attributes[:unit_price] if attributes[:unit_price] != nil
    end

    def delete(id)
        item = find_by_id(id)
        @all.delete(item)
    end

    def create(attributes)
      new_id = attributes[:id] = @all.last.id + 1
      @all << Item.new({
        :id => new_id,
        :name => attributes[:name],
        :description => attributes[:description],
        :unit_price => attributes[:unit_price],
        :created_at => attributes[:created_at],
        :updated_at => attributes[:updated_at],
        :merchant_id => attributes[:merchant_id]
        })
    end


    def inspect
      "#<#{self.class} #{@items.all} rows>"
    end
  
end 

