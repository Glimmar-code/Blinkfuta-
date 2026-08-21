# Running Blink Locally

This project is a Flutter application that connects to a Supabase backend.

## Prerequisites

1.  **Flutter SDK**: Ensure you have Flutter installed on your machine (`flutter --version`).
2.  **Chrome**: To run as a "local host" web app, you need Google Chrome.

## Setup

The project requires a `.env` file in the root of the Flutter directory (`imported_flutter_project/Blink-main/`). I have already placed a copy there for you.

Ensure your `.env` contains:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## Running as Local Host (Web)

To run the app in your browser on `localhost`:

```bash
cd imported_flutter_project/Blink-main
flutter run -d chrome --dart-define=LOCAL_HOST=true
```

This will launch the app at `http://localhost:<port>` and point the Supabase URL to `http://localhost:54321` (default for local Supabase).

If you want to run on web but still connect to the **production** Supabase:
```bash
flutter run -d chrome
```

### Note on CORS (Supabase)
If you encounter issues with requests being blocked when running on `localhost`, ensure you have added `http://localhost:*` to your Supabase project's **Redirect URLs** and **CORS** allow-list in the Supabase Dashboard (under Settings -> Authentication).

## Over-The-Air (OTA) Updates

I have integrated **Shorebird** into the project. This allows you to push small code changes (patches) to your users instantly without them having to download a new version from the Play Store or App Store.

### Initial Setup
1. Install Shorebird CLI: `curl -LSs https://shorebird.dev/install | bash`
2. Initialize Shorebird in this project: `shorebird init`

### Pushing an Update
Instead of a standard build, use:
```bash
shorebird patch android
```
This will bundle your changes and push them to the Shorebird cloud. Your users will receive the update the next time they open the app.

## Running on Mobile Emulator

To run on an Android or iOS emulator:

```bash
cd imported_flutter_project/Blink-main
flutter run
```
