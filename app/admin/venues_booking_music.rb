# frozen_string_literal: true
ActiveAdmin.register_page "Venues Booking Music" do
  menu parent: "Booking", label: "Venues Booking Music"

  content title: "Venues Booking Music" do
    div class: "venues-booking-section" do
      para "Venues actively seeking new music bookings"

      begin
        venues_seeking_music = Venue.where(needs_new_music: true).order(:name)

        if venues_seeking_music.any?
          table_for venues_seeking_music do
            column("Name") { |venue| link_to venue.name, admin_venue_path(venue) }
            column("Location") { |venue| venue.location }
            column("Website") do |venue|
              if venue.website.present?
                link_to "Visit", venue.website, target: "_blank", class: "btn btn-sm"
              else
                "N/A"
              end
            end
            column("Email") do |venue|
              if venue.email.present?
                mail_to venue.email, "Contact", class: "btn btn-sm"
              else
                "N/A"
              end
            end
            column("Phone") { |venue| venue.phone || "N/A" }
            column("Genres") do |venue|
              if venue.genres.present?
                venue.genres.join(", ")
              else
                "Any"
              end
            end
            column("Vibes") do |venue|
              if venue.vibes.present?
                venue.vibes.join(", ")
              else
                "Any"
              end
            end
            column("Verified") { |venue| status_tag venue.verified? ? "Yes" : "No" }
          end

          para "Total venues seeking music: #{venues_seeking_music.count}"
        else
          para "No venues are currently seeking new music."
        end
      rescue => e
        para "Error loading venues: #{e.message}"
      end
    end

    # Add custom styling
    div class: "venues-booking-style" do
      style do
        raw <<~CSS
          .venues-booking-section {
            padding: 20px;
          }
          .venues-booking-section .btn {
            display: inline-block;
            padding: 4px 8px;
            text-decoration: none;
            border-radius: 3px;
            color: white;
            background-color: #007cba;
            font-size: 12px;
          }
          .venues-booking-section .btn:hover {
            background-color: #005a8a;
          }
          .venues-booking-section table {
            margin-top: 15px;
          }
          .venues-booking-section td {
            vertical-align: top;
          }
        CSS
      end
    end
  end
end