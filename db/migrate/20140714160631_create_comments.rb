class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user
      t.references :about, polymorphic: true

      t.string :title
      t.string :content
      t.timestamps
    end
  end
end
