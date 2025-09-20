ActiveAdmin.register Event do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :date, :time, :location, :description, :event_type, :user_id, :group_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :date, :time, :location, :description, :event_type, :user_id, :group_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # Explicitly define filters to avoid ransack issues
  filter :title
  filter :date
  filter :time
  filter :location
  filter :event_type
  filter :user
  filter :group

  # Remove gigs from filters to prevent ransack errors
  remove_filter :gigs

end
