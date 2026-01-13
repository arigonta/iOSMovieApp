# Project Write-up

## Architecture Decisions

I chose the **MVVM (Model-View-ViewModel)** pattern for this application to cleanly separate UI logic from business logic. This makes the code more testable and maintainable.

### Key Components:
- **SwiftUI**: Used for a completely declarative UI, enabling rapid development and a modern look and feel.
- **Combine**: Used for reactive data binding between ViewModels and Views, particularly for search text debouncing.
- **Core Data**: Chosen for persistence (Favorites and Caching) because of its robustness and built-in support in iOS.
- **Actors/Concurrency**: Swift's modern `async/await` is used throughout the networking layer for readable asynchronous code.

## Challenges & Solutions

### 1. Offline Mode
**Challenge**: Ensuring the app remains functional without an internet connection.
**Solution**: I implemented a `CacheStoreProtocol` with a `CoreData` backing. Network requests in `SearchViewModel` fall back to this cache if they fail. Categories like "Now Playing" are cached with special keys.

### 2. Favorites Synchronization
**Challenge**: Keeping the "favorite" heart icon in sync between the Home screen, Search results, and Favorites tab.
**Solution**: I implemented a singleton pattern for `FavoritesStore` (`FavoritesStore.shared`) and ensured all ViewModels observe the same data source. This guarantees that a change in one screen is immediately reflected in others.

### 3. Image Caching
**Challenge**: Loading images efficiently without re-downloading them.
**Solution**: Implemented a custom `ImageCache` using `NSCache` to store downloaded images in memory, reducing processing power and data usage.

## Bonus Implementations
- **Pagination**: Implemented in search results to load more movies as the user scrolls.
- **Favorites**: Full favorites management with Core Data persistence.
- **Offline Mode**: Comprehensive caching for search results and home dashboard.
- **Unit Tests**: Added basic tests to verify ViewModel logic.
