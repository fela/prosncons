class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :content
      t.string :option1
      t.string :option2

      t.timestamps
    end
  end
end
