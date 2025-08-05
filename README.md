# 💱 Currency Converter

---

## Table of Contents

- Overview
- Product Spec
- Wireframes
- Schema

---

## Overview

### Description

Currency Converter is a simple and lightweight mobile app that allows users to convert between currencies in real-time using up-to-date exchange rates. It's built for students, travelers, freelancers, and online shoppers who frequently deal with different currencies. With a clean interface, real-time API integration, and instant conversion, the app ensures accurate results within seconds.

### App Evaluation

- **Category:** Utility / Finance
- **Mobile:** Real-time currency API, responsive dropdowns, and conversion logic optimized for mobile
- **Story:** Helps users check conversions instantly when traveling or shopping internationally
- **Market:** Useful for students, travelers, freelancers, business people, and global shoppers
- **Habit:** Occasionally used but highly valuable during international travel or currency comparison
- **Scope:** MVP is very achievable — simple dropdowns + real-time conversion; can expand with favorites, history, and graphs later

---

## Product Spec

### 1. User Stories

#### Required Must-have Stories

- [x] User can select a base currency and a target currency from dropdown menus
- [x] User can enter an amount to convert
- [x] User sees the converted result in real-time
- [x] App fetches current exchange rates via a free public API
- [x] Basic UI layout is responsive and styled for mobile

#### Optional Nice-to-have Stories

- [x] User can tap a button to swap the base and target currencies
- [x] User can view flags next to currency codes
- [x] App includes light/dark mode toggle
- [x] User can view their previous activtiy

---

### 2. Screen Archetypes

- **Home / Conversion Screen**
  - Currency selection dropdowns
  - Input field for amount
  - Button to convert or live updating result
  - Label showing exchange rate

- **Optional: Settings Screen**
  - Dark mode toggle
  - Manage saved pairs

- **Optional: Favorites Screen**
  - List of saved currency pairs
  - Quick convert with one tap
  - Currency exchange rates

---

### 3. Navigation

#### Tab Navigation (optional if you add more screens):

- Conversion
- History

#### Flow Navigation (Screen to Screen):

- Home → History
- Home → Live Rate
- Home → Conversion Result

---



