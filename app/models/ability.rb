class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    can :read, :all
    can :versions, :all
    if user
      can :vote, :all
      can :update, User, id: user.id
      if user.beta_tester?
        can :create, :all
        can :update, [Page, Argument], user_id: user.id
      end
      if user.id == 1 or (Rails.env.development? and [902541637, 663665735].include? user.id)
        can :access, :rails_admin       # only allow admin users to access Rails Admin
        can :dashboard
      end
    end
  end
end
