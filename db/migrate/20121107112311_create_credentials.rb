class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.references :user

      t.string :email, unique: true
      t.timestamps
    end
  end
end
