# Gemini API Key Kurulumu

## 400 Hatası Çözümü

Eğer "konum tespit edilmedi 400 hatası" alıyorsanız, bu genellikle API key eksikliği veya yanlış format nedeniyle oluyor.

## API Key Alma

1. **Google AI Studio'ya gidin:** https://aistudio.google.com/
2. **"Get API Key" butonuna tıklayın**
3. **"Create API Key" seçin**
4. **API key'inizi kopyalayın**

## API Key Ayarlama

### Yöntem 1: Environment Variable (Önerilen)

```bash
# Terminal'de çalıştırın:
export GEMINI_API_KEY="your_actual_api_key_here"

# Sonra uygulamayı çalıştırın:
flutter run
```

### Yöntem 2: Doğrudan Kodda (Güvenlik riski)

`lib/core/network/api_client.dart` dosyasında:

```dart
static const String _apiKey = 'your_actual_api_key_here';
```

## Test Etme

API key'i ayarladıktan sonra:

```bash
flutter run
```

## Hata Kodları

- **400 Bad Request:** API key geçersiz veya request formatı hatalı
- **403 Forbidden:** API key yetkisi yok veya quota aşıldı
- **429 Too Many Requests:** Rate limit aşıldı

## Güvenlik

- API key'inizi asla public repository'de paylaşmayın
- Environment variable kullanmayı tercih edin
- API key'inizi düzenli olarak yenileyin
