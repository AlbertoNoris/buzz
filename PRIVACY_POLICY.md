# Privacy Policy, Buzz

**Last updated:** June 1, 2026 (unmasked session replay)

Buzz ("the App") is developed by Alberto Noris ("we", "us"). This Privacy Policy explains what information the App collects, how it is used, and which third parties process it on our behalf. By using Buzz you agree to the practices described below.

If you do not agree with this Policy, do not use the App.

---

## 1. Summary

- Your **drink logs, profile data, history and personal preferences stay on your device.** We do not store them on any server.
- We use **third-party services** to attribute installs to marketing campaigns, to deliver and validate subscriptions, to measure advertising performance, and to measure in-app product usage.
- We will ask for your **App Tracking Transparency (ATT) permission** before reading your Advertising Identifier (IDFA). If you decline, no IDFA is read; we still measure attribution using anonymous device signals that do not identify you personally (allowed under Apple's guidelines).
- We do **not** sell your personal information.

---

## 2. Information stored on your device only

The following data is created and stored locally on your device using iOS's standard storage (UserDefaults / SharedPreferences). It is **never transmitted to us or any third party**:

- **Profile data:** biological sex, age, height, weight, weekly units goal, habitual-drinker flag, drink-free streak preferences.
- **Session data:** drinks logged (type, volume, alcohol percentage, timestamp), food events (size, timestamp), custom drink definitions.
- **History:** daily summaries, recovery actions, mood-tracking inputs.
- **App preferences:** units (metric / imperial), notification choices, last-viewed screen.

This data remains on your device until you delete it (in-app deletion, iOS Storage settings, or uninstalling the App).

---

## 3. Information processed by third parties

To run paid subscriptions and to measure marketing campaigns, the App uses a small number of third-party services. Each of them is an independent data controller for the data they receive. Links to their privacy policies are provided.

### 3.1 Apple App Store, In-App Purchases
Apple Inc. processes your in-app purchases and subscriptions on our behalf. We receive only a transaction receipt and the resulting subscription status, we never receive your payment details, credit card, or Apple ID.
Privacy policy: https://www.apple.com/legal/privacy/

### 3.2 RevenueCat, Subscriptions and entitlements
We use **RevenueCat, Inc.** to validate Apple receipts, deliver paywalls, and grant or revoke the "Buzz Pro" entitlement. RevenueCat receives:
- a randomly generated, anonymous "App User ID" (no email, no name)
- the Apple receipt token / original transaction ID
- device locale, country, App Store country, app version, OS version
- product identifiers, purchase status, renewal / cancellation / refund events

RevenueCat does **not** receive your IDFA, your name, or your drink data.
Privacy policy: https://www.revenuecat.com/privacy

### 3.3 AppsFlyer, Install attribution and marketing measurement
We use **AppsFlyer Ltd.** to understand which marketing campaign (if any) led you to install the App. AppsFlyer processes:
- when ATT is **authorized**: IDFA (Apple Advertising Identifier), IDFV, device model, OS, IP address, country, install timestamp, install source, in-app events listed below
- when ATT is **denied**: no IDFA. AppsFlyer still receives anonymous probabilistic signals (device model, OS, IP, country, install timestamp) used to estimate aggregate attribution. These signals are not used to identify you individually.

In-app events sent to AppsFlyer: onboarding completion, paywall viewed, plus server-to-server subscription events forwarded from RevenueCat (trial started, initial purchase, renewal, cancellation, expiration) with the corresponding product identifier, revenue, and currency.

AppsFlyer does **not** receive your drink logs, profile data, name or email.
Privacy policy: https://www.appsflyer.com/legal/services-privacy-policy/

### 3.4 TikTok For Business, Ad measurement (via AppsFlyer)
We run advertising campaigns on **TikTok For Business** (operated by ByteDance Ltd.). We do **not** integrate the TikTok SDK directly inside the App. AppsFlyer forwards aggregated and (where applicable) hashed conversion events to TikTok so we can measure which ads drove installs and subscriptions. When ATT is authorized, your IDFA is included in this forwarding; when ATT is denied, only aggregated SKAdNetwork postbacks and probabilistic signals are forwarded.
Privacy policy: https://www.tiktok.com/legal/page/global/privacy-policy/en

### 3.5 Apple SKAdNetwork
Independently of AppsFlyer, Apple's privacy-preserving SKAdNetwork framework sends Apple-validated conversion postbacks to Apple, which forwards anonymized aggregated postbacks to ad networks (including TikTok). SKAdNetwork postbacks never contain user-identifying information and are signed by Apple.

### 3.6 PostHog, Product analytics and session replay
We use **PostHog Inc.** (EU region, hosted at `eu.i.posthog.com`) to measure how users move through the App so we can improve onboarding, paywall conversion, and feature usage. PostHog receives:
- a randomly generated, anonymous "distinct ID" (the same anonymous device identifier used for attribution, no email, no name)
- app version, OS version, device model, device locale, country (derived from IP)
- automatic application-lifecycle events (Application Opened, Application Backgrounded, Application Updated)
- the following in-app product events: `onboarding_completed` (with profile aggregates: biological sex, age, habitual-drinker flag, unit system), `paywall_viewed` (with the surface placement that triggered it), and `paywall_purchased` (with product identifier, price, and currency)
- **session replay recordings** of your interactions with the App, taps, swipes, screen transitions, and the visual layout. Session replays are not masked by default, so recordings may include text, icons, emoji, images, and values visible on the screen, including drink amounts, alcohol percentages, calories, profile values, onboarding answers, recovery tips, drink history, and custom drink labels. We use these recordings only for product analytics, debugging, and improving the App experience. IP addresses are anonymized server-side.

PostHog does **not** receive your IDFA, your name, your email, or your payment card details. Buzz does not ask for payment card numbers, and Apple processes App Store payments outside our app UI.

Privacy policy: https://posthog.com/privacy

### 3.7 Apple HealthKit, Optional write-only sync (stays on your device)

With your explicit permission, the App can mirror the drinks you log into the system **Apple Health** app on your device. For each drink, the App writes two values:
- the **number of standard drinks** (`HKQuantityTypeIdentifierNumberOfAlcoholicBeverages`, using the US/NIAAA convention of 14 g of pure alcohol per standard drink), and
- the **calories from that drink** (`HKQuantityTypeIdentifierDietaryEnergyConsumed`, in kilocalories).

This data is stored only inside Apple Health on your device. It is **never transmitted to us, to Apple's servers, or to any third party.** Apple Health is end-to-end encrypted across your devices when you enable iCloud sync for it.

**The App requests write-only access. We do not read any data from Apple Health.** Drinks, calories, or any other data already added to Apple Health by other apps remain invisible to Buzz.

You can control this in two ways:
- **In Buzz:** Settings → Integrations → Apple Health. Toggling off stops any further writes immediately. Drinks already written to Apple Health remain there, only you can delete them, from inside the Apple Health app.
- **In iOS:** Settings → Health → Data Access & Devices → Buzz Control. You can revoke either of the two write permissions at any time.

If you decline this permission during onboarding or in Settings, the App functions normally without any Apple Health sync.

Apple HealthKit privacy framework: https://support.apple.com/HT203037

---

## 4. App Tracking Transparency (ATT)

The first time you open the App after onboarding we will show Apple's standard "Allow tracking?" prompt. You have three choices:

- **Allow:** the App reads your IDFA and shares it with AppsFlyer and (via AppsFlyer) with TikTok for advertising-measurement purposes.
- **Ask App Not to Track:** the App does **not** read your IDFA. Attribution still works at an anonymous, probabilistic level, and SKAdNetwork postbacks are still sent by Apple. You will not be tracked across other apps.
- **No choice yet:** the App behaves as if you said "Ask App Not to Track" until you make a choice.

You can change your choice at any time in **iOS Settings → Privacy & Security → Tracking → Buzz**.

---

## 5. Data we do NOT collect

We do not collect, store, or transmit:
- Your name, email, or any account credential (the App does not have user accounts).
- Your precise location or GPS data.
- Your contacts, calendar, photos, microphone, camera, or motion data.
- Any data **from** Apple Health. We can optionally **write** drinks to Apple Health on your device (Section 3.7), but we never read anything back from it, and nothing written to Apple Health is transmitted off your device by us.
- Your payment-card details (these stay between you and Apple).
- Your drink logs, food events, profile, or history (these stay on your device).

---

## 6. Permissions

The App may request the following iOS permissions:

- **Notifications**, to send local reminders (hydration, recovery, streak nudges). Notifications are scheduled and shown entirely on your device; no push-notification service is involved.
- **App Tracking Transparency**, see Section 4 above.
- **Apple Health (write-only, optional)**, see Section 3.7 above. The App only asks for permission to *write* drinks and calories to Apple Health, never to read.

The App does **not** request access to your camera, microphone, location, contacts, calendar, photos, or motion.

---

## 7. Data retention and deletion

- **On-device data** stays on your device until you delete it (in-app, in iOS Storage, or by uninstalling the App). Uninstalling fully erases it.
- **RevenueCat** keeps subscription records for as long as needed to deliver the entitlement and for legal / accounting obligations. To request deletion: privacy@revenuecat.com.
- **AppsFlyer** keeps attribution data per their published retention policy. To request deletion: privacy@appsflyer.com.
- **PostHog** keeps product-analytics event data per their published retention policy. To request deletion: privacy@posthog.com.
- **TikTok** keeps the aggregated conversion data it receives for advertising measurement per its own retention policy.

Because Buzz does not maintain its own user accounts or its own servers, we cannot delete data on your behalf from these third parties, please contact them directly.

---

## 8. Your rights (GDPR / CCPA / similar)

Depending on where you live, you may have the right to:
- access the personal data a processor holds about you;
- request correction or deletion;
- object to processing for advertising purposes;
- withdraw consent (for ATT users: turn tracking off in iOS Settings).

To exercise these rights, contact each processor directly using the addresses in Section 7 above, or reach us at the address in Section 12.

---

## 9. Children's privacy

Buzz is intended only for users **18 years of age or older** (or the legal drinking age in their jurisdiction, whichever is higher). We do not knowingly collect data from anyone under 18. The App enforces an age gate at onboarding.

---

## 10. International transfers

The third-party processors named above operate globally and may transfer data to the United States and other countries. They each contractually commit to standard data-protection safeguards (Standard Contractual Clauses or equivalent). Their privacy policies describe these transfers in detail.

---

## 11. Changes to this Policy

If this Policy is updated, the new version will be posted at the URL linked from the App Store listing with an updated "Last updated" date. Material changes (new data categories, new processors) will be communicated via an in-app notice or a re-display of the ATT prompt where appropriate. Continued use of the App after an update constitutes acceptance of the revised Policy.

---

## 12. Contact

- **Email:** noris.a@me.com
- **GitHub Issues:** https://github.com/AlbertoNoris/buzz/issues

---

*This privacy policy applies to Buzz, available on the Apple App Store. Bundle identifier: com.thestolenspot.buzzControl.*
