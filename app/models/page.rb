class Page < ActiveRecord::Base
  attr_accessible :content, :option1, :option2, :title
  validates_presence_of :title, :content

  has_many :arguments, dependent: :destroy

  def arguments_for(option)
    arguments.select{|x| x.option.parameterize == option.parameterize}
  end

  def arguments1
    arguments_for(option1)
  end

  def arguments2
    arguments_for(option2)
  end
end
