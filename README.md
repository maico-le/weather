# ☀️ Weather Glow (Atmosphere)

<p align="center">
  <img src="assets/icons/app_banner.png" alt="Weather Glow Banner" width="100%" />
</p>

<p align="center">
  <img src="assets/icons/app_icon.png" alt="Weather Glow App Icon" width="120" style="border-radius: 26px; box-shadow: 0 10px 30px rgba(0,0,0,0.4);" />
</p>

<p align="center">
  <b>Next-generation weather application featuring real-time vector animations, frosted glassmorphism UI, and AI-powered lifestyle & outfit advice.</b>
</p>

<p align="center">
  <a href="https://github.com/maico-le/weather/releases/latest">
    <img src="https://img.shields.io/badge/Download-Android%20APK%20(Direct)-00C853?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" />
  </a>
  <a href="https://github.com/maico-le/weather/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/maico-le/weather/release.yml?style=for-the-badge&label=Build%20Status" alt="Build Status" />
  </a>
  <a href="https://github.com/maico-le/weather/releases">
    <img src="https://img.shields.io/github/v/release/maico-le/weather?style=for-the-badge&color=blue" alt="Latest Version" />
  </a>
</p>

---

## 🌟 Key Features & Highlights

### 1. 🤖 AI Weather & Smart Outfit Advisor
- **Google Gemini 2.5 Flash Powered**: Connected to the unified [Maico Le Gateway](https://maico-le-server.vercel.app/) built in Go.
- **Context-Aware Lifestyle Advice**: Analyzes real-time temperature, humidity, UV index, and rain probability to suggest the ideal outfit, skincare protection (SPF 50+), hydration tips, and best outdoor hours.
- **Dual-Layer Fallback**: Seamlessly falls back to an intelligent local rule engine if network connectivity is intermittent.

### 2. 🌌 Interactive Dynamic Sky & Particle Engine
- **Touch & Gesture Interaction (Celestial Ripple)**: Tap and drag across the sky to generate responsive light ripples and atmospheric wind flows.
- **Atmospheric Floating Particles**: 25 ambient atmospheric dust particles drifting gracefully in real-time calculated by hardware-accelerated Custom Canvas shaders.
- **Smooth 60/120 FPS Vector Animations**: Lottie & vector scenes smoothly responding to sunny, cloudy, rainy, thunderous, or twilight night conditions.

### 3. 🎨 Dynamic Frosted Glassmorphism UI
- **Multi-layer Blur & Edge Highlights**: Elegant translucent frosted glass surfaces designed with modern Apple iOS / visionOS aesthetics.
- **Adaptive Natural Palette**:
  - 🌅 **Clear Sunny**: Jade azure blending into amber sunlight.
  - 🌧️ **Rain & Overcast**: Deep quartz slate with calming indigo undertones.
  - ⚡ **Thunderstorm**: Electrifying deep purple twilight.
  - 🌙 **Serene Night**: Peaceful midnight ocean navy.

### 4. 🔔 Multi-Session Local Weather Notifications
- **Configurable Daily Notification Intervals**:
  - 🌤️ **Morning (07:00)**: Wake-up summary, rain warnings, and outfit recommendations before heading out.
  - ☀️ **Noon (12:00)**: Peak UV index alerts, heat protection, and hydration reminders.
  - 🌙 **Evening (18:00)**: Evening forecast, ambient temperature, and night activity planning.
- **Instant Test Notification**: Test sound, vibration, and banner previews with a single tap from the settings screen.

### 5. 🚨 Real-Time Extreme Weather Alerts
- Proactive meteorological hazard detection:
  - ⚠️ **Hazardous UV Index (≥ 8)**: Warning against direct sunburn and eye strain.
  - 🔥 **Extreme Heat (≥ 35°C)**: Heat exhaustion protection guidelines.
  - ⚡ **Severe Thunderstorms & Gale (≥ 45 km/h)**: Safety and commuting precautions.

### 6. ⚡ Zero-Latency Offline-First Architecture
- **Instant Launch (0.01s)**: Snapshots the latest weather forecast and AI advice using persistent local cache. The app opens immediately without blank loading screens (Stale-While-Revalidate pattern).
- **One-Tap GPS Auto-Location**: Instant latitude/longitude reverse-geocoding via native device sensors.

---

## 📥 Download & Installation

Get the official release APK directly on your Android device:

👉 **[Download Latest Weather Glow APK](https://github.com/maico-le/weather/releases/latest)**

*Note: After downloading the `.apk` file, allow "Install from this source" in your Android security settings to complete installation.*

---

## 📱 Interface Architecture Preview

```
┌──────────────────────────────────────────────┐
│  📍 Ho Chi Minh City ▾        📡  🔍  ⚙️     │
│                                              │
│  ⚠️ EXTREME UV ALERT (Index: 9 / Very High)  │
│                                              │
│               ☀️ (Vector Animation)           │
│                                              │
│                    33°C                      │
│             Sunny & Hot Afternoon            │
│        Feels like 36° • High: 35° Low: 25°   │
│                                              │
│ ┌──────────────────────────────────────────┐ │
│ │ 🤖 AI WEATHER ADVISOR (Gemini 2.5 Flash) │ │
│ │ Wear lightweight cotton, apply SPF 50+   │ │
│ │ sunscreen, and carry a compact umbrella. │ │
│ └──────────────────────────────────────────┘ │
│                                              │
│ ┌──────────────────────────────────────────┐ │
│ │ HOURLY FORECAST                          │ │
│ │ Now        14:00    16:00    18:00       │ │
│ │   ☀️        ⛅       🌧️       🌤️         │ │
│ │   33°       32°      29°      28°        │ │
│ └──────────────────────────────────────────┘ │
│                                              │
│ ┌───────────────────┐  ┌───────────────────┐ │
│ │ 💧 HUMIDITY       │  │ 💨 WIND           │ │
│ │ 75%               │  │ 12 km/h NE        │ │
│ └───────────────────┘  └───────────────────┘ │
└──────────────────────────────────────────────┘
```

---

## 🗺️ Engineering Milestones

- [x] **Milestone 1**: Clean / Feature-First architecture, GitHub Actions automated APK release CI/CD.
- [x] **Milestone 2**: wttr.in JSON integration, custom models, and localized conditions.
- [x] **Milestone 3**: Premium Glassmorphism design, 60fps vector animations (Lottie & Custom Canvas), hourly & 3-day forecast.
- [x] **Milestone 4**: Interactive celestial sky touch ripples, floating atmospheric particles.
- [x] **Milestone 5**: Native GPS auto-location (Geolocator), home screen widget simulation.
- [x] **Milestone 6**: Intelligent extreme weather banners (Thunderstorm, UV, Heatwave, Gale).
- [x] **Milestone 7**: Golang serverless gateway with Gemini 2.5 Flash AI advice integration.
- [x] **Milestone 8**: Settings Screen with multi-session customizable local notifications.

---

## 🛠️ Technology Stack

- **Client App**: Flutter 3 (Dart 3, Material 3)
- **Backend Gateway**: Golang (Go 1.23, Vercel Serverless Functions)
- **AI Engine**: Google Gemini 2.5 Flash
- **Graphics & Motion**: Lottie Vector Animations, Custom Canvas Shaders
- **Persistence**: SharedPreferences (Zero-latency cache & settings)
- **Notifications**: Flutter Local Notifications (Core Library Desugared)
- **CI/CD Pipeline**: GitHub Actions Release Automations

---

<p align="center">
  Crafted with ❤️ by <b>Maico Le</b>
</p>
