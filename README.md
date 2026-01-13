# iOS Movie App

A simple iOS app for searching and viewing movie details using The Movie Database (TMDB) API.

## Features

- **Discover**: Browse "Now Playing" and "Popular" movies.
- **Search**: Search for movies by title.
- **Details**: View movie overview, release date, rating, and cast.
- **Favorites**: Save movies to a local favorites list.
- **Offline Mode**: Cache support allows viewing previously loaded content without an internet connection.
- **Dark Mode**: Modern dark-themed UI.

## Requirements

- iOS 16.0+
- Xcode 14.0+
- API Key from [The Movie Database](https://www.themoviedb.org/documentation/api)

## Setup

1.  Clone the repository.
2.  Open `iOSMovieApp.xcodeproj`.
3.  Set your TMDB API Key in `Config.xcconfig`:
    ```xcconfig
    TMDB_API_KEY = your_api_key_here
    ```
4.  Build and Run.

## Architecture

The app uses **MVVM (Model-View-ViewModel)** architecture with **SwiftUI**.
- **Views**: SwiftUI views for UI rendering.
- **ViewModels**: Handle business logic and state management.
- **Services**: `TMDBClient` for networking.
- **Persistence**: Core Data for caching and favorites storage.

## Libraries

- **Netfox**: Network debugging (enabled in Debug builds).
- **Kingfisher** (Optional/Reference): Replaced with custom `CachedImageView` for dependency minimization or learning purposes.
