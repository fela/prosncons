class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :primary_email, unique: true
      t.string :name
      t.text :urls

      t.timestamps
    end
  end
end
