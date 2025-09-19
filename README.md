# Musiportal Admin

A Rails-based admin interface for managing the Musiportal platform using Active Admin. This application provides a comprehensive dashboard for administrators to manage users, groups, events, venues, and all other data entities in the Musiportal ecosystem.

## Features

- **User Management**: View, edit, and manage user profiles, genres, vibes, and group memberships
- **Group Management**: Manage bands, venues, promoters, and festivals with detailed information
- **Event Management**: Oversee all events, concerts, and performances
- **Content Management**: Manage genres, vibes, and other categorization systems
- **Membership Management**: Track and manage group memberships and roles
- **Venue Management**: Maintain venue information and booking details
- **Festival Management**: Handle festival listings and associated events

## Technology Stack

- **Rails 7.2.2**: Main application framework
- **Active Admin 3.3.0**: Admin interface framework
- **Devise 4.9.4**: User authentication and management
- **PostgreSQL**: Database (shared with musiportal_api)
- **Stimulus & Turbo**: Modern JavaScript framework integration

## Setup Instructions

### Prerequisites

- Ruby 3.1.0 or later
- PostgreSQL
- Bundler

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd musiportal_admin
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Database setup**
   ```bash
   # The app is configured to use the same database as musiportal_api
   bundle exec rails db:migrate
   bundle exec rails db:seed
   ```

4. **Start the server**
   ```bash
   bundle exec rails server -p 3001
   ```

5. **Access the admin interface**
   - Navigate to `http://localhost:3001`
   - Login with the default admin credentials:
     - Email: `admin@example.com`
     - Password: `password`

## Configuration

### Database Connection

The application is configured to connect to the same PostgreSQL database as `musiportal_api`:
- Development database: `musiportal_api_development`
- All models are shared between the API and admin applications

### Admin Resources

Active Admin resources are configured for all major models:

- **Users**: Complete user management with profile details, groups, and events
- **Groups**: Band, venue, promoter, and festival management
- **Events**: Event creation, editing, and management
- **Memberships**: Group membership and role management
- **Venues**: Venue information and contact details
- **Genres & Vibes**: Category management for music classification

### Security

- Admin authentication is handled by Devise
- Strong parameter filtering is implemented for all resources
- Admin users are separate from regular platform users

## Admin Interface Features

### Dashboard
- Overview of key metrics and recent activity
- Quick access to all management sections

### User Management
- View all registered users
- Edit user profiles and contact information
- Manage user roles and permissions
- View user's groups and events
- Filter and search capabilities

### Group Management
- Manage all types of groups (bands, venues, promoters, festivals)
- Edit group profiles and descriptions
- View group members and their roles
- Manage group verification status
- Handle group categories (genres and vibes)

### Event Management
- Create and edit events
- Manage event details and scheduling
- Associate events with groups and venues
- Track event types and categories

### Content Management
- Manage music genres and classifications
- Handle "vibes" categorization system
- Control verification and featured content

## Development

### Adding New Admin Resources

To add a new model to the admin interface:

1. Generate the Active Admin resource:
   ```bash
   bundle exec rails generate active_admin:resource ModelName
   ```

2. Customize the resource file in `app/admin/model_names.rb`:
   - Define permitted parameters
   - Configure index, show, and form displays
   - Add filters and search capabilities

### Customization

Active Admin resources can be customized by modifying files in `app/admin/`. Each resource file allows you to:

- Define which parameters can be edited
- Customize the index page layout
- Configure detailed show pages
- Create custom forms
- Add filters and search
- Implement custom actions

## Deployment

The application is designed to be deployed alongside the main API:

1. Ensure PostgreSQL database access
2. Set environment variables for production
3. Run migrations: `bundle exec rails db:migrate`
4. Precompile assets: `bundle exec rails assets:precompile`
5. Start the server on the designated port

## API Integration

This admin interface operates on the same database as `musiportal_api`, providing:

- Real-time data management
- Immediate reflection of changes in the mobile app
- Centralized content management
- Comprehensive oversight of platform activity

## Support and Maintenance

### Regular Tasks
- Monitor user activity and registrations
- Verify group information and authenticity
- Manage content categories and classifications
- Review and approve featured content
- Handle user support requests

### Backup and Recovery
- Database backups are handled at the infrastructure level
- Admin user accounts should be backed up separately
- Configuration files should be version controlled

## License

This application is part of the Musiportal platform ecosystem.