# 📊 Stock & Cost Management (Stok ve Maliyet Yönetimi)

A modern, user-friendly **Flutter** application integrating profit/loss tracking, dynamic ingredient cost updates, and recipe-based automated inventory management.

---

## 🚀 Core Features

### 📈 1. Visual Dashboard & Analytics
*   **Real-time Performance:** Track today's revenue, total costs, and net profit margins at a glance.
*   **Pie Charts & Trends:** Automated visual breakdown of profit/loss budgets.
*   **Critical Stock Alerts:** Immediate visual warnings about depleted or low inventory items.

### 📦 2. Ingredient & Inventory Management
*   **Dynamic Weighted Average:** Automatically recalculates accurate average stock costs as soon as new purchases are logged.
*   **Multi-Unit Conversion:** Conveniently scales units (e.g., grams to kilograms, milliliters to liters) for clean inputs.
*   **Rollback / Deletion capabilities:** Soft deletion of past purchases automatically restores accurate prior weighted stock prices.

### 🍕 3. Recipes & Production Framework
*   **Product Costing Simulation:** Link raw materials into customized Product Recipes to simulate unit item costs.
*   **Auto-Produce triggers:** Linked ingredient quantities automatically decrement from inventory upon sale creation.

### 💰 4. Revenue & Sales Monitoring
*   **Profit Analysis:** Immediate comparison of revenue vs raw cost factors on every made sale dashboard.
*   **Update History Dialogs:** Native dialogues allowing easy fix modifications on sale items price-points and notes.

### 🧾 5. Smart Invoice Recognition (OCR)
*   **Computer Vision Layout:** Scanning bill/receipt payloads automatically maps them into inventory items via camera setups.

---

## 🛠️ Tech Stack

*   **Framework:** [Flutter](https://flutter.dev) & Dart
*   **State Management:** Riverpod
*   **Local Storage:** [Isar Database](https://isar.dev) (Lightweight & ultra-fast local database queries)
*   **Analytics Renderings:** `fl_chart` libraries

---

## 🔑 Getting Started

1.  Ensure you have Flutter SDK set up on your machine setup.
2.  Download bundles:
    ```bash
    flutter pub get
    ```
3.  Launch build target:
    ```bash
    flutter run
    ```

<br>

---
---

<br>

# 📊 Stok ve Maliyet Yönetimi (Stock & Cost Management)

Kâr-zarar takibi, dinamik hammadde maliyetleri ve reçete bazlı otomatik stok yönetimini tek çatı altında toplayan, modern ve kullanıcı dostu bir **Flutter** uygulaması.

---

## 🚀 Öne Çıkan Özellikler (Core Features)

### 📈 1. Görsel Özet ve Dashboard
*   **Anlık Performans:** Bugünkü satış gelirleri, maliyetler ve net kâr oranı takibi.
*   **Dairesel Grafikler:** Ciro içindeki kâr/zarar bütçesini otomatik analiz eder.
*   **Kritik Stok Alarmları:** Biten ya da azalan maddeleri gözünüzün önüne getirir.

### 📦 2. Hammadde ve Stok Yönetimi
*   **Dinamik Ağırlıklı Ortalama (Weighted Average):** Yeni satın alma girdikçe önceki stok maliyetlerini otomatik düzeltir.
*   **Çoklu Birim Çevirileri:** Gramdan kiloya, mililitreden litreye otomatik görüntüleme desteği.
*   **Geri Alım (Rollback):** Hatalı satın alımları sildiğinizde eski stok maliyetine şeffaf ve güvenli geri dönebilme.

### 🍕 3. Reçeteler ve Üretim Sistematiği
*   **Ürün Maliyetleme:** Hammaddeleri birleştirip ürün birim maliyetlerinizi otomatik simüle edin.
*   **Otomatik Üretim Desteği:** Satış yapıldığı an ürünün içerisindeki tüm hammadde miktarları otomatik olarak eksiltilir.

### 💰 4. Satış ve Ciro Takibi
*   **Karlılık Analizi:** Hangi satışta ne kadar kâr elde edildiğini maliyet-satış farkına göre anında görebilme.
*   **Geçmiş Kayıt Düzenleme:** Yapılan satışların fiyat bilgisi ya da notlarını detay listesinden her zaman güncelleyebilme.

### 🧾 5. Akıllı Fatura ve Fiş Tanılama (OCR)
*   **Makineli Görme:** Kamera aracılığıyla fişi taratarak satırları otomatik hammadde girdisine dönüştürme altyapısı mevcuttur.

---

## 🛠️ Kullanılan Teknolojiler (Tech Stack)

*   **Framework:** [Flutter](https://flutter.dev) & Dart
*   **State Management:** Riverpod
*   **Yerel Veritabanı:** [Isar Database](https://isar.dev) (Hafif ve ultra hızlı query)
*   **Görsel Analitikler:** `fl_chart` kütüphaneleri

---

## 🔑 Kurulum ve Çalıştırma (Get Started)

1.  Bilgisayarınızda Flutter SDK setup'ının kurulu olduğundan emin olun.
2.  Paketleri indirin:
    ```bash
    flutter pub get
    ```
3.  Uygulamayı çalıştırın:
    ```bash
    flutter run
    ```
