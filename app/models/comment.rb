class Comment < ActiveRecord::Base
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
end