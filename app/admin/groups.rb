ActiveAdmin.register Group do

  permit_params :name, :type, :bio, :description, :location, :zipCode, :website,
                :image_url, :email, :phone, :verified,
                genres: [], vibes: [], genre_ids: [], vibe_ids: []

  # Index page configuration
  index do
    selectable_column
    id_column
    column :name
    column :type
    column :location
    column :email
    column :phone
    column :verified
    column "Members" do |group|
      group.users.count
    end
    column :created_at
    actions
  end

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :name
      row :type
      row :bio
      row :description
      row :location
      row :zipCode
      row :website do |group|
        group.website ? link_to(group.website, group.website, target: '_blank') : nil
      end
      row :image_url
      row :email
      row :phone
      row :verified
      row :genres do |group|
        group.genres&.join(', ')
      end
      row :vibes do |group|
        group.vibes&.join(', ')
      end
      row :created_at
      row :updated_at
    end

    panel "Members" do
      table_for group.memberships.includes(:user) do
        column "User" do |membership|
          link_to membership.user.name, admin_user_path(membership.user)
        end
        column :roles do |membership|
          membership.roles&.join(', ')
        end
        column :status
        column :created_at
      end
    end

    panel "Events" do
      table_for group.events.limit(10) do
        column :title
        column :date
        column :location
        column :event_type
      end
    end
  end

  # Form configuration
  form do |f|
    f.inputs "Group Details" do
      f.input :name
      f.input :type, as: :select, collection: ['band', 'venue', 'promoter', 'festival']
      f.input :bio, as: :text
      f.input :description, as: :text
      f.input :location
      f.input :zipCode
      f.input :website
      f.input :image_url
      f.input :email
      f.input :phone
      f.input :verified
    end

    f.inputs "Categories" do
      f.input :genres, as: :check_boxes, collection: Genre.all.collect { |g| [g.name, g.name] }
      f.input :vibes, as: :check_boxes, collection: Vibe.all.collect { |v| [v.name, v.name] }
    end

    f.actions
  end

  # Filters
  filter :name
  filter :type
  filter :location
  filter :verified
  filter :created_at

end