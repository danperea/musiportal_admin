ActiveAdmin.register User do

  permit_params :name, :email, :location, :bio, :phone, :active_group_id, :profile_picture,
                genres: [], vibes: [], portfolio_videos: [], roles: []

  # Index page configuration
  index do
    selectable_column
    id_column
    column :name
    column :email
    column :location
    column :phone
    column :active_group do |user|
      user.active_group&.name
    end
    column :created_at
    actions
  end

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :location
      row :bio
      row :phone
      row :roles do |user|
        user.roles&.join(', ')
      end
      row :active_group do |user|
        user.active_group&.name
      end
      row :genres do |user|
        user.genres&.join(', ')
      end
      row :vibes do |user|
        user.vibes&.join(', ')
      end
      row :profile_picture
      row :created_at
      row :updated_at
    end

    panel "Groups" do
      table_for user.groups do
        column :name
        column :type
        column :location
        column :created_at
      end
    end

    panel "Events" do
      table_for user.events.limit(10) do
        column :title
        column :date
        column :location
        column :event_type
      end
    end
  end

  # Form configuration
  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :location
      f.input :bio, as: :text
      f.input :phone
      f.input :active_group, as: :select, collection: Group.all.collect { |g| [g.name, g.id] }
      f.input :profile_picture
    end

    f.inputs "Categories" do
      f.input :genres, as: :check_boxes, collection: Genre.all.collect { |g| [g.name, g.name] }
      f.input :vibes, as: :check_boxes, collection: Vibe.all.collect { |v| [v.name, v.name] }
    end

    f.actions
  end

  # Filters
  filter :name
  filter :email
  filter :location
  filter :active_group
  filter :created_at

end
