class Page < ActiveRecord::Base
  has_paper_trail :on => [:update, :destroy]
  attr_accessible :content, :option1, :option2, :title
  validates_presence_of :content
  validates :title, length: { in: 6..128 }
  #validates :content, length: { minimum: 16}  # have to fix form first
  validate :options_should_be_different


  has_many :arguments, -> {order [:option, :created_at]}, dependent: :destroy
  has_many :votes, as: :votable
  has_many :comments, as: :about
  belongs_to :user

  alias_attribute :author, :user

  def arguments_for(option)
    res = arguments.where(option: option)
    res.sort_by {|x| [-x.score, -x.created_at.to_i]}
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

  # TODO: extract in common module
  # returns all versions including the user that made it and the
  def version_history
    res = []
    event = 'create'
    author = user
    versions.each do |version|
      # some old entries still include create actions
      # TODO remove next line
      next if version.event == 'create'
      res << {
          obj: version.reify,
          event: event,
          author: author
      }
      event = version.event
      author = User.find_by_id(version.whodunnit.to_i)
    end
    res << {
        obj: self,
        event: event,
        author: author
    }
  end


end
