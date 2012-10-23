# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'child-benefit-tax-calculator'
    @stubbed_calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
    add_response :income_work_out
    add_response "2012-13"
  end

  should "ask what is your income" do
    assert_current_node :what_is_your_estimated_income_for_the_year_before_tax?
  end

  context "adjusted income tests" do
	  context "income at 60k" do
	  	setup do
	  		add_response "60000"
    		add_response :yes    
	  	end

	  	should "ask about pension" do
        assert_current_node :how_much_pension_contributions_before_tax?
      end

      context "test 01" do
      	setup do
      		add_response "5000"    # Q3A Gross Pension
          add_response "1600"    # Q4 net pension 
          add_response "1000"    # Q5 trading losses 
        end

        should "ask about charity donations" do
          assert_current_node :how_much_do_you_expect_to_give_to_charity_this_year?
          assert_state_variable :total_income, 60000
          assert_state_variable :gross_pension_contributions, 5000
          assert_state_variable :net_pension_contributions, 1600
          assert_state_variable :trading_losses, 1000
          assert_state_variable :total_deductions, 8000
          assert_state_variable :adjusted_net_income, 52000 
        end

        should "ask about children claiming for" do 
        	add_response "800"
        	assert_current_node :how_many_children_claiming_for?
          assert_state_variable :adjusted_net_income, 51000
        end
      end

      context "test 02" do
      	setup do
      		add_response "5000"    # Q3A Gross Pension
          add_response "0"    # Q4 net pension 
          add_response "0"    # Q5 trading losses 
        	add_response "0"		# Q6 Gift Aided 
        end

        should "ask about children claiming for" do 
        	assert_current_node :how_many_children_claiming_for?
          assert_state_variable :total_deductions, 5000
          assert_state_variable :adjusted_net_income, 55000 
        end
      end

      context "test 03" do
      	setup do
      		add_response "0"    # Q3A Gross Pension
          add_response "1600"    # Q4 net pension 
          add_response "0"    # Q5 trading losses 
        	add_response "0"		# Q6 Gift Aided 
        end

        should "ask about children claiming for" do 
        	assert_current_node :how_many_children_claiming_for?
          assert_state_variable :total_deductions, 2000
          assert_state_variable :adjusted_net_income, 58000 
        end
      end
      
      context "test 04" do
      	setup do
      		add_response "0"    # Q3A Gross Pension
          add_response "0"    # Q4 net pension 
          add_response "3000"    # Q5 trading losses 
        	add_response "0"		# Q6 Gift Aided 
        end

        should "ask about children claiming for" do 
        	assert_current_node :how_many_children_claiming_for?
          assert_state_variable :total_deductions, 3000
          assert_state_variable :adjusted_net_income, 57000 
        end
      end

      context "test 05" do
      	setup do
      		add_response "0"    # Q3A Gross Pension
          add_response "0"    # Q4 net pension 
          add_response "0"    # Q5 trading losses 
        	add_response "1600"		# Q6 Gift Aided 
        end

        should "ask about children claiming for" do 
        	assert_current_node :how_many_children_claiming_for?
          assert_state_variable :total_deductions, 0
          assert_state_variable :adjusted_net_income, 58000 
        end
      end
	  end
  end

end