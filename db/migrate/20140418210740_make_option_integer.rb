class MakeOptionInteger < ActiveRecord::Migration
  def up
    options = {}
    Argument.all.each do |a|
      options[a.id] = a.option
    end
    remove_column :arguments, :option
    add_column :arguments, :option, :integer
    Argument.all.each do |a|
      option = options[a.id]
      index = [a.page.option1, a.page.option2].index(option)
      if index.nil?
        print "No valid option found for #{a}"
        index = option == 'cons' ? 1 : 0
      end
      a.option = index
      a.save!
    end
  end

  def down
    options = {}
    Argument.all.each do |a|
      options[a.id] = a.option
    end
    remove_column :arguments, :option
    add_column :arguments, :option, :string
    Argument.all.each do |a|
      index = options[a.id]
      a.option = [a.page.option1, a.page.option2][index]
      a.save!
    end
  end
end
