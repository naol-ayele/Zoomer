# Zoomer

**Handwriting-to-Digital Display Engine**

Zoomer is a high-performance Flutter application designed for real-time communication. It transforms handwritten input into bold, scrolling digital text, making it the perfect tool for communicating in loud environments, across distances, or for accessibility needs.

## Key Features

- ** AI Handwriting Recognition:** Integrated ML-powered engine that converts natural handwriting into digital text on the fly.
- ** Dynamic Color Engine:** Customize text and background colors with real-time preview.
- ** Quick-Word Grid:** A customizable "HoverGrid" for instant access to frequently used phrases like "YES", "NO", and "STOP".
- ** Scrolling Display:** Smooth, high-visibility scrolling text with adjustable speeds.
- ** Strobe Mode:** Integrated manual strobe control for high-attention signaling.
- ** Orientation Optimized:** Forced landscape layout to maximize drawing surface area and readability.

## Technical Stack

- **Framework:** Flutter (Dart)
- **AI/ML:** Google ML Kit (Digital Ink Recognition)
- **Persistence:** Local Storage Service for user-defined Quick-Words.
- **Architecture:** Modular widget structure with dedicated services for Ink and Storage.

## Getting Started

### Prerequisites

- Flutter SDK: `^3.0.0`
- Android/iOS device with touch support (for handwriting)

### Installation

1. **Clone the repo:**

```bash
git clone https://github.com/naol-ayele/zoomer.git

```

2. **Install dependencies:**

```bash
flutter pub get

```

3. **Run the app:**

```bash
flutter run

```

## Project Structure

- `lib/services/`: Core logic for handwriting recognition and data persistence.
- `lib/widgets/`: Reusable UI components including the `InkCanvas` and `ColorEngine`.
- `lib/models/`: Data structures for `QuickWord` and `InkCanvas` states.
- `lib/screens/`: High-level screens for input and the live display.
