module SmartAnswer
  class CalculateAgriculturalHolidayEntitlementFlow < Flow
    def define
      content_id "8834bc7c-7ac7-4d45-8a57-1d5a5dcd70a0"
      name 'calculate-agricultural-holiday-entitlement'
      status :published
      satisfies_need "100143"

      calculator = Calculators::AgriculturalHolidayEntitlementCalculator.new()

      multiple_choice :work_the_same_number_of_days_each_week? do
        option "same-number-of-days": "Yes"
        option "different-number-of-days": "No"

        next_node_map(
          "same-number-of-days": :how_many_days_per_week?,
          "different-number-of-days": :what_date_does_holiday_start?
        )
      end

      multiple_choice :how_many_days_per_week? do
        option "7-days": "7 days per week"
        option "6-days": "6 days per week"
        option "5-days": "5 days per week"
        option "4-days": "4 days per week"
        option "3-days": "3 days per week"
        option "2-days": "2 days per week"
        option "1-day": "1 day per week"

        calculate :days_worked_per_week do |response|
          # XXX: this is a bit nasty and takes advantage of the fact that
          # to_i only looks for the very first integer
          response.to_i
        end

        next_node :worked_for_same_employer?
      end

      date_question :what_date_does_holiday_start? do
        from { Date.civil(Date.today.year, 1, 1) }
        to { Date.civil(Date.today.year + 1, 12, 31) }

        calculate :weeks_from_october_1 do |response|
          calculator.weeks_worked(response)
        end

        next_node :how_many_total_days?
      end

      multiple_choice :worked_for_same_employer? do
        option "same-employer": "Yes"
        option "multiple-employers": "No"

        calculate :holiday_entitlement_days do |response|
          if response == 'same-employer'
            # This is calculated as a flat number based on the days you work
            # per week
            if !days_worked_per_week.nil?
              calculator.holiday_days(days_worked_per_week)
            elsif !weeks_from_october_1.nil?
              calculator.holiday_days (total_days_worked.to_f / weeks_from_october_1.to_f).round(10)
            end
          else
            nil
          end
        end

        next_node_map(
          "same-employer": :done,
          "multiple-employers": :how_many_weeks_at_current_employer?
        )
      end

      value_question :how_many_total_days?, parse: Integer do

        precalculate :available_days do
          calculator.available_days
        end

        validate { |response| response <= available_days }

        calculate :total_days_worked do |response|
          response
        end

        next_node :worked_for_same_employer?
      end

      value_question :how_many_weeks_at_current_employer?, parse: Integer do
        next_node :done

        #Has to be less than a full year
        validate { |response| response < 52 }

        calculate :holiday_entitlement_days do |response|
          if !days_worked_per_week.nil?
            days = calculator.holiday_days(days_worked_per_week)
          elsif !weeks_from_october_1.nil?
            days = calculator.holiday_days (total_days_worked.to_f / weeks_from_october_1.to_f).round(10)
          end
          sprintf("%.1f", (days * (response / 52.0)).round(10))
        end
      end

      outcome :done
    end
  end
end
