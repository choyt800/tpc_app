class Membership < ActiveRecord::Base

  belongs_to :member
  belongs_to :plan

  validates :member_id, presence: true
  validates :plan_id, presence: true
  attr_accessor :plan_category_id, :trial_period_days, :coupon

  scope :active, -> { where("end_date": nil) }

  def next_bill_date
    if start_date?
      #calculate next bill date if member is on month-to-month membership
      if payment_type == "Month-to-month"
        if Date.today.strftime("%d").to_i < start_date.strftime("%d").to_i
          @next_bill = "#{Date.today.year}-#{Date.today.strftime("%m")}-#{start_date.strftime("%d")}"
        else
          if Date.today.month.to_i != 12
            @next_bill = "#{Date.today.year}-#{1.month.from_now.month}-#{start_date.strftime("%d")}"
          else
            @next_bill = "#{1.year.from_now.year}-#{1.month.from_now.month}-#{start_date.strftime("%d")}"
          end
        end

      #calculate next bill date if member is on prepaid membership
      elsif payment_type.include? "Prepaid"
        x = payment_type.gsub(/[^\d]/, '').to_i

        if Date.today < (start_date.to_date + x.months)
          @next_bill =  start_date.to_date + x.months
        else
          y = ((Date.today - start_date.to_date).to_i) / (x * 30)
          @next_bill = (start_date.to_date + x.months + ((y * x).months))
        end
      else
        @next_bill =  "N/A"
      end

      @next_bill
    end
  end



  def length_of_membership
    if end_date != nil
      length_of_membership = ((end_date - start_date) / 86400).to_i
    else
      length_of_membership = (Date.today.mjd - start_date.to_date.mjd).to_i
    end
  end

  def status
    if end_date? && Date.current <= end_date
      "pending cancellation"
    elsif end_date?
      "cancelled"
    else
      "live"
    end
  end

  def period_start
    @previous_month = (Date.today - 1.month).month
    @previous_year = (Date.today - 1.year).year
    #calculate period_start when today's day of month is before start_date day of month
    if Date.today.strftime("%d").to_i < start_date.strftime("%d").to_i
      if Date.today.month.to_i != 1
        @period_start = "#{Date.today.year}-#{@previous_month}-#{start_date.strftime("%d")}"
      else
        @period_start = "#{@previous_year}-#{@previous_month}-#{start_date.strftime("%d")}"
      end
    else
      #calculate period_start when today's day of month is after start_date day of month
      @period_start = "#{Date.today.year}-#{Date.today.strftime("%m")}-#{start_date.strftime("%d")}"
    end
  end

  def period_end
    @period_end = @period_start.to_date + 1.month
  end

  def checkins_in_period
    @start_date = @period_start.to_datetime
    @end_date = @period_end.to_datetime
    @checkins = member.checkins.where(:date => @start_date..@end_date).count
    # @start_date.to_s
    # @end_date.to_s
  end

  def days
    if plan.name != "Community FT"
      @days = plan.name.gsub(/[^\d]/, '')
    else
    end
  end

  def days_left
    @days_left = @days.to_i - @checkins.to_i
  end
end
