class CreateArguments < ActiveRecord::Migration
  def change
    create_table :arguments do |t|
      t.string :option
      t.string :summary
      t.text :description
      t.references :page
      t.references :user

      t.timestamps
    end
  end
end
