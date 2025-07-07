# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a R Shiny web application for visualizing nephropathy (kidney disease) data from OpenSearch. The application features user authentication, an image-based navigation interface, and interactive data tables.

## Common Development Commands

### Running the Application
```r
# Install dependencies (if not already installed)
install.packages(c("shiny", "DT", "shinymanager", "data.table"))

# Run the application locally
shiny::runApp("app.R")
```

### Deployment to shinyapps.io
```r
# Set account info (credentials required)
rsconnect::setAccountInfo(name='yang-lab', token='YOUR_TOKEN', secret='YOUR_SECRET')

# Deploy the application
rsconnect::deployApp(".")
```

## Architecture and Code Structure

### Single-File Architecture
The entire application is contained in `app.R` following a standard Shiny pattern:
1. **Dependencies loading** - Libraries are loaded at the top
2. **Data preprocessing** - CSV files are loaded using `data.table::fread()`
3. **Authentication setup** - User credentials defined for `shinymanager`
4. **UI definition** - Dynamic UI based on authentication and navigation state
5. **Server logic** - Reactive values control page navigation and data display

### Key Components

#### Authentication Layer
- Uses `shinymanager::secure_app()` wrapper
- Two hardcoded users: `user01/password01` (regular) and `user02/password02` (admin)
- Credentials stored in-memory (not secure for production)

#### Navigation Flow
- **Home page**: 12 disease images in 3x4 grid (currently all using placeholder)
- **Data tables page**: 3 tabs showing different nephropathy datasets
- Navigation controlled by reactive value `rv$page` ("home" or "data")

#### Data Structure
Three datasets loaded from `all_data_kidney_disease_opensearch/`:
- `Nephropathy_MOD_Count_part.csv` - Modification counts by sample
- `Nephropathy_Scale_MOD_part.csv` - Scale modifications data
- `Nephropathy_Site_Count_part.csv` - Site-specific counts

Note: "_part" files contain first 1000 rows for faster loading during development.

### UI Implementation Details
- Custom CSS for responsive image grid with hover effects
- Bootstrap-based layout using Shiny's column system
- Statistics panels show total modifications and sample counts
- Tables rendered with `DT::datatable()` with 10-row pagination

## Development Considerations

### Current Limitations
1. All 12 images use the same placeholder (`www/image.jpg`)
2. Repetitive click handlers for images (could be refactored to use loops)
3. Statistics calculation shows identical values for all tables
4. No formal dependency management (no renv.lock or DESCRIPTION file)
5. Hardcoded authentication credentials

### File Organization
```
disease_openSearch/
├── app.R                                    # Main application
├── www/image.jpg                           # Placeholder image
├── all_data_kidney_disease_opensearch/     # Data directory
└── rsconnect/                              # Deployment configuration
```

### Performance Notes
- Full datasets exist but app uses partial versions (1000 rows) for performance
- Data loaded into memory at startup - consider lazy loading for larger datasets
- No caching implemented - each session loads data fresh

## Deployment URL
https://yang-lab.shinyapps.io/disease_opensearch/