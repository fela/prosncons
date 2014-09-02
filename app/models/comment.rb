class Comment < ActiveRecord::Base
  attr_accessible :title, :content
  belongs_to :about, polymorphic: true
  belongs_to :user

  alias_attribute :author, :user

  def page
    if about.is_a? Page
      about
    else
      about.page
    end
  end

  def to_s
    return "Comment ##{id}: #{title.inspect}"
  end
end