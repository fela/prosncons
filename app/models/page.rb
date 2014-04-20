class Page < ActiveRecord::Base
  has_paper_trail :on => [:update, :destroy]
  attr_accessible :content, :option1, :option2, :title
  validates_presence_of :title, :content
  validate :options_should_be_different

  has_many :arguments, dependent: :destroy
  has_many :votes, as: :votable
  belongs_to :user

  alias_attribute :author, :user

  def arguments_for(option)
    res = arguments.select{|x| x.option == option}
    res.sort {|x, y| y.score <=> x.score}
  end

  def arguments1
    arguments_for(0)
  end

  def arguments2
    arguments_for(1)
  end

  def option_index(option)
    options.index(option)
  end

  def options
    [option1, option2]
  end

  def options_should_be_different
    if option1 == option2
      errors.add(:option2, 'should be different from the first option')
    end
  end
end
