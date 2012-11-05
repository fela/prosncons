class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :user
      t.references :votable, polymorphic: true

      t.integer :vote
      t.string :ip
      t.timestamps
    end
  end
end
