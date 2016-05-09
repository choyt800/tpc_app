class CreateKeycards < ActiveRecord::Migration
  def change
    create_table :keycards do |t|
      t.string :number
      t.string :hours

      t.timestamps null: false
    end
  end
end
