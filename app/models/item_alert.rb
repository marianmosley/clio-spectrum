class ItemAlert < ActiveRecord::Base
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"

  attr_accessible :source, :item_key, :author_id, :alert_type,
                  :start_date, :end_date, :message

  validates :author_id, :presence => true
  validates :message, :presence => true
  validates :source, :presence => true
  validates :item_key, :presence => true

  ALERT_TYPES = {
    'access_requirements' => 'Access Requirements',
    'alert' =>  'Alert',
    # 'alternate_connect' => 'Alternate Connect',
    # 'elink_enabled' =>  'eLink Enabled',
    # 'related_resources' => 'Related Resources'
  }


  def active?
    # puts "====  start_date=#{start_date} end_date=#{end_date}  DateTime.now=#{DateTime.now}"
    (start_date.nil? || start_date < DateTime.now) &&
    (end_date.nil? || end_date > DateTime.now)
  end

end
