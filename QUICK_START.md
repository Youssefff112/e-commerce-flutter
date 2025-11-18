# 🎬 Quick Test Guide - Cinema Booking Apps

## ✅ What You Have

Two complete Flutter apps with **NO BACKEND NEEDED**:

- ✨ Professional UI with Material 3 design
- 🎯 All features working with mock data
- 🔐 Local authentication (frontend only)
- 🎫 47-seat booking system

## 🚀 How to Run (VS Code)

### Option 1: Press F5 (Easiest)

1. Open either app folder in VS Code:

   - `cinema_booking_vendor` or
   - `cinema_booking_customer`

2. Press `F5` or click Run → Start Debugging

3. Select device:

   - **Chrome** (or Brave)
   - Windows Desktop
   - Or any connected device

4. App launches automatically!

### Option 2: Command Palette

1. Press `Ctrl+Shift+P`
2. Type: "Flutter: Select Device"
3. Choose "Chrome (web-javascript)"
4. Press `Ctrl+Shift+P` again
5. Type: "Flutter: Run Flutter"

### Option 3: Terminal (if Flutter in PATH)

```powershell
# Vendor App
cd cinema_booking_vendor
flutter run -d chrome

# Customer App (new terminal)
cd cinema_booking_customer
flutter run -d chrome
```

## 📋 Test Scenario

### 1️⃣ Vendor App

- Click "Add Movie"
- Enter: Title, Description
- Set time slots (defaults provided)
- Click image buttons to pick image
- Submit
- See movie appear in right panel with booking count

### 2️⃣ Customer App

- Register: email `test@test.com`, password `test123`
- See movies list
- Search for movie by title
- Click movie card
- Select time slot
- Click seats (turn green when selected)
- Click "Book X Seats" button
- Success! Seats turn grey (booked)

### 3️⃣ Real-time Test

- Keep both apps open
- Book seats in Customer App
- Watch booking count update in Vendor App instantly
- Vendor can view which seats are booked

## 🎨 UI Features You'll See

**Customer App:**

- Beautiful gradient login screen
- Movie cards with booking stats
- Search bar for finding movies
- Professional seat selection grid
- Color legend (white/green/grey)
- "SCREEN" indicator above seats

**Vendor App:**

- Split-panel dashboard design
- Purple theme (vs Customer's blue)
- Real-time booking statistics
- Delete confirmation dialogs
- Seat grid visualization
- Image picker buttons

## 💡 About Authentication

**Question:** Is authentication frontend or backend in Flutter?

**Answer:** It depends on implementation:

1. **Firebase Auth** (Backend):

   - Uses Firebase servers
   - Real user accounts
   - Requires internet

2. **Local Auth** (Frontend - What I implemented):
   - Uses `SharedPreferences` (local storage)
   - Data stored on device
   - No internet needed
   - Perfect for demos/testing

For this project: **Frontend-only** - No Firebase, no backend servers needed!

## 🔧 If Flutter Extensions Not Working

1. Install extensions manually:

   - Search "Flutter" in Extensions panel
   - Install "Flutter" by Dart Code
   - Install "Dart" by Dart Code

2. Restart VS Code

3. Open Command Palette (`Ctrl+Shift+P`)

4. Type: "Flutter: Run Flutter Doctor"

## ✨ What Makes It Professional

- ✅ Clean Material 3 UI
- ✅ Form validation
- ✅ Loading states
- ✅ Success/error messages
- ✅ Confirmation dialogs
- ✅ Responsive layout
- ✅ Color-coded feedback
- ✅ Proper navigation
- ✅ Logout functionality
- ✅ Real-time updates

## 🎯 Ready to Test!

Just press **F5** in VS Code and select Chrome (or Brave). No configuration needed!
