
# 🌿 PlantHub

## System Architecture

```mermaid
flowchart LR
    A["📱 Flutter App"] --> B["State Management"]
    B --> C["Firebase Services"]
    B --> D["Gemini AI"]

    C --> E["Authentication"]
    C --> F["Cloud Firestore"]
    C --> G["Firebase Storage"]

    D --> H["Plant Disease Detection"]
    D --> I["AI Plant Assistant"]

    style A fill:#087f5b,color:#fff,stroke:#34d399
    style B fill:#1e3a5f,color:#fff,stroke:#60a5fa
    style C fill:#4338ca,color:#fff,stroke:#a5b4fc
    style D fill:#7e22ce,color:#fff,stroke:#d8b4fe
```

## About PlantHub

PlantHub is a plant care application designed to help users
manage their plants, identify plant diseases, and get AI-powered
assistance for plant care.

## Tech Stack

- **Flutter & Dart** — Mobile application
- **Provider / BLoC** — State management
- **Firebase** — Authentication and data services
- **Cloud Firestore** — Database
- **Firebase Storage** — File and image storage
- **Gemini AI** — AI-powered plant assistance
