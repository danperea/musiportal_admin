# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Quick Links" do
          div class: "dashboard-links" do
            h3 "Manage Resources"
            ul do
              li { link_to "Users", admin_users_path, class: "btn btn-primary" }
              li { link_to "Events", admin_events_path, class: "btn btn-primary" }
              li { link_to "Gigs", admin_gigs_path, class: "btn btn-primary" }
              li { link_to "Genres", admin_genres_path, class: "btn btn-primary" }
              li { link_to "Vibes", admin_vibes_path, class: "btn btn-primary" }
            end

            h3 "Groups"
            ul do
              li { link_to "Bands", admin_bands_path, class: "btn btn-secondary" }
              li { link_to "Venues", admin_venues_path, class: "btn btn-secondary" }
              li { link_to "Event Planners", admin_event_planners_path, class: "btn btn-secondary" }
            end
          end
        end
      end

      column do
        panel "Recent Activity" do
          div class: "recent-activity" do
            h3 "Latest Events"
            begin
              recent_events = Event.order(created_at: :desc).limit(5)
              if recent_events.any?
                table_for recent_events do
                  column("Title") { |event| link_to event.title, admin_event_path(event) }
                  column("Date") { |event| event.date&.strftime("%B %d, %Y") || "TBD" }
                  column("Type") { |event| event.event_type&.humanize || "N/A" }
                  column("Created") { |event| time_ago_in_words(event.created_at) + " ago" }
                end
              else
                para "No events found."
              end
            rescue => e
              para "Error loading events: #{e.message}"
            end

            h3 "Latest Gigs"
            begin
              recent_gigs = Gig.order(created_at: :desc).limit(5)
              if recent_gigs.any?
                table_for recent_gigs do
                  column("Title") { |gig| link_to gig.title, admin_gig_path(gig) }
                  column("Status") { |gig| status_tag gig.status&.humanize || "Unknown" }
                  column("Budget") do |gig|
                    if gig.budget_min.present? && gig.budget_max.present?
                      "$#{gig.budget_min} - $#{gig.budget_max}"
                    elsif gig.budget_min.present?
                      "$#{gig.budget_min}+"
                    else
                      "Negotiable"
                    end
                  end
                  column("Created") { |gig| time_ago_in_words(gig.created_at) + " ago" }
                end
              else
                para "No gigs found."
              end
            rescue => e
              para "Error loading gigs: #{e.message}"
            end
          end
        end
      end
    end

    columns do
      column do
        panel "System Statistics" do
          div class: "stats-grid" do
            begin
              user_count = User.count
              event_count = Event.count
              gig_count = Gig.count
              genre_count = Genre.count
              vibe_count = Vibe.count

              table do
                tr do
                  td { strong "Total Users:" }
                  td { user_count }
                end
                tr do
                  td { strong "Total Events:" }
                  td { event_count }
                end
                tr do
                  td { strong "Total Gigs:" }
                  td { gig_count }
                end
                tr do
                  td { strong "Total Genres:" }
                  td { genre_count }
                end
                tr do
                  td { strong "Total Vibes:" }
                  td { vibe_count }
                end
              end
            rescue => e
              para "Error loading statistics: #{e.message}"
            end
          end
        end
      end

      column do
        panel "Recent Users" do
          begin
            recent_users = User.order(created_at: :desc).limit(10)
            if recent_users.any?
              table_for recent_users do
                column("Name") { |user| link_to user.name, admin_user_path(user) }
                column("Email") { |user| user.email }
                column("Joined") { |user| time_ago_in_words(user.created_at) + " ago" }
              end
            else
              para "No users found."
            end
          rescue => e
            para "Error loading users: #{e.message}"
          end
        end
      end
    end

    # Add some custom styling
    div class: "dashboard-style" do
      style do
        raw <<~CSS
          .dashboard-links ul {
            list-style: none;
            padding: 0;
          }
          .dashboard-links li {
            margin: 8px 0;
          }
          .dashboard-links .btn {
            display: inline-block;
            padding: 8px 16px;
            text-decoration: none;
            border-radius: 4px;
            color: white;
            margin-right: 8px;
          }
          .btn-primary {
            background-color: #007cba;
          }
          .btn-secondary {
            background-color: #6c757d;
          }
          .recent-activity h3 {
            margin-top: 20px;
            margin-bottom: 10px;
            color: #333;
          }
          .stats-grid table {
            width: 100%;
          }
          .stats-grid td {
            padding: 4px 8px;
          }
        CSS
      end
    end
  end # content
end
