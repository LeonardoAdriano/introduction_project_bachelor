json.extract! user, :id, :name, :entered, :mail, :verified, :password, :created_at, :updated_at
json.url user_url(user, format: :json)
