class Page < ActiveRecord::Base
  has_paper_trail :on => [:update, :destroy]
  attr_accessible :content, :option1, :option2, :title
  validates_presence_of :title, :content

  has_many :arguments, dependent: :destroy
  has_many :votes, as: :votable
  belongs_to :user

  alias :author :user

  def arguments_for(option)
    res = arguments.select{|x| x.option.parameterize == option.parameterize}
    res.sort {|x, y| y.score <=> x.score}
  end

  def arguments1
    arguments_for(option1)
  end

  def arguments2
    arguments_for(option2)
  end
end
