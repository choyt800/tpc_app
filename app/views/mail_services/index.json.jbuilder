json.array!(@mail_services) do |mail_service|
  json.extract! mail_service, :id, :member_id, :mailbox_id, :start_date, :end_date, :notes
  json.url mail_service_url(mail_service, format: :json)
end
