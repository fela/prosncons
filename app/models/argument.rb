class Argument < ActiveRecord::Base
  attr_accessible :summary, :description, :option
  validates_presence_of :summary, :description, :option, :page
  belongs_to :page

  # validate :my_method
  #def expiration_date_cannot_be_in_the_past
  #  if !expiration_date.blank? and expiration_date < Date.today
  #    errors.add(:expiration_date, "can't be in the past")
  #  end
  #end
end