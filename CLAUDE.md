# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Open in Xcode
open basenana.xcodeproj

# Build from command line
xcodebuild -project basenana.xcodeproj -scheme basenana -configuration Debug build

# Run tests
xcodebuild test -project basenana.xcodeproj -scheme basenana
```

## Architecture

This is a macOS desktop application using **Clean Architecture** with a unified Swift Package Manager setup.

### Project Structure

```
basenana/
├── Sources/                    # Source root
│   ├── Domain/                 # Domain layer (independent)
│   ├── Data/                   # Data layer (depends on Domain)
│   ├── Feature/                # Feature layer (depends on Domain, Data, Styleguide)
│   └── Styleguide/             # Styleguide layer (independent)
├── Tests/                      # Test directory
│   ├── DomainTests/
│   ├── DataTests/
│   ├── FeatureTests/
│   └── StyleguideTests/
├── basenana/                   # App layer (executable app)
│   ├── basenanaApp.swift       # App entry point
│   ├── DI/                     # Dependency injection container
│   ├── Environment/            # Environment configuration
│   ├── macOS/                  # macOS UI
│   └── Share/                  # Share extension
├── basenana-exec/              # Executable entry
│   └── main.swift
└── Package.swift               # SPM configuration
```

### Layer Structure

| Directory | Layer | Purpose |
|-----------|-------|---------|
| `basenana/` | App | App entry point, DI container, environment config, share extensions |
| `Sources/Domain/` | Domain | Entities, AppState, Repository protocols, UseCases |
| `Sources/Data/` | Data | Network clients, REST API, Repository implementations |
| `Sources/Feature/Entry/` | Feature | GroupTable (feed/group UI), WebPage (Readability.js) |
| `Sources/Feature/Document/` | Feature | Document reading, search, masonry layout |
| `Sources/Feature/Workflow/` | Feature | Business workflow management |
| `Sources/Styleguide/` | Shared | Reusable SwiftUI components and styling |

### Dependency Flow

- **basenana** (Executable) → **BasenanaApp** (App Layer)
- **Feature** depends on **Domain**, **Data**, **Styleguide**
- **Data** depends on **Domain**
- **Styleguide** is independent

### Key Patterns

- **Dependency Injection**: `Container.swift` using Swinject and Factory property wrappers
- **State Management**: `AppState` in Domain layer (`Sources/Domain/AppState/`)
- **Repository Pattern**: Protocols in Domain (`Sources/Domain/RepositoryProtocol/`), implementations in Data (`Sources/Data/Repositories/`)
- **Use Case Pattern**: Abstracted via `UseCaseProtocol`, concrete implementations in Domain (`Sources/Domain/UseCases/`)

## Key Dependencies

- **Feed Parsing**: FeedKit (RSS/Atom)
- **HTML Parsing**: SwiftSoup, Fuzi
- **Web Scraping**: Readability.js (bundled in WebPage module)
- **Logging**: SwiftyBeaver
- **DI**: Swinject, Factory
- **UI**: SwiftUI, SwiftData, SwiftUIMasonry

## Testing

Each module has a corresponding `Tests/` directory using XCTest. Run tests in Xcode with `Cmd+U` or via `xcodebuild test`.
