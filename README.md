
## 🌿 PlantHub — Application Overview

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Mobile%20App-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Firebase-Backend%20Services-FFCA28?logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Gemini-AI%20Assistant-8E75B2?logo=googlegemini&logoColor=white" alt="Gemini AI"/>
</p>

```mermaid
flowchart TD
    U([User]) --> APP[PlantHub Mobile App]

    APP --> AUTH[Authentication]
    APP --> PLANTS[Plant Library & My Plants]
    APP --> DIAG[Plant Disease Diagnosis]
    APP --> AI[AI Plant Assistant]
    APP --> SETTINGS[Profile & Settings]

    AUTH --> FB[Firebase Authentication]
    PLANTS --> DB[(Cloud Firestore)]
    DIAG --> GEMINI[Gemini AI]
    AI --> GEMINI
    SETTINGS --> FB

    style U fill:#166534,color:#fff,stroke:#4ade80
    style APP fill:#0f172a,color:#fff,stroke:#60a5fa
    style DIAG fill:#14532d,color:#fff,stroke:#4ade80
    style AI fill:#581c87,color:#fff,stroke:#c084fc
    style DB fill:#164e63,color:#fff,stroke:#22d3ee
```

### About the Project

PlantHub is a Flutter application that helps users manage plants, explore plant care information, identify potential plant diseases, and access AI-powered assistance.

### Core Technologies

- **Flutter & Dart:** Mobile application development.
- **Firebase:** Authentication and cloud services.
- **Cloud Firestore:** Data storage.
- **Gemini AI:** AI-powered plant assistance and diagnosis.
