# RCBC ATM Go — Feature Documentation

**Version:** 1.0.0+1  
**Platform:** Android (Topwise hardware device)  
**Flutter SDK:** ^3.9.2  
**Last updated:** April 26, 2026

---

## Table of Contents

1. [App Overview](#app-overview)
2. [Architecture](#architecture)
3. [Routing](#routing)
4. [Feature: Splash Screen](#feature-splash-screen)
5. [Feature: Login](#feature-login)
6. [Feature: Main Menu](#feature-main-menu)
7. [Feature: Withdrawal Flow](#feature-withdrawal-flow)
   - [Amount Entry](#1-amount-entry)
   - [Summary](#2-summary)
   - [Card Entry](#3-card-entry)
   - [Card Confirmation](#4-card-confirmation)
   - [PIN Entry](#5-pin-entry)
   - [Processing](#6-processing)
   - [E-Receipt (Optional)](#7-e-receipt-optional)
   - [Receipt Screen](#8-receipt-screen)
8. [Feature: Printing](#feature-printing)
9. [Feature: Card Reader (Isolated Module)](#feature-card-reader-isolated-module)
10. [Animations](#animations)
11. [State Management](#state-management)
12. [Data Model](#data-model)
13. [Theme & Design System](#theme--design-system)
14. [Dependencies](#dependencies)
15. [Known Limitations / Placeholders](#known-limitations--placeholders)

---

## App Overview

RCBC ATM Go is a Flutter-based mobile ATM terminal application designed to run on Topwise POS/ATM hardware. It provides an operator-facing interface for ATM transactions, starting with cash withdrawal. The app communicates with the device's native printer and card reader hardware through Android platform channels.

---

## Architecture

```
lib/
├── main.dart                          # App entry point, BlocProviders
├── app.dart                           # GoRouter config, MaterialApp.router
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Color palette
│   │   └── app_strings.dart           # String constants (menu labels, keypad)
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 light theme
│   └── widgets/
│       └── numpad_key.dart            # Reusable styled keypad key widget
└── features/
    ├── auth/
    │   ├── splash_page.dart
    │   └── login_page.dart
    ├── transaction/
    │   ├── data/models/
    │   │   └── transaction_model.dart  # Freezed data model
    │   ├── presentation/cubits/
    │   │   ├── transaction_cubit.dart
    │   │   └── transaction_state.dart
    │   ├── menu_page.dart
    │   ├── withdrawal_amount_page.dart
    │   ├── withdrawal_summary_page.dart
    │   ├── card_entry_page.dart
    │   ├── card_confirmation_page.dart
    │   ├── pin_entry_page.dart
    │   ├── processing_page.dart
    │   ├── ereceipt_page.dart
    │   └── receipt_page.dart
    ├── printer/
    │   ├── data/
    │   │   └── printer_service.dart
    │   └── presentation/cubits/
    │       ├── printer_cubit.dart
    │       └── printer_state.dart
    └── card_reader/
        ├── data/
        │   └── card_reader_service.dart
        └── presentation/cubits/
            └── card_reader_cubit.dart
```

**State management:** Flutter BLoC (Cubit pattern)  
**Navigation:** GoRouter (declarative, URL-based)  
**DI:** Manual — `PrinterService` is instantiated in `main.dart` and passed into `PrinterCubit` via constructor

---

## Routing

All routes are defined in `lib/app.dart`. The app starts at `/splash`.

| Route | Name | Screen |
|---|---|---|
| `/splash` | `splash` | `SplashPage` |
| `/login` | `login` | `LoginPage` |
| `/menu` | `menu` | `MenuPage` |
| `/withdraw/amount` | `withdraw-amount` | `WithdrawalAmountPage` |
| `/withdraw/summary` | `withdraw-summary` | `WithdrawalSummaryPage` |
| `/withdraw/card-entry` | `withdraw-card-entry` | `CardEntryPage` |
| `/withdraw/card-confirm` | `withdraw-card-confirm` | `CardConfirmPage` |
| `/withdraw/pin` | `withdraw-pin` | `PinEntryPage` |
| `/withdraw/processing` | `withdraw-processing` | `ProcessingPage` |
| `/withdraw/ereceipt` | `withdraw-ereceipt` | `EReceiptPage` |
| `/receipt` | `receipt` | `ReceiptPage` — requires `TransactionModel` passed via `extra` |

---

## Feature: Splash Screen

**File:** `lib/features/auth/splash_page.dart`  
**Status: Functional**

- Displays the ATM Go logo centered on screen with a `CircularProgressIndicator`
- Auto-navigates to `/login` after a **2.5-second** timer using `Future.delayed`
- No user interaction required

---

## Feature: Login

**File:** `lib/features/auth/login_page.dart`  
**Status: UI only — no authentication**

- Renders a username field and a password field
- Pressing **LOGIN** always navigates to `/menu` regardless of input
- No validation, no session handling, no backend call

---

## Feature: Main Menu

**File:** `lib/features/transaction/menu_page.dart`  
**Status: Functional for Withdraw only**

- Displays a product grid with labels sourced from `AppStrings`
- Shows a static terminal info card with hardcoded MID, TID, and network name
- **WITHDRAW** navigates to `/withdraw/amount`
- All other products (Cash In, Balance Inquiry, Fund Transfer, Bills Payment, etc.) show a **"Coming soon"** `SnackBar`
- **LOGOUT** navigates back to `/login`

---

## Feature: Withdrawal Flow

The withdrawal is a linear, 8-step flow. The entire flow is orchestrated by `TransactionCubit`, which holds state for each step.

### Transaction State Machine

```
TransactionInitial
  → TransactionAmountEntered (amount)
    → TransactionCardInserted (amount + card data)
      → TransactionPinEntered (card data + pin)
        → TransactionProcessing (card data)
          → TransactionSuccess (TransactionModel)
          → TransactionError (message)
```

---

### 1. Amount Entry

**File:** `lib/features/transaction/withdrawal_amount_page.dart`  
**Status: Functional**

- Custom numeric input buffer displayed as a formatted currency string (e.g. `PHP 5,000.00`)
- Custom numpad built from `NumpadKey` widgets (digit, backspace, clear, confirm keys)
- Calls `TransactionCubit.enterAmount(amount)` on confirmation
- Cancel resets the cubit state and returns to menu
- Navigation to `/withdraw/summary` on valid amount entry

---

### 2. Summary

**File:** `lib/features/transaction/withdrawal_summary_page.dart`  
**Status: Functional (demo values)**

- Displays the entered amount and acquirer fee (hardcoded at **PHP 0.00**)
- Shows a total row
- **PROCEED** navigates to `/withdraw/card-entry` if amount > 0
- **CANCEL** resets cubit and returns to menu

---

### 3. Card Entry

**File:** `lib/features/transaction/card_entry_page.dart`  
**Status: Functional (simulated card insert only)**

- Shows a centered credit card icon inside a circle container
- **Animation:** Repeating scale pulse — `AnimationController` (1400ms, reverse: true) driving a `ScaleTransition` with `Tween<double>(1.0, 1.08)` and `Curves.easeInOut`
- A loading overlay (`Colors.black26` + `CircularProgressIndicator`) appears while waiting for card data
- **SIMULATE CARD INSERT** button calls `TransactionCubit.simulateCardInsert(amount)`:
  - Waits 2 seconds (`Future.delayed`)
  - Emits `TransactionCardInserted` with hardcoded demo card data
- On `TransactionCardInserted` state → navigates to `/withdraw/card-confirm`
- On `TransactionError` state → shows `SnackBar` with the error message
- Back button is disabled while loading; resets cubit and pops on tap otherwise

> **Note:** `CardReaderService` exists (Topwise hardware integration) but is **not called here**. The card insert is fully simulated.

---

### 4. Card Confirmation

**File:** `lib/features/transaction/card_confirmation_page.dart`  
**Status: Functional**

- Reads card data from `TransactionCardInserted` state in the cubit
- Displays:
  - Masked card number (e.g. `**** **** **** 1105`)
  - Card holder name
  - Expiry date
  - Card type (e.g. MASTERCARD)
  - Account type (e.g. SAVINGS)
  - Withdrawal amount
- **PROCEED** navigates to `/withdraw/pin`
- **CANCEL** resets cubit and returns to menu

---

### 5. PIN Entry

**File:** `lib/features/transaction/pin_entry_page.dart`  
**Status: Functional**

- **Shuffled keypad:** digits 0–9 are shuffled via `Random()` on every page load using `List.generate(10, (i) => i)..shuffle(Random())`
- 4-dot PIN indicator row — each dot is an `AnimatedContainer` (150ms duration) that fills with `AppColors.primary` as digits are entered
- Grid layout: 3 columns × 4 rows (12 keys total: 9 shuffled digits + backspace + last digit + ENTER)
- ENTER key is enabled only when exactly 4 digits have been entered (`NumpadKeyStyle.confirm` vs `NumpadKeyStyle.disabled`)
- On ENTER: calls `TransactionCubit.enterPin(pin)` then navigates to `/withdraw/processing`
- CANCEL resets cubit and returns to menu

> **Note:** The PIN value is stored in state but is **not validated** against any host or hardware PIN pad — it is passed through for demo purposes.

---

### 6. Processing

**File:** `lib/features/transaction/processing_page.dart`  
**Status: Functional (simulated)**

- Triggers `TransactionCubit.processTransaction()` via `WidgetsBinding.instance.addPostFrameCallback` on first build
- Shows a processing animation / loader while the cubit is in `TransactionProcessing` state
- `TransactionCubit.processTransaction()` flow:
  1. Validates that state is `TransactionPinEntered`
  2. Emits `TransactionProcessing`
  3. Waits **3 seconds** (`Future.delayed`)
  4. Builds a `TransactionModel` with:
     - Current timestamp (`MM/DD/YYYY HH:mm:ss`)
     - Synthetic RRN, Invoice No., Trace ID (using `DateTime.now().millisecondsSinceEpoch % 1000000`)
     - Hardcoded TID: `62000005`, MID: `88000000`
     - Hardcoded Auth Code: `A1B2C3`
     - Acquirer Fee: `0.00`
  5. Emits `TransactionSuccess(transaction)`
- On `TransactionSuccess` → navigates to `/withdraw/ereceipt`
- On `TransactionError` → shows `SnackBar` and returns to menu

---

### 7. E-Receipt (Optional)

**File:** `lib/features/transaction/ereceipt_page.dart`  
**Status: UI stub**

- Offers the customer an option to receive a digital receipt
- Phone number and email fields are displayed (no controllers wired to any logic)
- **SEND** shows a `"Receipt sent!"` `SnackBar` then navigates to `/receipt` with the `TransactionModel`
- **SKIP** navigates directly to `/receipt` with the `TransactionModel`
- No actual SMS, email, or API call is made

---

### 8. Receipt Screen

**File:** `lib/features/transaction/receipt_page.dart`  
**Status: Functional**

Renders the full on-screen receipt and triggers physical printing.

**Receipt layout** (mirrors the printed output):
- `***** CUSTOMER COPY *****` header
- ATM Go logo (`assets/images/atm_go_logo.png`, height 88)
- Bank name: RCBC Savings Bank
- Address: 333 Sen. Gil Puyat Ave, Makati
- Website: www.rcbc.com
- Dashed dividers (`_DashedDivider` — custom `LayoutBuilder` widget using `Row` of `Divider` segments)
- Transaction type (e.g. WITHDRAW)
- Fields: Date/Time, RRN, TID, MID, Invoice No., Trace ID, Status
- Fields: Card Type, Auth Code, Card No.
- Amounts: Amount (PHP), Acquirer Fee (PHP), TOTAL (PHP, bold)
- Footer: "PIN Verified", "Signature Not Required", "RCBC/CARD"
- `***** CUSTOMER COPY *****` footer

**Print button behavior:**
1. Tap **PRINT** → immediately calls `PrinterCubit.print(transaction)`
2. After 200ms delay → `_isPrinting = true`, triggering the `AnimatedSlide`
3. **Animation:** Receipt card slides upward off screen (`Offset(0, -1.0)`, 2000ms, `Curves.linear`) simulating a physical receipt being printed
4. On `PrinterSuccess` → `_printDone = true`, button changes to **"PRINTED ✓"** (green), success overlay appears
5. On `PrinterError` → `SnackBar` shows the error message, print state resets

**DONE** button: resets `TransactionCubit` to `TransactionInitial` and navigates to `/menu`

---

## Feature: Printing

**Files:**
- `lib/features/printer/data/printer_service.dart`
- `lib/features/printer/presentation/cubits/printer_cubit.dart`
- `lib/features/printer/presentation/cubits/printer_state.dart`

**Status: Functional (requires Topwise native handler on Android)**

### PrinterService

Communicates with the native Android layer via:
- **Method Channel:** `topwise/device`
- **Method:** `printer/printReceipt`
- **Timeout:** 20 seconds

**Arguments sent to native:**

| Key | Value |
|---|---|
| `preLogoLines` | `["     ***** CUSTOMER COPY *****     "]` (centered) |
| `lines` | Full list of formatted receipt strings (see below) |
| `gray` | `3` |
| `align` | `"CENTER"` |
| `textSize` | `20` |
| `bold` | `false` |
| `underline` | `false` |

**Receipt line formatting:**
- **Line width:** 32 characters
- **Label width:** 12 characters
- `_colonRow(label, value)` → `"Label       : value"` format
- `_centered(text)` → pads with spaces to center within 32 chars
- `_leftRight(label, value)` → left-aligned label, right-aligned value (available, currently unused in receipt)

**Error handling:**
- `TimeoutException` → returns `PrinterResult(success: false, message: ...)`
- `PlatformException` → returns `PrinterResult(success: false, message: "code: ..., message: ...")` 
- All exceptions → logged via `dart:developer` `log()` with stack trace

### PrinterCubit

States:
- `PrinterInitial`
- `PrinterLoading`
- `PrinterSuccess`
- `PrinterError(message)`

Single method: `print(TransactionModel tx)` — calls `PrinterService.printReceipt(tx)` and emits appropriate state.

---

## Feature: Card Reader (Isolated Module)

**Files:**
- `lib/features/card_reader/data/card_reader_service.dart`
- `lib/features/card_reader/presentation/cubits/card_reader_cubit.dart`

**Status: Implemented in code — not connected to the app flow**

> `CardReaderCubit` is not registered in `main.dart` and `CardReaderService` is not called by any page.

### CardReaderService

Communicates with native Android via:
- **Method Channel:** `topwise/device`
- **Event Channel:** `topwise/cardEvents`

**Available methods:**

| Method | Channel call | Description |
|---|---|---|
| `events()` | Event stream | Subscribes to card hardware events (`type` + `data` map) |
| `startSwipe(timeout)` | `card/startSwipe` | Start magnetic stripe read (default 60s timeout) |
| `stopSwipe()` | `card/stopSwipe` | Stop swipe read |
| `startIC()` | `card/startIC` | Start chip (IC) card read |
| `stopIC()` | `card/stopIC` | Stop chip read |
| `isICPresent()` | `card/isICPresent` | Returns `bool` — whether IC card is inserted |
| `resetIC()` | `card/resetIC` | Reset IC card, returns ATR string |
| `readICApdu(apduHex)` | `card/readICApdu` | Send APDU command, returns response hex |
| `startRF()` | `card/startRF` | Start contactless (NFC/RF) read |
| `stopRF()` | `card/stopRF` | Stop RF read |
| `pollRF()` | `card/pollRF` | Poll for RF card, returns card data map |
| `readRFApdu(apduHex)` | `card/readRFApdu` | Send APDU to RF card, returns response hex |
| `stopAll()` | `card/stopAll` | Stop all active card readers |

---

## Animations

| Screen | Animation | Implementation |
|---|---|---|
| Card Entry | Repeating scale pulse on card icon | `AnimationController` (1400ms, repeat + reverse) → `ScaleTransition` with `Tween<double>(1.0, 1.08)`, `Curves.easeInOut` |
| PIN Entry | Dot fill indicator per digit | `AnimatedContainer` (150ms) on each of 4 dot widgets — fills `AppColors.primary` when digit is entered |
| Receipt (printing) | Receipt card slides up off screen | `AnimatedSlide` offset `(0, -1.0)`, 2000ms, `Curves.linear` — triggers on print tap + 200ms delay |

All animations use standard Flutter animation APIs — no third-party animation packages.

---

## State Management

The app uses **Flutter BLoC** in the Cubit pattern.

### TransactionCubit

Registered globally in `main.dart`. Manages the full withdrawal session lifecycle.

| Method | Description |
|---|---|
| `enterAmount(double)` | Emits `TransactionAmountEntered` |
| `simulateCardInsert(double)` | 2s delay → emits `TransactionCardInserted` with demo card data |
| `enterPin(String)` | Emits `TransactionPinEntered` (requires `TransactionCardInserted` state) |
| `processTransaction()` | 3s delay → builds `TransactionModel` → emits `TransactionSuccess` |
| `reset()` | Emits `TransactionInitial` — called on cancel or DONE |

### PrinterCubit

Registered globally in `main.dart`. Receives a `PrinterService` instance via constructor.

| Method | Description |
|---|---|
| `print(TransactionModel)` | Calls `PrinterService.printReceipt` → emits `PrinterLoading` → `PrinterSuccess` or `PrinterError` |

---

## Data Model

**File:** `lib/features/transaction/data/models/transaction_model.dart`

Generated with `freezed` + `json_serializable`.

```dart
TransactionModel({
  required String transactionType,  // e.g. "WITHDRAW"
  required String dateTime,         // "MM/DD/YYYY HH:mm:ss"
  required String rrn,              // Retrieval Reference Number
  required String tid,              // Terminal ID
  required String mid,              // Merchant ID
  required String invoiceNo,        // Invoice number
  required String traceId,          // Trace ID
  required String status,           // e.g. "Success"
  required String cardType,         // e.g. "MASTERCARD"
  required String authCode,         // Authorization code
  required String cardNo,           // Masked card number
  required double amount,           // Transaction amount
  required double acquirerFee,      // Fee (currently 0.00)
  required double total,            // amount + acquirerFee
})
```

Supports `fromJson` / `toJson` for future API serialization. Currently only constructed in-memory by `TransactionCubit.processTransaction()`.

---

## Theme & Design System

**File:** `lib/core/theme/app_theme.dart`  
**File:** `lib/core/constants/app_colors.dart`

Material 3 light theme using `ColorScheme.fromSeed` seeded from `AppColors.primary`.

**AppBar:** RCBC primary color background, white text, centered title, 0 elevation  
**ElevatedButton:** Full-width (double.infinity × 52px), rounded corners (10px), bold uppercase text  
**OutlinedButton:** Full-width, 1.5px primary border  
**Card:** 0 elevation, `AppColors.cardBg`, 12px border radius  
**Input fields:** Filled, outlined, primary color focus border

**Key colors:**

| Token | Usage |
|---|---|
| `AppColors.primary` | RCBC brand blue — buttons, app bar, accents |
| `AppColors.background` | Scaffold background |
| `AppColors.cardBg` | Card fill |
| `AppColors.textPrimary` | Main text |
| `AppColors.textSecond` | Secondary / hint text |
| `AppColors.success` | Green — print success, check icons |
| `AppColors.cancel` | Red/orange — cancel button |
| `AppColors.divider` | Dashed divider lines on receipt |

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^8.1.6 | State management (Cubit) |
| `go_router` | ^14.2.7 | Declarative navigation |
| `freezed_annotation` | ^2.4.4 | Immutable data models |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `equatable` | ^2.0.5 | Value equality for state classes |
| `dio` | ^5.4.3+1 | HTTP client (declared, not yet used) |
| `cupertino_icons` | ^1.0.8 | iOS-style icon set |

**Dev dependencies:** `freezed`, `json_serializable`, `build_runner`, `flutter_lints`, `flutter_test`

**Assets:** `assets/images/` — includes `atm_go_logo.png` (used on splash, login, processing, receipt)

---

## Known Limitations / Placeholders

| Area | Current behavior | What's needed |
|---|---|---|
| Login | Always succeeds — no auth | Real credential validation + session |
| Card insert | Simulated 2s delay with hardcoded card data | Wire `CardReaderService` + `CardReaderCubit` into `CardEntryPage` |
| Transaction processing | `Future.delayed(3s)` + synthetic data | Real ISO 8583 host message + response parsing |
| Acquirer fee | Hardcoded `0.00` | Dynamic fee from host response |
| TID / MID | Hardcoded in `TransactionCubit` | Read from device config or server |
| Auth code | Hardcoded `A1B2C3` | From host authorization response |
| E-receipt send | SnackBar only | SMS / email API integration |
| `dio` | Declared but unused | HTTP client for host API calls |
| Menu items | All except Withdraw show "Coming soon" | Implement Cash In, Balance Inquiry, Fund Transfer, Bills Payment |
| Route guards | None — any route is accessible directly | Auth guard to redirect unauthenticated users to `/login` |
