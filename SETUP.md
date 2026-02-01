# 🚀 Quick Start Guide - Iron Log

## Running the App (Tomorrow Morning)

### Option 1: iOS Simulator (Easiest)

1. **Open Terminal** and navigate to the project:
   ```bash
   cd ~/xenwork/iron_log
   ```

2. **Start iOS Simulator**:
   ```bash
   open -a Simulator
   ```

3. **Run the app**:
   ```bash
   export PATH="$HOME/flutter/bin:$PATH"
   flutter run
   ```

   The app will build and launch in the simulator!

---

### Option 2: Physical iPhone (Recommended for Real Use)

1. **Connect your iPhone** via USB

2. **Trust the computer** on your iPhone (popup will appear)

3. **Open Xcode** (if you have it installed):
   ```bash
   open ios/Runner.xcworkspace
   ```

4. **Sign the app**:
   - Click on "Runner" in the project navigator (left panel)
   - Go to "Signing & Capabilities" tab
   - Select your Apple ID under "Team"
   - Xcode will automatically create a provisioning profile

5. **Run from terminal**:
   ```bash
   cd ~/xenwork/iron_log
   export PATH="$HOME/flutter/bin:$PATH"
   flutter run
   ```

6. **Trust the developer on iPhone**:
   - Settings → General → VPN & Device Management
   - Tap your developer email
   - Tap "Trust"

---

## Troubleshooting

### "Flutter not found"
```bash
export PATH="$HOME/flutter/bin:$PATH"
```

### "No devices found"
- **Simulator**: Run `open -a Simulator` first
- **Physical device**: Make sure iPhone is unlocked and trusted

### "Xcode not found"
You'll need Xcode from the Mac App Store to run on iOS (free download, ~12GB)

### "Build failed"
```bash
cd ~/xenwork/iron_log
flutter clean
flutter pub get
flutter run
```

---

## Testing the App

### Quick Test Flow:

1. **Log a workout**:
   - Tap + button
   - Enter "Bench Press"
   - Add 3 sets: 10 reps × 60kg, 8 reps × 70kg, 6 reps × 80kg
   - Tap Save

2. **View history**:
   - Switch to History tab
   - Tap on today's workout
   - See your exercises

3. **See progression**:
   - Tap on "Bench Press"
   - See the chart (will show single data point)
   - Log more workouts to see progression over time!

---

## GitHub Repo

**URL:** https://github.com/aashishd/iron-log (private)

**Cloning on another machine:**
```bash
git clone https://github.com/aashishd/iron-log.git
cd iron-log
flutter pub get
flutter run
```

---

## What's Next (Optional Enhancements)

**Easy additions:**
- [ ] Rest timer between sets
- [ ] Notes per workout
- [ ] Personal records (PR) tracking
- [ ] Body weight logging
- [ ] Export data to CSV

**Medium complexity:**
- [ ] Workout templates
- [ ] Exercise library with images
- [ ] Dark mode
- [ ] Multiple weight units (kg/lbs toggle)

**Advanced:**
- [ ] Apple Health integration
- [ ] Apple Watch companion app
- [ ] iCloud sync (optional backup)

---

## App Info

**Name:** Iron Log 🏋️  
**Bundle ID:** com.ashish.ironlog  
**Repo:** https://github.com/aashishd/iron-log  
**Built with:** Flutter 3.38.9, SQLite (sqflite), fl_chart  

**Theme:**
- Pastel purple primary (#D4BAFF)
- Pastel blue secondary (#BAE1FF)
- Soft gray backgrounds (#F5F5F5)
- Minimalist Material Design 3

---

**Enjoy tracking your gains! 💪**

Let me know if you want any changes or new features!

— Xen 🔮
