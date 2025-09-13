# 🔑 API Keys Rehberi

Bu rehber, FindLoc uygulaması için gerekli API key'lerini nasıl alacağınızı gösterir.

## 1. Google Maps API Key

### Adımlar:
1. [Google Cloud Console](https://console.cloud.google.com/) hesabı oluşturun
2. Yeni bir proje oluşturun veya mevcut projeyi seçin
3. **APIs & Services > Library** bölümüne gidin
4. Şu API'leri etkinleştirin:
   - **Maps JavaScript API**
   - **Street View Static API**
   - **Geocoding API**
   - **Places API**

5. **APIs & Services > Credentials** bölümüne gidin
6. **Create Credentials > API Key** seçin
7. API key'inizi kopyalayın

### Kullanım:
```dart
// lib/core/config/api_keys.dart dosyasında
static const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### Ücretlendirme:
- İlk 28,000 istek ücretsiz
- Sonrası $7 per 1000 istek

---

## 2. OpenWeatherMap API Key

### Adımlar:
1. [OpenWeatherMap](https://openweathermap.org/api) hesabı oluşturun
2. Email doğrulaması yapın
3. **API Keys** bölümüne gidin
4. API key'inizi kopyalayın

### Kullanım:
```dart
static const String openWeatherApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### Ücretlendirme:
- 1000 istek/gün ücretsiz
- Sonrası $40/month

---

## 3. Webcams.travel API Key

### Adımlar:
1. [Webcams.travel](https://www.webcams.travel/api/) hesabı oluşturun
2. API key talep edin
3. Onay sonrası key'inizi alın

### Kullanım:
```dart
static const String webcamsTravelApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### Ücretlendirme:
- 1000 istek/gün ücretsiz
- Sonrası $10/month

---

## 4. Güvenlik Kameraları API

### Türkiye için:
1. **E-Devlet API**: [E-Devlet Kapısı](https://www.turkiye.gov.tr/)
2. **Belediye API'leri**: İstanbul, Ankara, İzmir belediyeleri
3. **Özel Güvenlik Şirketleri**: Axis, Hikvision, Dahua

### Kullanım:
```dart
static const String securityCameraApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

---

## 5. Trafik Kameraları API

### Türkiye için:
1. **KGM (Karayolları Genel Müdürlüğü)**
2. **İBB Trafik API**: İstanbul Büyükşehir Belediyesi
3. **Google Maps Traffic API**

### Kullanım:
```dart
static const String trafficCameraApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

---

## 6. Turizm API

### Türkiye için:
1. **Kültür ve Turizm Bakanlığı API**
2. **TripAdvisor API**
3. **Booking.com API**

### Kullanım:
```dart
static const String tourismApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

---

## 🔒 Güvenlik Notları

1. **API key'lerinizi asla public repository'de paylaşmayın**
2. **Environment variables kullanın**
3. **API key'leri düzenli olarak yenileyin**
4. **Rate limiting uygulayın**
5. **Error handling yapın**

---

## 📝 Environment Variables

`.env` dosyası oluşturun:
```env
GOOGLE_MAPS_API_KEY=your_google_maps_key
OPENWEATHER_API_KEY=your_openweather_key
WEBCAMS_TRAVEL_API_KEY=your_webcams_key
SECURITY_CAMERA_API_KEY=your_security_key
TRAFFIC_CAMERA_API_KEY=your_traffic_key
TOURISM_API_KEY=your_tourism_key
```

---

## 🚀 Test Etme

API key'lerinizi test etmek için:

```dart
// Test Google Maps API
final testUrl = 'https://maps.googleapis.com/maps/api/streetview?size=400x400&location=41.0082,28.9784&fov=90&heading=0&pitch=0&key=$apiKey';

// Test OpenWeather API
final testUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=41.0082&lon=28.9784&appid=$apiKey';
```

---

## 💡 İpuçları

1. **Ücretsiz limitleri aşmamak için caching kullanın**
2. **Batch requests yapın**
3. **Error handling ekleyin**
4. **Fallback mekanizmaları oluşturun**
5. **API key rotation uygulayın**
