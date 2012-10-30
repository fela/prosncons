class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :content
      t.string :option1, default: 'pros'
      t.string :option2, default: 'cons'

      t.timestamps
    end
  end
end
