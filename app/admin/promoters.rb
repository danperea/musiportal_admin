ActiveAdmin.register Promoter do
  # Customize index view
  index do
    selectable_column
    id_column
    column :name
    column :location
    column :bio do |promoter|
      truncate(promoter.bio.to_s, length: 100)
    end
    column :verified
    column :created_at
    actions
  end

  # Customize show view
  show do
    attributes_table do
      row :id
      row :name
      row :type
      row :location
      row :bio
      row :description
      row :website
      row :email
      row :phone
      row :verified
      row :created_at
      row :updated_at
    end

    panel "Members" do
      table_for promoter.members do
        column :name
        column :email
        column("Role") { |user| promoter.memberships.find_by(user: user)&.roles&.join(", ") }
      end
    end

    panel "Events" do
      table_for promoter.events.limit(10) do
        column :title
        column :date
        column :location
      end
    end
  end

  # Customize form
  form do |f|
    f.inputs "Promoter Details" do
      f.input :name
      f.input :bio, as: :text
      f.input :description, as: :text
      f.input :location
      f.input :website
      f.input :email
      f.input :phone
      f.input :verified
    end
    f.actions
  end

  # Filters
  filter :name
  filter :location
  filter :verified
  filter :created_at

  # Permit params
  permit_params :name, :bio, :description, :location, :website, :email, :phone, :verified
end