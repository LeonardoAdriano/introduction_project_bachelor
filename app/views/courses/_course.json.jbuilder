json.extract! course, :id, :name, :private, :valid_until, :accessible_until, :accessible_from, :created_at, :updated_at
json.url course_url(course, format: :json)
