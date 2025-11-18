# Testing Guide - Cinema Booking Apps

## Quick Test Commands

Open two terminals in VS Code (Terminal → New Terminal):

### Terminal 1 - Vendor App

```powershell
cd cinema_booking_vendor
flutter run -d chrome
```

### Terminal 2 - Customer App

```powershell
cd cinema_booking_customer
flutter run -d chrome
```

## Before First Run

### 1. Configure Firebase (Do this once)

```powershell
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Customer App
cd cinema_booking_customer
flutterfire configure --project=cinema-booking-demo

# Configure Vendor App
cd ../cinema_booking_vendor
flutterfire configure --project=cinema-booking-demo
```

This creates `lib/firebase_options.dart` in each app automatically.

### 2. Install Dependencies

```powershell
# In cinema_booking_customer folder
flutter pub get

# In cinema_booking_vendor folder
cd ../cinema_booking_vendor
flutter pub get
```

### 3. Enable Firestore & Auth in Firebase Console

1. Go to https://console.firebase.google.com
2. Select your project
3. **Firestore Database** → Create database → Start in **test mode**
4. **Authentication** → Get Started → **Email/Password** → Enable

## Testing Workflow

### Step 1: Run Vendor App

```powershell
cd cinema_booking_vendor
flutter run -d chrome
```

Add a movie:

- Title: `Avengers Endgame`
- Description: `Epic superhero movie`
- Time: `18:00`
- Click "Add Movie"

### Step 2: Run Customer App

```powershell
cd cinema_booking_customer
flutter run -d chrome
```

Register & Login:

- Email: `user1@test.com`
- Password: `test123`
- Click "Register"
- Login with same credentials

### Step 3: Book Seats

- Click on the movie you added
- Select a time slot
- Click on 2-3 seats (they turn green)
- Click "Book X seats" button
- Should see success message

### Step 4: Test Real-time Updates

- Go back to Vendor App
- See the booked seat count increase
- Click the movie to see which seats are booked (grey)

### Step 5: Test Multiple Users

In Customer App:

- Logout (may need to add logout button or restart app)
- Register new user: `user2@test.com` / `test123`
- Try to book same seats → Should fail
- Book different seats → Should succeed

## Available Devices

Check available devices:

```powershell
flutter devices
```

Common options:

- `chrome` - Web browser (easiest for testing)
- `windows` - Windows desktop app
- Android emulator (if installed)
- Connected physical device

## VS Code Testing (GUI Method)

1. Open either app folder in VS Code
2. Press `F5` or click "Run" → "Start Debugging"
3. Select device from dropdown
4. App launches automatically

## Useful Commands

```powershell
# Check Flutter installation
flutter doctor

# Clear cache if issues
flutter clean
flutter pub get

# Enable web support
flutter config --enable-web

# Update dependencies
flutter pub upgrade

# View Firebase config
flutterfire configure --help
```

## Expected Results

✅ Vendor can add/delete movies  
✅ Customer can register/login  
✅ Customer sees movies in real-time  
✅ Seat booking works atomically  
✅ Booked seats show as grey  
✅ Multiple users can't book same seat  
✅ Vendor sees real-time booking updates
