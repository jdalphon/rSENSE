class CreateVislogs < ActiveRecord::Migration
  def change
    create_table :vislogs do |t|
      t.text :data
      t.integer :visualization_id
      t.integer :user_id

      t.timestamps
    end
  end
end
