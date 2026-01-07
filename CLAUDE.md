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

This is a macOS desktop application using **Clean Architecture** with modular SPM packages. Each module has its own `Package.swift` and corresponds to a directory at the project root.

### Layer Structure

| Directory | Layer | Purpose |
|-----------|-------|---------|
| `basenana/` | App | App entry point, DI container, environment config, share extensions |
| `Data/` | Data | NetworkCore (gRPC), NetworkExtension, Repository implementations |
| `Domain/` | Domain | Entities, AppState, UseCaseProtocol, UseCase, DomainTestHelpers |
| `Entry/` | UI | GroupTable (feed/group UI), WebPage (web scraping via Readability.js) |
| `Document/` | UI/Feature | Document reading and search functionality |
| `Notify/` | Feature | macOS notification handling |
| `Styleguide/` | Shared | Reusable SwiftUI components and styling |
| `Workflow/` | Feature | Business workflow management |

### Dependency Flow

Domain layer is independent. Data layer depends on Domain. Entry and other feature modules depend on Domain.

### Key Patterns

- **Dependency Injection**: `Container.swift` using Swinject and Factory property wrappers
- **State Management**: `AppState` in Domain layer
- **Repository Pattern**: Protocols in Domain, implementations in Data
- **Use Case Pattern**: Abstracted via `UseCaseProtocol`, concrete implementations in Domain

## Key Dependencies

- **Networking**: grpc-swift (gRPC client/server)
- **Feed Parsing**: FeedKit (RSS/Atom)
- **HTML Parsing**: SwiftSoup, Fuzi
- **Web Scraping**: Readability.js (bundled in WebPage module)
- **Logging**: SwiftyBeaver
- **UI**: SwiftUI, SwiftData (persistence), SwiftUIMasonry

## Testing

Each module has a corresponding `Tests/` directory using XCTest. Run tests in Xcode with `Cmd+U` or via `xcodebuild test`.
