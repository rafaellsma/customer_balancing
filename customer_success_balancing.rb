require "set"

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    away_customer_success_set = Set.new(away_customer_success)

    available_customer_success = customer_success.select do |cs|
      !away_customer_success_set.include? cs[:id]
    end

    available_customer_success.sort! do |first_cs, second_cs|
      first_cs[:score] <=> second_cs[:score]
    end

    qt_customers_by_cs = Hash.new(0)
    customers.each do |customer|
      cs = available_customer_success.bsearch { |cs| cs[:score] >= customer[:score] }
      unless cs.nil?
        qt_customers_by_cs[cs[:id]] += 1
      end
    end

    get_most_popular_cs_id(qt_customers_by_cs)
  end

  private

  attr_accessor :customer_success, :customers, :away_customer_success

  def get_most_popular_cs_id(qt_customers_by_cs)
    if (qt_customers_by_cs.empty?)
      return 0
    end

    largests_qt_customers = qt_customers_by_cs.values.max(2)

    if (largests_qt_customers.size == 1 || has_two_most_popular_cs_differents_customers_qt?(largests_qt_customers))
      qt_customers_by_cs.key(largests_qt_customers[0])
    else
      return 0
    end
  end

  def has_two_most_popular_cs_differents_customers_qt?(amounts)
    return amounts[0] != amounts[1]
  end
end
