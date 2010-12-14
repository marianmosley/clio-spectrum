class Library < ActiveRecord::Base
  validates_uniqueness_of :hours_db_code
  has_many :hours, :class_name => "LibraryHours", :dependent => :destroy


  def hours_for_range(startdate, enddate)
    hours.find(:all, :conditions => ["library_hours.date BETWEEN ? and ?", startdate.to_date, enddate.to_date]).sort { |x,y| x.date <=> y.date }
  end

  def is_open?(check_at)
    hours_res = hours.find_by_date(check_at.to_date)
    
    hours_res ? hours_res.opens <= check_at && check_at <= hours_res.closes : false

  end
end
