Cinema Booking Flutter (Vendor + Customer)

## Overview

- Two Flutter apps: `cinema_booking_vendor` and `cinema_booking_customer`.
- **Frontend-only with mock data** - No backend setup required!
- Authentication uses local storage (SharedPreferences)
- Data is shared in memory between app instances

## Setup Instructions

### Prerequisites

1. **Flutter SDK** - Install from https://flutter.dev/docs/get-started/install
2. **Windows Desktop Development** - Run `flutter config --enable-windows-desktop`
3. Check installation: `flutter doctor`

### Installation Steps

After cloning this repository:

```powershell
# Customer App
cd cinema_booking_customer
flutter pub get

# Vendor App
cd ..\cinema_booking_vendor
flutter pub get
```

### Running the Apps

**Using Terminal (Windows Desktop)**

```powershell
# Run Vendor App
cd cinema_booking_vendor
flutter run -d windows

# Run Customer App (in another terminal)
cd cinema_booking_customer
flutter run -d windows
```

**Using VS Code**

1. Open the workspace folder in VS Code
2. Press `F5` or click "Run and Debug"
3. Select Windows (windows-x64)
4. Choose which app to run

## 🧪 Testing Scenario

1. **Start Vendor App**

   - Add a movie with title, description, and 3 time slots
   - Optionally add an image from gallery/camera
   - Leave app open

2. **Start Customer App**

   - Register a new account (email: user@test.com, password: 123456)
   - Login with credentials
   - Browse movies and click on one
   - Select time slot and seats (4-gap-5 layout)
   - Click "Book Seats"

3. **Check Vendor App**

   - Click "View" on the movie
   - Switch between time slots to see different bookings
   - Each time slot shows its own seat occupancy

4. **Check Customer Bookings**
   - In Customer app, click the receipt icon (top right)
   - View booking history with all details

## Features Implemented

### Customer App

- ✅ Register / Login (Email + Password)
- ✅ List movies (latest first)
- ✅ Movie details with seat selection (47 seats: rows 1-4 with 4-gap-5 pattern, row 5 with 11 seats)
- ✅ Real-time seat availability using MockDataService streams
- ✅ In-memory booking system with instant updates
- ✅ Multiple time slots per movie
- ✅ Booking history page showing past bookings with timestamps

### Vendor App

- ✅ Add / Delete movie (title, desc, time slots)
- ✅ View bookings per movie with clickable time slot tabs
- ✅ Real-time booking count updates
- ✅ Image picker support (gallery/camera)
- ✅ Search functionality
- ✅ No authentication required

## Troubleshooting

**Build errors:**

- Run `flutter clean ; flutter pub get`
- Check Flutter version: `flutter doctor`

**App not launching:**

- Ensure Windows desktop development is enabled
- Run `flutter config --enable-windows-desktop`

**Real-time updates not working:**

- Both apps share the same MockDataService singleton
- Restart both apps to reset data
