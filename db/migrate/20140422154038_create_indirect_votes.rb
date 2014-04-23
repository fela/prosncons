class CreateIndirectVotes < ActiveRecord::Migration
  def change
    create_table :indirect_votes do |t|
      t.references :vote, index: true
      t.references :argument, index: true
      t.integer :position
      t.integer :voted_for_position
      t.boolean :same_option

      t.timestamps
    end
  end
end
