CycleSync — PCOS Tracker Mobile App

A modern Flutter-based PCOS tracking application designed to help women monitor symptoms, menstrual cycles, medications, hydration, lifestyle habits, and hormonal wellness in one elegant platform.

Built with:

Flutter
Supabase
Riverpod / Provider
Clean Architecture
Material Design 3
🌸 Overview

CycleSync is a feminine wellness-focused mobile application that empowers users with PCOS (Polycystic Ovary Syndrome) to:

Track menstrual cycles
Monitor symptoms
Log medications & supplements
Analyze mood and lifestyle patterns
Receive personalized insights
Build healthier routines

The app is designed with a soft, calming UI aesthetic using:

DeepPurpleAccent
Soft pink gradients
Wellness-inspired blue accents
✨ Features
Authentication
Email & password login
Registration
Forgot password
Supabase Auth integration
Cycle Tracking
Period logging
Flow intensity tracking
Ovulation estimation
Calendar visualization
Symptom Tracking
Acne
Fatigue
Mood swings
Hair growth/loss
Bloating
Anxiety tracking
Lifestyle Tracking
Water intake
Sleep tracking
Exercise logs
Weight tracking
BMI calculations
Medication Management
Medication reminders
Supplement schedules
Dosage tracking
Insights & Analytics
Mood trends
Symptom charts
Weight progress
Cycle consistency analysis
🎨 UI/UX Inspiration

The design direction is inspired by modern feminine wellness applications and PCOS-focused health experiences.

References:

Figma Make PCOS Tracker UI Concept
Lunari Period Tracker UI Kit
Glow — The PCOS Companion UX Case Study
Chime Health Tracker UI Kit

The UI emphasizes:

emotional comfort
low-stress interaction
soft gradients
rounded cards
wellness-first layouts
modern typography
🧠 Community Research

Common frustrations with existing PCOS apps include:

inaccurate cycle predictions
poor support for irregular periods
lack of PCOS-specific insights
limited symptom customization
insensitive fertility notifications

These insights heavily influenced the MVP feature planning.

Reddit

•

r/PCOS

›

all my cycle/fertility tracking apps don’t take PCOS & it’s treatment into account, resulting in vague and inaccurate predictions

Reddit

•

r/PcosIndia

›

existing apps are bad at tracking irregular cycles or even irregular flow same day and don't have a good way to log non-standard symptoms like hair loss or acne

Reddit

•

r/womenintech

›

I’m so tired of period tracking apps that don’t really work for PCOS

Give feedback
🏗️ Project Architecture
lib/
├── core/
├── shared/
├── features/
├── routes/
└── dependency_injection/

Architecture style:

Clean Architecture
Feature-first structure
Scalable modular architecture
Service abstraction
Dependency injection
📁 Core Structure
Core

Contains:

constants
theme
services
network
utilities
errors
Shared

Reusable:

widgets
models
providers
Features

Each feature contains:

presentation
providers
data
domain
🚀 Tech Stack
Technology	Usage
Flutter	Frontend
Supabase	Backend
PostgreSQL	Database
Riverpod	State Management
GoRouter	Navigation
GetIt	Dependency Injection
Hive	Local Storage
Dio	Networking
FCM	Push Notifications
🔐 Supabase Setup
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
📦 Recommended Packages
dependencies:
  flutter:
    sdk: flutter

  supabase_flutter: ^2.5.6
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  get_it: ^7.7.0
  dio: ^5.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  fl_chart: ^0.68.0
  table_calendar: ^3.1.2
  connectivity_plus: ^6.0.3
  flutter_local_notifications: ^17.1.2
🎨 Theme

CycleSync uses:

Deep Purple Accent
Soft Pink
Wellness Blue
Rounded cards
Soft gradients
Material 3 styling

Typography:

Poppins
📱 Planned Screens
Splash Screen
Login/Register
Onboarding
Dashboard
Cycle Calendar
Symptom Logger
Medication Tracker
Water Tracker
Insights Dashboard
Profile & Settings
🔮 Future Roadmap
Version 1.1
Advanced analytics
Better prediction engine
Doctor report export
Version 1.2
AI insights
Meal planner
Smart recommendations
Version 2.0
Wearable integration
Telemedicine
PCOS community support
Hormonal health AI assistant
📊 MVP Goals

The MVP aims to validate:

user engagement
retention through reminders
demand for PCOS-specific health tracking
personalized health insights
💖 Design Philosophy

CycleSync is designed to feel:

comforting
feminine
calming
premium
emotionally safe
medically useful

Unlike traditional period trackers, the focus is specifically on irregular cycles, hormonal wellness, and PCOS symptom management.

🛠️ Getting Started
Install dependencies
flutter pub get
Run app
flutter run
Generate launcher icons
flutter pub run flutter_launcher_icons
📄 License

MIT License

👩‍💻 Developer Notes

Recommended next implementation order:

Authentication UI
Bottom Navigation
Dashboard UI
Cycle Tracking Logic
Symptom Logging
Supabase Integration
Notifications
Insights Charts
AI Recommendations
🌺 CycleSync

Track your cycle.
Understand your body.
Balance your health.