class AddReferencesToKeycardCheckoutsAndMailServices < ActiveRecord::Migration
  def change
    add_reference :keycard_checkouts, :plan, index: true
    add_reference :mail_services, :plan, index: true
  end
end
