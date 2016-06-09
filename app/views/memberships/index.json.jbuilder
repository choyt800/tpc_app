json.array!(@memberships) do |membership|
  json.extract! membership, :id, :type, :start_date, :datetime
  json.url membership_url(membership, format: :json)
end
