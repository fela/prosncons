class CreateArguments < ActiveRecord::Migration
  def change
    create_table :arguments do |t|
      t.string :summary
      t.string :option
      t.text :description
      t.references :page

      t.timestamps
    end
  end
end
