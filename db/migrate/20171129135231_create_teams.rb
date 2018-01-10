class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string    :name
      t.string    :owner
      t.string    :owner_email
      t.string    :stripe_id
      t.text      :notes

      t.string    :avatar_file_name
      t.string    :avatar_content_type
      t.integer   :avatar_file_size
      t.datetime  :avatar_updated_at

      t.string    :document_file_name
      t.string    :document_content_type
      t.integer   :document_file_size
      t.datetime  :document_updated_at

      t.timestamps null: false
    end

    add_column :members,            :team_id, :integer
    add_column :memberships,        :team_id, :integer
    add_column :keycard_checkouts,  :team_id, :integer
    add_column :mail_services,      :team_id, :integer
  end
end
