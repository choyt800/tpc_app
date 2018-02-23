class AddTeamActiveToMember < ActiveRecord::Migration
  def change
    add_column :members, :team_active, :boolean, default: true
  end
end
