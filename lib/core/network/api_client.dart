import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:find_loc/core/data/models/location_model.dart';

class ApiClient {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com';
  static const String _apiKey = 'AIzaSyAcIUzhAtpU56TX9RB0gSElyA4fJ3RVGXo';

  // Helper method to make Gemini API calls
  static Future<Map<String, dynamic>> _callGeminiAPI(
    String prompt,
    List<Map<String, dynamic>> imageParts,
  ) async {
    // API key kontrolü
    if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') {
      throw Exception(
          'API key ayarlanmamış! Lütfen geçerli bir Gemini API key\'i ekleyin.');
    }

    // Request body'yi oluştur
    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            ...imageParts,
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.1,
        "topK": 32,
        "topP": 1,
        "maxOutputTokens": 4096,
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    };

    // Debug için request body'yi logla
    print('API Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse(
          '$_baseUrl/v1beta/models/gemini-1.5-pro:generateContent?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'FindLoc/1.0',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];

          // Gelişmiş JSON temizleme
          String cleanContent = _cleanJsonResponse(content);

          return jsonDecode(cleanContent);
        } else {
          throw Exception('API response format error: No candidates found');
        }
      } catch (e) {
        throw Exception(
            'JSON parse error: $e. Response body: ${response.body}');
      }
    } else {
      final errorBody = response.body;
      print('API Error Response: ${response.statusCode} - $errorBody');

      if (response.statusCode == 400) {
        // 400 hatası için daha detaylı analiz
        try {
          final errorData = jsonDecode(errorBody);
          if (errorData['error'] != null) {
            final error = errorData['error'];
            final message = error['message'] ?? 'Bilinmeyen hata';
            final status = error['status'] ?? 'UNKNOWN';

            if (message.contains('API_KEY_INVALID') ||
                message.contains('invalid')) {
              throw Exception(
                  'API key geçersiz! Lütfen geçerli bir Gemini API key\'i ekleyin.\n\nHata detayı: $message');
            } else if (message.contains('quota') || message.contains('limit')) {
              throw Exception(
                  'API quota aşıldı! Lütfen daha sonra tekrar deneyin.\n\nHata detayı: $message');
            } else {
              throw Exception(
                  'API isteği geçersiz: $message\n\nStatus: $status');
            }
          } else {
            throw Exception(
                'API key geçersiz veya request formatı hatalı. Lütfen API key\'i kontrol edin.\n\nHata: $errorBody');
          }
        } catch (e) {
          throw Exception(
              'API key geçersiz veya request formatı hatalı. Lütfen API key\'i kontrol edin.\n\nHata: $errorBody');
        }
      } else if (response.statusCode == 403) {
        throw Exception(
            'Erişim reddedildi (403): API key yetkisi yok veya quota aşıldı.\n\nÇözüm:\n• API key\'in geçerli olduğundan emin olun\n• Gemini API\'nin etkin olduğunu kontrol edin\n• Quota limitinizi kontrol edin');
      } else if (response.statusCode == 429) {
        throw Exception(
            'Çok fazla istek (429): Rate limit aşıldı. Lütfen birkaç dakika bekleyin.');
      } else if (response.statusCode == 500) {
        throw Exception(
            'Sunucu hatası (500): Gemini API geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.');
      } else {
        throw Exception(
            'API çağrısı başarısız: ${response.statusCode}\n\nHata detayı: $errorBody\n\nÇözüm önerileri:\n• İnternet bağlantınızı kontrol edin\n• API key\'in geçerli olduğundan emin olun\n• Daha sonra tekrar deneyin');
      }
    }
  }

  // Gelişmiş JSON temizleme metodu
  static String _cleanJsonResponse(String content) {
    String cleanContent = content.trim();

    // 1. Markdown code block'ları kaldır
    if (cleanContent.startsWith('```json')) {
      cleanContent = cleanContent.substring(7);
    } else if (cleanContent.startsWith('```')) {
      cleanContent = cleanContent.substring(3);
    }

    if (cleanContent.endsWith('```')) {
      cleanContent = cleanContent.substring(0, cleanContent.length - 3);
    }

    cleanContent = cleanContent.trim();

    // 2. Gereksiz metinleri kaldır
    final unwantedPrefixes = [
      'JSON:',
      'Response:',
      'Result:',
      'Here is the JSON:',
      'The JSON response is:',
      'JSON format:',
      'Bu JSON formatında:',
      'JSON yanıtı:',
      'Sonuç:',
    ];

    for (String prefix in unwantedPrefixes) {
      if (cleanContent.toLowerCase().startsWith(prefix.toLowerCase())) {
        cleanContent = cleanContent.substring(prefix.length).trim();
        break;
      }
    }

    // 3. JSON başlangıç ve bitiş kontrolü
    if (!cleanContent.startsWith('{') && !cleanContent.startsWith('[')) {
      // JSON başlangıcını bul
      final startIndex = cleanContent.indexOf('{');
      if (startIndex != -1) {
        cleanContent = cleanContent.substring(startIndex);
      } else {
        // Array başlangıcını bul
        final arrayStartIndex = cleanContent.indexOf('[');
        if (arrayStartIndex != -1) {
          cleanContent = cleanContent.substring(arrayStartIndex);
        }
      }
    }

    // 4. JSON bitişini bul
    if (cleanContent.contains('}')) {
      final lastBraceIndex = cleanContent.lastIndexOf('}');
      cleanContent = cleanContent.substring(0, lastBraceIndex + 1);
    } else if (cleanContent.contains(']')) {
      final lastBracketIndex = cleanContent.lastIndexOf(']');
      cleanContent = cleanContent.substring(0, lastBracketIndex + 1);
    }

    // 5. Son temizlik
    cleanContent = cleanContent.trim();

    // 6. Eğer hala JSON değilse, basit bir JSON oluştur
    if (!cleanContent.startsWith('{') && !cleanContent.startsWith('[')) {
      cleanContent =
          '{"error": "Invalid JSON format", "original_content": "$content"}';
    }

    return cleanContent;
  }

  // Helper method to get MIME type from URL
  static String _getMimeTypeFromUrl(String url) {
    final extension = url.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // Instagram URL kontrolü
  static bool _isInstagramUrl(String url) {
    return url.toLowerCase().contains('instagram.com') ||
        url.toLowerCase().contains('instagr.am') ||
        url.toLowerCase().contains('ig.me');
  }

  // URL temizleme
  static String _cleanImageUrl(String url) {
    // URL'yi temizle ve geçerli hale getir
    String cleanUrl = url.trim();

    // Instagram URL'lerini özel olarak işle
    if (_isInstagramUrl(cleanUrl)) {
      // Instagram post URL'lerini görsel URL'lerine çevirmeye çalış
      if (cleanUrl.contains('/p/')) {
        // Instagram post URL'si - doğrudan görsel URL'sine çevir
        final postId = cleanUrl.split('/p/')[1].split('/')[0];
        cleanUrl = 'https://instagram.com/p/$postId/media/?size=l';
      } else if (cleanUrl.contains('/reel/')) {
        // Instagram reel URL'si
        final reelId = cleanUrl.split('/reel/')[1].split('/')[0];
        cleanUrl = 'https://instagram.com/reel/$reelId/media/?size=l';
      }
    }

    // Eğer URL https:// ile başlamıyorsa ekle
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    return cleanUrl;
  }

  // URL için uygun header'ları al
  static Map<String, String> _getHeadersForUrl(String url) {
    final headers = <String, String>{
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1',
      'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9,tr;q=0.8',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'Sec-Fetch-Dest': 'image',
      'Sec-Fetch-Mode': 'no-cors',
      'Sec-Fetch-Site': 'cross-site',
    };

    // Özel siteler için ek header'lar
    if (url.contains('instagram.com') ||
        url.contains('instagr.am') ||
        url.contains('ig.me')) {
      headers['Referer'] = 'https://www.instagram.com/';
      headers['Origin'] = 'https://www.instagram.com';
      headers['X-Requested-With'] = 'XMLHttpRequest';
    } else if (url.contains('imgur.com')) {
      headers['Referer'] = 'https://imgur.com/';
    } else if (url.contains('reddit.com')) {
      headers['Referer'] = 'https://reddit.com/';
    } else if (url.contains('twitter.com') || url.contains('x.com')) {
      headers['Referer'] = 'https://twitter.com/';
    }

    return headers;
  }

  // Two-stage analysis for image files
  static Future<LocationModel> detectLocationTwoStage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = 'image/jpeg';

    final imageParts = [
      {
        "inline_data": {
          "mime_type": mimeType,
          "data": base64Image,
        }
      }
    ];

    // Stage 1: General detection
    final generalPrompt = _getGeneralDetectionPrompt();
    final generalResult = await _callGeminiAPI(generalPrompt, imageParts);

    final locationType = generalResult['locationType'] ?? 'unknown';
    final architectureStyle = generalResult['architectureStyle'] ?? 'unknown';
    final geography = generalResult['geography'] ?? 'unknown';
    final roadType = generalResult['roadType'] ?? 'unknown';
    final country = generalResult['country'] ?? 'unknown';
    final specialAreaType = generalResult['specialAreaType'] ?? 'unknown';
    final entertainmentSubType =
        generalResult['entertainmentSubType'] ?? 'unknown';
    final urbanSubType = generalResult['urbanSubType'] ?? 'unknown';
    final climateZone = generalResult['climateZone'] ?? 'unknown';
    final vegetationType = generalResult['vegetationType'] ?? 'unknown';
    final waterBodyType = generalResult['waterBodyType'] ?? 'unknown';
    final buildingDensity = generalResult['buildingDensity'] ?? 'unknown';
    final trafficLevel = generalResult['trafficLevel'] ?? 'unknown';
    final timeOfDay = generalResult['timeOfDay'] ?? 'unknown';
    final season = generalResult['season'] ?? 'unknown';

    // Stage 2: Specialized analysis based on general detection
    final specializedPrompt = _getSpecializedPrompt(
      locationType: locationType,
      architectureStyle: architectureStyle,
      geography: geography,
      roadType: roadType,
      country: country,
      specialAreaType: specialAreaType,
      entertainmentSubType: entertainmentSubType,
      urbanSubType: urbanSubType,
      climateZone: climateZone,
      vegetationType: vegetationType,
      waterBodyType: waterBodyType,
      buildingDensity: buildingDensity,
      trafficLevel: trafficLevel,
      timeOfDay: timeOfDay,
      season: season,
    );

    final detailedResult = await _callGeminiAPI(specializedPrompt, imageParts);

    return LocationModel.fromJson(detailedResult);
  }

  // Two-stage analysis for URLs
  static Future<LocationModel> detectLocationTwoStageFromUrl(
      String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image: ${response.statusCode}');
    }

    final bytes = response.bodyBytes;
    final base64Image = base64Encode(bytes);
    final mimeType = _getMimeTypeFromUrl(imageUrl);

    final imageParts = [
      {
        "inline_data": {
          "mime_type": mimeType,
          "data": base64Image,
        }
      }
    ];

    // Stage 1: General detection
    final generalPrompt = _getGeneralDetectionPrompt();
    final generalResult = await _callGeminiAPI(generalPrompt, imageParts);

    final locationType = generalResult['locationType'] ?? 'unknown';
    final architectureStyle = generalResult['architectureStyle'] ?? 'unknown';
    final geography = generalResult['geography'] ?? 'unknown';
    final roadType = generalResult['roadType'] ?? 'unknown';
    final country = generalResult['country'] ?? 'unknown';
    final specialAreaType = generalResult['specialAreaType'] ?? 'unknown';
    final entertainmentSubType =
        generalResult['entertainmentSubType'] ?? 'unknown';
    final urbanSubType = generalResult['urbanSubType'] ?? 'unknown';
    final climateZone = generalResult['climateZone'] ?? 'unknown';
    final vegetationType = generalResult['vegetationType'] ?? 'unknown';
    final waterBodyType = generalResult['waterBodyType'] ?? 'unknown';
    final buildingDensity = generalResult['buildingDensity'] ?? 'unknown';
    final trafficLevel = generalResult['trafficLevel'] ?? 'unknown';
    final timeOfDay = generalResult['timeOfDay'] ?? 'unknown';
    final season = generalResult['season'] ?? 'unknown';

    // Stage 2: Specialized analysis based on general detection
    final specializedPrompt = _getSpecializedPrompt(
      locationType: locationType,
      architectureStyle: architectureStyle,
      geography: geography,
      roadType: roadType,
      country: country,
      specialAreaType: specialAreaType,
      entertainmentSubType: entertainmentSubType,
      urbanSubType: urbanSubType,
      climateZone: climateZone,
      vegetationType: vegetationType,
      waterBodyType: waterBodyType,
      buildingDensity: buildingDensity,
      trafficLevel: trafficLevel,
      timeOfDay: timeOfDay,
      season: season,
    );

    final detailedResult = await _callGeminiAPI(specializedPrompt, imageParts);

    return LocationModel.fromJson(detailedResult);
  }

  // General detection prompt for Stage 1
  static String _getGeneralDetectionPrompt() {
    return '''
Bu görseli analiz et ve konum türünü genel olarak belirle. Aşağıdaki JSON formatında yanıt ver:

{
  "locationType": "sahil|dağ|orman|şehir|kırsal|su_alanı|çöl|tarihi|dini|endüstriyel|eğlence|ulaşım|eğitim|sağlık|genel",
  "architectureStyle": "modern|klasik|gotik|barok|osmanlı|antik|endüstriyel|geleneksel|art_deco|brutalist|neoklasik|romanesk|rönesans|victorian|colonial|contemporary|bilinmiyor",
  "geography": "kıyı|dağlık|düz|tepeli|ormanlık|çöl|şehir|kırsal|vadi|plato|ada|yarımada|körfez|delta|bilinmiyor",
  "roadType": "otoyol|şehir_içi|kırsal|köprü|tünel|yaya|bulvar|sokak|patika|asfalt|toprak|taş|kavşak|yol_ayrım|intersection|bilinmiyor",
  "country": "ülke_adı_veya_bilinmiyor",
  "specialAreaType": "sahil|dağ|orman|su_alanı|çöl|tarihi|dini|endüstriyel|eğlence|ulaşım|eğitim|sağlık|yol_ayrım|kavşak|intersection|genel",
  "entertainmentSubType": "tema_parkı|su_parkı|spor|kültür|gece_hayatı|müze|galeri|tiyatro|sinema|konser|festival|bilinmiyor",
  "urbanSubType": "metropol|iş_merkezi|konut|turist|endüstriyel|ticari|finansal|kültürel|eğitim|sağlık|ulaşım|liman|havaalanı|bilinmiyor",
  "climateZone": "tropikal|subtropikal|ılıman|karasal|kutup|çöl|mediterranean|continental|bilinmiyor",
  "vegetationType": "tropikal_orman|ılıman_orman|iğne_yapraklı|geniş_yapraklı|çalılık|çayır|tundra|çöl|mangrov|bilinmiyor",
  "waterBodyType": "deniz|okyanus|göl|nehir|dere|kanal|baraj|liman|koy|körfez|ada|bilinmiyor",
  "buildingDensity": "yoğun|orta|seyrek|çok_seyrek|bilinmiyor",
  "trafficLevel": "yoğun|orta|az|çok_az|bilinmiyor",
  "timeOfDay": "gündüz|gece|şafak|akşam|bilinmiyor",
  "season": "ilkbahar|yaz|sonbahar|kış|bilinmiyor"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  // Specialized prompt selector for Stage 2
  static String _getSpecializedPrompt({
    required String locationType,
    required String architectureStyle,
    required String geography,
    required String roadType,
    required String country,
    String? specialAreaType,
    String? entertainmentSubType,
    String? urbanSubType,
    String? climateZone,
    String? vegetationType,
    String? waterBodyType,
    String? buildingDensity,
    String? trafficLevel,
    String? timeOfDay,
    String? season,
  }) {
    if (specialAreaType?.contains('sahil') == true) {
      return _getCoastalAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('dağ') == true) {
      return _getMountainAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('orman') == true) {
      return _getForestAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('su_alanı') == true) {
      return _getWaterBodyAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('çöl') == true) {
      return _getDesertAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('tarihi') == true) {
      return _getHistoricalAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('dini') == true) {
      return _getReligiousAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('endüstriyel') == true) {
      return _getIndustrialAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('eğlence') == true) {
      return _getEntertainmentAnalysisPrompt(locationType, architectureStyle,
          geography, roadType, country, entertainmentSubType);
    } else if (specialAreaType?.contains('ulaşım') == true) {
      return _getTransportationAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (roadType.contains('otoyol') == true ||
        roadType.contains('şehir_içi') == true ||
        roadType.contains('bulvar') == true ||
        specialAreaType?.contains('yol_ayrım') == true ||
        specialAreaType?.contains('intersection') == true ||
        specialAreaType?.contains('junction') == true) {
      return _getRoadIntersectionAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('eğitim') == true) {
      return _getEducationalAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('sağlık') == true) {
      return _getHealthcareAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
      // SOSYAL MEDYA POPÜLER YERLER
    } else if (specialAreaType?.contains('restoran') == true ||
        specialAreaType?.contains('kafe') == true ||
        specialAreaType?.contains('bar') == true ||
        specialAreaType?.contains('yemek') == true ||
        specialAreaType?.contains('food') == true) {
      return _getRestaurantAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('sokak') == true ||
        specialAreaType?.contains('cadde') == true ||
        specialAreaType?.contains('bulvar') == true ||
        specialAreaType?.contains('street') == true) {
      return _getStreetAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('manzara') == true ||
        specialAreaType?.contains('seyir') == true ||
        specialAreaType?.contains('teras') == true ||
        specialAreaType?.contains('viewpoint') == true) {
      return _getViewpointAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('turist') == true ||
        specialAreaType?.contains('ziyaret') == true ||
        specialAreaType?.contains('landmark') == true ||
        specialAreaType?.contains('attraction') == true) {
      return _getTouristAttractionAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('instagram') == true ||
        specialAreaType?.contains('fotoğraf') == true ||
        specialAreaType?.contains('selfie') == true ||
        specialAreaType?.contains('viral') == true) {
      return _getInstagramWorthyAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('alışveriş') == true ||
        specialAreaType?.contains('market') == true ||
        specialAreaType?.contains('mall') == true ||
        specialAreaType?.contains('shop') == true) {
      return _getShoppingAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('park') == true ||
        specialAreaType?.contains('bahçe') == true ||
        specialAreaType?.contains('yeşil') == true ||
        specialAreaType?.contains('garden') == true) {
      return _getParkAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('köprü') == true ||
        specialAreaType?.contains('bridge') == true ||
        specialAreaType?.contains('geçit') == true) {
      return _getBridgeAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (specialAreaType?.contains('meydan') == true ||
        specialAreaType?.contains('square') == true ||
        specialAreaType?.contains('plaza') == true) {
      return _getSquareAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else if (locationType.contains('şehir') ||
        locationType.contains('kent')) {
      return _getUrbanAnalysisPrompt(locationType, architectureStyle, geography,
          roadType, country, urbanSubType);
    } else if (locationType.contains('kırsal')) {
      return _getRuralAnalysisPrompt(
          locationType, architectureStyle, geography, roadType, country);
    } else {
      return _getGeneralDetailedPrompt(
          locationType, architectureStyle, geography, roadType, country);
    }
  }

  // Enhanced specialized prompts with detailed analysis
  static String _getCoastalAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
SAHİL ALANI ANALİZİ - UZMAN COĞRAFYA, MİMARİ VE SOSYAL MEDYA ANALİSTİ

Bu görseli sahil alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

DETAYLI ANALİZ GEREKSİNİMLERİ:
1. COĞRAFİ ÖZELLİKLER:
   - Sahil türü: kumlu|kayalık|çakıllı|mangrov|deltalı|fiyort|koy|körfez|ada|yarımada
   - Kıyı şekli: düz|dik|alçak|yüksek|dalgalı|düzgün
   - Deniz durumu: sakin|dalgalı|fırtınalı|buzlu|sıcak|soğuk
   - Gelgit durumu: yüksek|düşük|orta|yok

2. MİMARİ VE YAPILAŞMA:
   - Sahil yapıları: iskele|rıhtım|liman|marina|plaj_kulübesi|otel|villa|ev|apartman
   - Mimari tarz: mediterranean|tropikal|modern|geleneksel|kolonyal|contemporary
   - Yapı yoğunluğu: yoğun|orta|seyrek|çok_seyrek
   - Yükseklik: tek_kat|çok_kat|gökdelen|karışık

3. TURİZM VE EĞLENCE:
   - Turizm türü: lüks|orta|ekonomik|backpacker|aile|çift|grup
   - Aktivite türü: yüzme|dalış|sörf|yacht|balıkçılık|güneşlenme|yürüyüş
   - Tesis türü: resort|otel|pansiyon|camping|villa|apartman

4. ULAŞIM VE ALTYAPI:
   - Yol türü: sahil_yolu|ana_cadde|sokak|patika|otoyol
   - Ulaşım: araba|otobüs|tren|feribot|uçak|yürüyüş
   - Liman türü: ticari|yolcu|balıkçı|marina|askeri

5. DOĞAL ÖZELLİKLER:
   - Bitki örtüsü: palmiye|çam|mangrov|çalı|çim|kum|kayalık
   - Hayvan yaşamı: kuş|balık|deniz_kaplumbağası|yunus|balina
   - Jeolojik yapı: kumtaşı|kireçtaşı|granit|bazalt|volkanik

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tarz",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85,
  "coastalType": "sahil_türü",
  "coastlineShape": "kıyı_şekli",
  "seaCondition": "deniz_durumu",
  "tideLevel": "gelgit_durumu",
  "coastalStructures": ["yapı1", "yapı2"],
  "tourismType": "turizm_türü",
  "activities": ["aktivite1", "aktivite2"],
  "facilities": ["tesis1", "tesis2"],
  "transportation": ["ulaşım1", "ulaşım2"],
  "portType": "liman_türü",
  "vegetation": ["bitki1", "bitki2"],
  "wildlife": ["hayvan1", "hayvan2"],
  "geology": "jeolojik_yapı",
  "climate": "iklim_türü",
  "waterTemperature": "su_sıcaklığı",
  "beachQuality": "plaj_kalitesi",
  "accessibility": "erişilebilirlik",
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "sunsetView": "günbatımı_manzarası",
  "sunriseView": "gündoğumu_manzarası",
  "nightView": "gece_manzarası",
  "crowdLevel": "kalabalık_seviyesi",
  "beachActivities": ["plaj_aktivitesi1", "plaj_aktivitesi2"],
  "waterSports": ["su_sporu1", "su_sporu2"],
  "diningOptions": ["yemek_seçeneği1", "yemek_seçeneği2"],
  "accommodation": ["konaklama1", "konaklama2"],
  "parking": "otopark",
  "safety": "güvenlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel",
  "influencerVisits": "influencer_ziyaretleri",
  "hashtagPotential": "hashtag_potansiyeli"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getMountainAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
DAĞ ALANI ANALİZİ - UZMAN COĞRAFYA, MİMARİ VE SOSYAL MEDYA ANALİSTİ

Bu görseli dağ alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

DETAYLI ANALİZ GEREKSİNİMLERİ:
1. JEOLOJİK ÖZELLİKLER:
   - Dağ türü: volkanik|kıvrımlı|blok|kırık|kalker|granit|bazalt|kumtaşı
   - Yükseklik: alçak|orta|yüksek|çok_yüksek|ultra_yüksek
   - Eğim: hafif|orta|dik|çok_dik|dikey
   - Formasyon: tek_tepe|sıra|masif|plato|vadi|geçit

2. İKLİM VE HAVA DURUMU:
   - İklim kuşağı: tropikal|subtropikal|ılıman|karasal|alpin|kutup
   - Hava durumu: güneşli|bulutlu|sisli|kar|yağmur|fırtına
   - Sıcaklık: sıcak|ılık|serin|soğuk|çok_soğuk
   - Rüzgar: sakin|hafif|orta|güçlü|fırtına

3. BİTKİ ÖRTÜSÜ VE EKOSİSTEM:
   - Vejetasyon: tropikal|subtropikal|ılıman|iğne_yapraklı|alpin|tundra|çöl
   - Ağaç türü: çam|meşe|kayın|gürgen|sedir|ardıç|huş
   - Çalılık: rododendron|defne|maki|çalı|ot
   - Çiçekli bitkiler: alpin_çiçekler|yabani_çiçekler|endemik

4. YAPILAŞMA VE YERLEŞİM:
   - Yerleşim türü: köy|kasaba|şehir|dağ_evi|kulübe|kamp
   - Mimari tarz: geleneksel|modern|rustik|alpin|chalet|log
   - Yapı malzemesi: taş|ahşap|tuğla|beton|karışık
   - Yükseklik: tek_kat|çok_kat|karışık

5. ULAŞIM VE ALTYAPI:
   - Yol türü: dağ_yolu|viraj|tünel|köprü|patika|teleferik
   - Ulaşım: araba|otobüs|tren|teleferik|yürüyüş|at
   - Altyapı: elektrik|su|kanalizasyon|internet|telefon

6. TURİZM VE AKTİVİTELER:
   - Turizm türü: doğa|avcılık|dağcılık|kayak|trekking|kültür
   - Aktivite türü: yürüyüş|tırmanış|kayak|snowboard|mountain_bike|fotoğraf
   - Tesis türü: otel|pansiyon|kamp|dağ_evi|kulübe|resort

7. DOĞAL AFET RİSKLERİ:
   - Risk türü: çığ|heyelan|sel|fırtına|deprem|volkanik
   - Risk seviyesi: düşük|orta|yüksek|çok_yüksek
   - Koruma önlemleri: var|yok|kısmi

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tarz",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85,
  "mountainType": "dağ_türü",
  "elevation": "yükseklik",
  "slope": "eğim",
  "formation": "formasyon",
  "climate": "iklim_kuşağı",
  "weather": "hava_durumu",
  "temperature": "sıcaklık",
  "wind": "rüzgar",
  "vegetation": "vejetasyon",
  "treeType": ["ağaç1", "ağaç2"],
  "shrubbery": ["çalı1", "çalı2"],
  "flowers": ["çiçek1", "çiçek2"],
  "settlementType": "yerleşim_türü",
  "buildingMaterial": "yapı_malzemesi",
  "transportation": ["ulaşım1", "ulaşım2"],
  "infrastructure": ["altyapı1", "altyapı2"],
  "tourismType": "turizm_türü",
  "activities": ["aktivite1", "aktivite2"],
  "facilities": ["tesis1", "tesis2"],
  "naturalHazards": ["risk1", "risk2"],
  "riskLevel": "risk_seviyesi",
  "protectionMeasures": "koruma_önlemleri",
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "sunsetView": "günbatımı_manzarası",
  "sunriseView": "gündoğumu_manzarası",
  "nightView": "gece_manzarası",
  "crowdLevel": "kalabalık_seviyesi",
  "hikingTrails": ["yürüyüş_parkuru1", "yürüyüş_parkuru2"],
  "viewpoints": ["manzara_noktası1", "manzara_noktası2"],
  "campingSpots": ["kamp_alanı1", "kamp_alanı2"],
  "safety": "güvenlik",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel",
  "influencerVisits": "influencer_ziyaretleri",
  "hashtagPotential": "hashtag_potansiyeli"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getForestAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
ORMAN ALANI ANALİZİ - UZMAN COĞRAFYA, MİMARİ VE SOSYAL MEDYA ANALİSTİ

Bu görseli orman alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

DETAYLI ANALİZ GEREKSİNİMLERİ:
1. EKOSİSTEM TÜRÜ:
   - Orman türü: tropikal|subtropikal|ılıman|iğne_yapraklı|karışık|alpin|mangrov|bambu
   - Yoğunluk: çok_yoğun|yoğun|orta|seyrek|çok_seyrek
   - Yaş: genç|orta|olgun|yaşlı|antik
   - Koruma durumu: korumalı|kısmi_koruma|korunmamış|endüstriyel

2. AĞAÇ TÜRLERİ VE VEJETASYON:
   - Dominant ağaç türü: çam|meşe|kayın|gürgen|sedir|ardıç|huş|kavak|söğüt|palmiye|bambu
   - Alt katman: çalı|ot|yosun|mantar|eğrelti|sarmaşık
   - Çiçekli bitkiler: yabani_çiçekler|endemik|nadir|yaygın
   - Mantar türü: yenilebilir|zehirli|tıbbi|dekoratif

3. İKLİM VE ÇEVRE:
   - İklim kuşağı: tropikal|subtropikal|ılıman|karasal|alpin|mediterranean
   - Nem seviyesi: çok_yüksek|yüksek|orta|düşük|çok_düşük
   - Sıcaklık: sıcak|ılık|serin|soğuk|çok_soğuk
   - Yağış: çok_yüksek|yüksek|orta|düşük|çok_düşük

4. YERLEŞİM VE YAPILAŞMA:
   - Yerleşim türü: köy|kasaba|şehir|dağ_evi|kulübe|kamp|araştırma_istasyonu
   - Mimari tarz: geleneksel|modern|rustik|alpin|chalet|log|bambu
   - Yapı malzemesi: ahşap|taş|bambu|beton|karışık
   - Yükseklik: tek_kat|çok_kat|karışık

5. ULAŞIM VE ALTYAPI:
   - Yol türü: orman_yolu|patika|yürüyüş_parkuru|asfalt|toprak|taş
   - Ulaşım: araba|otobüs|tren|teleferik|yürüyüş|at|bisiklet
   - Altyapı: elektrik|su|kanalizasyon|internet|telefon|güvenlik

6. TURİZM VE AKTİVİTELER:
   - Turizm türü: doğa|ekoturizm|avcılık|dağcılık|trekking|kültür|bilim
   - Aktivite türü: yürüyüş|tırmanış|fotoğraf|kuş_gözlemi|botanik|kamp
   - Tesis türü: otel|pansiyon|kamp|dağ_evi|kulübe|resort|araştırma_merkezi

7. DOĞAL YAŞAM:
   - Memeli türleri: ayı|kurt|geyik|tavşan|sincap|kirpi|yaban_domuzu
   - Kuş türleri: kartal|şahin|baykuş|ağaçkakan|bülbül|saka
   - Böcek türleri: kelebek|arı|karınca|böcek|örümcek
   - Sürüngen türleri: yılan|kertenkele|kaplumbağa|kurbağa

8. KORUMA VE RİSKLER:
   - Koruma durumu: milli_park|doğa_rezervi|koruma_alanı|endüstriyel|karışık
   - Risk türü: yangın|hastalık|zararlı|iklim|insan|endüstri
   - Risk seviyesi: düşük|orta|yüksek|çok_yüksek
   - Koruma önlemleri: var|yok|kısmi|geliştiriliyor

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tarz",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85,
  "forestType": "orman_türü",
  "density": "yoğunluk",
  "age": "yaş",
  "protectionStatus": "koruma_durumu",
  "dominantTreeType": "dominant_ağaç_türü",
  "understory": ["alt_katman1", "alt_katman2"],
  "flowers": ["çiçek1", "çiçek2"],
  "mushroomType": "mantar_türü",
  "climate": "iklim_kuşağı",
  "humidity": "nem_seviyesi",
  "temperature": "sıcaklık",
  "precipitation": "yağış",
  "settlementType": "yerleşim_türü",
  "buildingMaterial": "yapı_malzemesi",
  "transportation": ["ulaşım1", "ulaşım2"],
  "infrastructure": ["altyapı1", "altyapı2"],
  "tourismType": "turizm_türü",
  "activities": ["aktivite1", "aktivite2"],
  "facilities": ["tesis1", "tesis2"],
  "mammals": ["memeli1", "memeli2"],
  "birds": ["kuş1", "kuş2"],
  "insects": ["böcek1", "böcek2"],
  "reptiles": ["sürüngen1", "sürüngen2"],
  "conservationStatus": "koruma_durumu",
  "riskType": ["risk1", "risk2"],
  "riskLevel": "risk_seviyesi",
  "protectionMeasures": "koruma_önlemleri",
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "sunsetView": "günbatımı_manzarası",
  "sunriseView": "gündoğumu_manzarası",
  "nightView": "gece_manzarası",
  "crowdLevel": "kalabalık_seviyesi",
  "hikingTrails": ["yürüyüş_parkuru1", "yürüyüş_parkuru2"],
  "naturePhotography": "doğa_fotoğrafçılığı",
  "wildlifeWatching": "yaban_hayvanı_izleme",
  "campingSpots": ["kamp_alanı1", "kamp_alanı2"],
  "safety": "güvenlik",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel",
  "influencerVisits": "influencer_ziyaretleri",
  "hashtagPotential": "hashtag_potansiyeli"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getWaterBodyAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
SU ALANI ANALİZİ - UZMAN COĞRAFYA VE MİMARİ ANALİSTİ

Bu görseli su alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getDesertAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
ÇÖL ALANI ANALİZİ - UZMAN COĞRAFYA VE MİMARİ ANALİSTİ

Bu görseli çöl alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getHistoricalAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
TARİHİ ALAN ANALİZİ - UZMAN TARİH VE MİMARİ ANALİSTİ

Bu görseli tarihi alan uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getReligiousAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
DİNİ ALAN ANALİZİ - UZMAN DİN VE MİMARİ ANALİSTİ

Bu görseli dini alan uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getIndustrialAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
ENDÜSTRİYEL ALAN ANALİZİ - UZMAN ENDÜSTRİ VE MİMARİ ANALİSTİ

Bu görseli endüstriyel alan uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getEntertainmentAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
    String? entertainmentSubType,
  ) {
    return '''
EĞLENCE ALANI ANALİZİ - UZMAN EĞLENCE VE TURİZM ANALİSTİ

Bu görseli eğlence alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getTransportationAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
ULAŞIM ALANI ANALİZİ - UZMAN ULAŞIM VE LOJİSTİK ANALİSTİ

Bu görseli ulaşım alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getEducationalAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
EĞİTİM ALANI ANALİZİ - UZMAN EĞİTİM VE MİMARİ ANALİSTİ

Bu görseli eğitim alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getHealthcareAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
SAĞLIK ALANI ANALİZİ - UZMAN SAĞLIK VE MİMARİ ANALİSTİ

Bu görseli sağlık alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getUrbanAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
    String? urbanSubType,
  ) {
    return '''
ŞEHİR ALANI ANALİZİ - UZMAN ŞEHİR VE MİMARİ ANALİSTİ

Bu görseli şehir alanı uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

DETAYLI ANALİZ GEREKSİNİMLERİ:
1. ŞEHİR TÜRÜ VE BÜYÜKLÜK:
   - Şehir türü: metropol|büyük_şehir|orta_şehir|küçük_şehir|kasaba|köy
   - Nüfus yoğunluğu: çok_yoğun|yoğun|orta|seyrek|çok_seyrek
   - Gelişim seviyesi: gelişmiş|gelişmekte|gelişmemiş|karışık
   - Şehir planlaması: planlı|yarı_planlı|plansız|organik|karışık

2. MİMARİ VE YAPILAŞMA:
   - Mimari tarz: modern|klasik|gotik|barok|osmanlı|antik|endüstriyel|geleneksel|art_deco|brutalist|neoklasik|romanesk|rönesans|victorian|colonial|contemporary
   - Yapı türü: gökdelen|apartman|ev|villa|ofis|ticari|endüstriyel|kamu|dini|eğitim|sağlık
   - Yapı yoğunluğu: çok_yoğun|yoğun|orta|seyrek|çok_seyrek
   - Yükseklik: tek_kat|çok_kat|gökdelen|karışık
   - Yapı malzemesi: beton|çelik|cam|tuğla|taş|ahşap|karışık

3. ŞEHİR BÖLGELERİ:
   - Bölge türü: merkez|iş_merkezi|konut|ticari|endüstriyel|kültürel|eğitim|sağlık|ulaşım|liman|havaalanı|turist|gecekondu|lüks
   - Fonksiyon: ticari|konut|karma|endüstriyel|kamu|eğitim|sağlık|turist|ulaşım
   - Sosyo-ekonomik durum: yüksek|orta|düşük|karışık
   - Güvenlik seviyesi: yüksek|orta|düşük|değişken

4. ULAŞIM VE ALTYAPI:
   - Yol türü: otoyol|bulvar|ana_cadde|sokak|yaya|bisiklet|tramvay|metro
   - Ulaşım: araba|otobüs|tren|metro|tramvay|taksi|bisiklet|yürüyüş|feribot|uçak
   - Trafik durumu: yoğun|orta|az|çok_az|değişken
   - Altyapı: elektrik|su|kanalizasyon|internet|telefon|gaz|güvenlik|temizlik

5. TİCARET VE EKONOMİ:
   - Ticaret türü: büyük_ticaret|orta_ticaret|küçük_ticaret|sokak_ticareti|pazar|alışveriş_merkezi
   - Ekonomik sektör: hizmet|sanayi|tarım|turizm|teknoloji|finans|eğitim|sağlık
   - İş merkezi: var|yok|kısmi|gelişmekte
   - Turizm: yüksek|orta|düşük|yok

6. KÜLTÜR VE SOSYAL YAŞAM:
   - Kültürel tesisler: müze|galeri|tiyatro|sinema|konser|kütüphane|spor|park
   - Sosyal yaşam: canlı|orta|sakin|çok_sakin
   - Gece hayatı: canlı|orta|sakin|yok
   - Eğlence: yüksek|orta|düşük|yok

7. DOĞAL ÇEVRE:
   - Yeşil alan: çok|orta|az|çok_az|yok
   - Park türü: büyük_park|küçük_park|sokak_parkı|botanik|hayvanat_bahçesi
   - Su kaynakları: nehir|göl|deniz|çeşme|yok
   - Hava kalitesi: iyi|orta|kötü|çok_kötü

8. GÜVENLİK VE YASAL DURUM:
   - Güvenlik: yüksek|orta|düşük|değişken
   - Polis varlığı: yoğun|orta|az|yok
   - Kamera sistemi: var|yok|kısmi
   - Acil servis: var|yok|kısmi

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "cityType": "şehir_türü",
  "populationDensity": "nüfus_yoğunluğu",
  "developmentLevel": "gelişim_seviyesi",
  "urbanPlanning": "şehir_planlaması",
  "buildingType": "yapı_türü",
  "buildingDensity": "yapı_yoğunluğu",
  "buildingHeight": "yükseklik",
  "buildingMaterial": "yapı_malzemesi",
  "districtType": "bölge_türü",
  "function": "fonksiyon",
  "socioEconomicStatus": "sosyo_ekonomik_durum",
  "securityLevel": "güvenlik_seviyesi",
  "transportation": ["ulaşım1", "ulaşım2"],
  "trafficLevel": "trafik_durumu",
  "infrastructure": ["altyapı1", "altyapı2"],
  "commerceType": "ticaret_türü",
  "economicSector": "ekonomik_sektör",
  "businessCenter": "iş_merkezi",
  "tourism": "turizm",
  "culturalFacilities": ["kültürel_tesis1", "kültürel_tesis2"],
  "socialLife": "sosyal_yaşam",
  "nightlife": "gece_hayatı",
  "entertainment": "eğlence",
  "greenSpace": "yeşil_alan",
  "parkType": "park_türü",
  "waterSources": ["su_kaynağı1", "su_kaynağı2"],
  "airQuality": "hava_kalitesi",
  "security": "güvenlik",
  "policePresence": "polis_varlığı",
  "cameraSystem": "kamera_sistemi",
  "emergencyServices": "acil_servis"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getRuralAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
KIRSAL ALAN ANALİZİ - UZMAN COĞRAFYA VE MİMARİ ANALİSTİ

Bu görseli kırsal alan uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getGeneralDetailedPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
GENEL DETAYLI ANALİZ - UZMAN COĞRAFYA VE MİMARİ ANALİSTİ

Bu görseli genel uzman olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $geography, $country

JSON FORMATI:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  // Eski tek-aşamalı metodlar (geriye uyumluluk için)
  static Future<LocationModel> detectLocationFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = 'image/jpeg';

    final imageParts = [
      {
        "inline_data": {
          "mime_type": mimeType,
          "data": base64Image,
        }
      }
    ];

    final prompt = _getLocationDetectionPrompt();
    final result = await _callGeminiAPI(prompt, imageParts);

    return LocationModel.fromJson(result);
  }

  static Future<LocationModel> detectLocationFromUrl(String imageUrl) async {
    try {
      // Instagram URL'lerini kontrol et (geçici olarak devre dışı)
      // if (_isInstagramUrl(imageUrl)) {
      //   throw Exception(
      //       'Instagram URL\'leri doğrudan desteklenmiyor. Lütfen görseli indirip galeriye kaydedin, sonra galeriden seçin.');
      // }

      // URL'yi temizle ve geçerli hale getir
      final cleanUrl = _cleanImageUrl(imageUrl);

      // Özel header'lar ekle (bazı siteler için)
      final headers = _getHeadersForUrl(cleanUrl);

      print('Trying to download image from: $cleanUrl');
      final response = await http.get(Uri.parse(cleanUrl), headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        print('Downloaded ${bytes.length} bytes');

        // Görsel boyutunu kontrol et (çok büyükse hata ver)
        if (bytes.length > 10 * 1024 * 1024) {
          // 10MB limit
          throw Exception(
              'Görsel çok büyük. Lütfen daha küçük bir görsel kullanın.');
        }

        // Görsel boş mu kontrol et
        if (bytes.isEmpty) {
          throw Exception('Görsel boş veya indirilemedi.');
        }

        final base64Image = base64Encode(bytes);
        final mimeType = _getMimeTypeFromUrl(cleanUrl);

        final imageParts = [
          {
            "inline_data": {
              "mime_type": mimeType,
              "data": base64Image,
            }
          }
        ];

        final prompt = _getLocationDetectionPrompt();
        final result = await _callGeminiAPI(prompt, imageParts);

        return LocationModel.fromJson(result);
      } else {
        throw Exception(
            'Görsel indirilemedi. HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e.toString().contains('Instagram')) {
        rethrow;
      } else {
        throw Exception(
            'Görsel işlenirken hata oluştu: $e\n\nÇözüm önerileri:\n• Görseli cihazınıza indirin ve galeriden seçin\n• Farklı bir görsel URL\'si deneyin\n• Görselin herkese açık olduğundan emin olun');
      }
    }
  }

  // Eski tek-aşamalı prompt
  static String _getLocationDetectionPrompt() {
    return '''
Bu görseli analiz et ve konum bilgilerini JSON formatında TÜRKÇE olarak ver.

Analiz etmen gereken özellikler:
- Mimari yapılar ve özellikleri
- Yol türü ve kesişim özellikleri  
- Trafik işaretleri ve yön tabelaları
- Coğrafi özellikler (dağ, deniz, orman, vs.)
- Kültürel ipuçları (dil, para birimi, vs.)

JSON formatı:
{
  "locationName": "konum_adı",
  "description": "detaylı_açıklama",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "confidence": 0.85
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  // SOSYAL MEDYA POPÜLER YERLER - İNSANLARIN FOTOĞRAF ÇEKTİĞİ YERLER
  static String _getRestaurantAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
RESTORAN VE YEMEK YERİ ANALİZİ - UZMAN GASTRONOMİ VE SOSYAL MEDYA ANALİSTİ

Bu görseli restoran/yemek yeri uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "restaurantType": "restoran_türü",
  "cuisineType": "mutfak_türü",
  "priceLevel": "fiyat_seviyesi",
  "atmosphere": "atmosfer",
  "interiorDesign": "iç_mekan_tasarımı",
  "lighting": "aydınlatma",
  "decorStyle": "dekorasyon_tarzı",
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "popularDishes": ["popüler_yemek1", "popüler_yemek2"],
  "targetAudience": "hedef_kitle",
  "openingHours": "açılış_saatleri",
  "reservationRequired": "rezervasyon_gerekli",
  "outdoorSeating": "dış_mekan_oturma",
  "parking": "otopark",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getStreetAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
SOKAK VE CADDE ANALİZİ - UZMAN ŞEHİR PLANLAMA VE SOSYAL MEDYA ANALİSTİ

Bu görseli sokak/cadde uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "streetType": "sokak_türü",
  "width": "genişlik",
  "length": "uzunluk",
  "pavementType": "kaldırım_türü",
  "streetFurniture": ["sokak_mobilyası1", "sokak_mobilyası2"],
  "lighting": "aydınlatma",
  "trees": "ağaçlar",
  "shops": ["dükkan1", "dükkan2"],
  "cafes": ["kafe1", "kafe2"],
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "crowdLevel": "kalabalık_seviyesi",
  "safety": "güvenlik",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getViewpointAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
MANZARA NOKTASI ANALİZİ - UZMAN FOTOĞRAF VE SOSYAL MEDYA ANALİSTİ

Bu görseli manzara noktası uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "viewpointType": "manzara_noktası_türü",
  "elevation": "yükseklik",
  "viewDirection": "bakış_yönü",
  "visibleLandmarks": ["görünen_yer1", "görünen_yer2"],
  "naturalFeatures": ["doğal_özellik1", "doğal_özellik2"],
  "urbanFeatures": ["şehir_özelliği1", "şehir_özelliği2"],
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "sunsetView": "günbatımı_manzarası",
  "sunriseView": "gündoğumu_manzarası",
  "nightView": "gece_manzarası",
  "crowdLevel": "kalabalık_seviyesi",
  "safety": "güvenlik",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getTouristAttractionAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
TURİST ATRAKSİYONU ANALİZİ - UZMAN TURİZM VE SOSYAL MEDYA ANALİSTİ

Bu görseli turist atraksiyonu uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "attractionType": "atraksiyon_türü",
  "significance": "önem",
  "historicalPeriod": "tarihi_dönem",
  "culturalValue": "kültürel_değer",
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "crowdLevel": "kalabalık_seviyesi",
  "entranceFee": "giriş_ücreti",
  "openingHours": "açılış_saatleri",
  "guidedTours": "rehberli_turlar",
  "facilities": ["tesis1", "tesis2"],
  "souvenirShops": "hediyelik_eşya_dükkanları",
  "restaurants": ["restoran1", "restoran2"],
  "parking": "otopark",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getInstagramWorthyAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
İNSTAGRAM DEĞERLİ YER ANALİZİ - UZMAN SOSYAL MEDYA VE FOTOĞRAF ANALİSTİ

Bu görseli Instagram değerli yer uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "instagramWorthiness": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestAngles": ["en_iyi_açı1", "en_iyi_açı2"],
  "lightingConditions": "aydınlatma_koşulları",
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "hashtagPotential": "hashtag_potansiyeli",
  "viralPotential": "viral_potansiyel",
  "crowdLevel": "kalabalık_seviyesi",
  "photoDifficulty": "fotoğraf_zorluğu",
  "equipmentNeeded": ["gerekli_ekipman1", "gerekli_ekipman2"],
  "safety": "güvenlik",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "influencerVisits": "influencer_ziyaretleri"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getShoppingAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
ALIŞVERİŞ YERİ ANALİZİ - UZMAN TİCARET VE SOSYAL MEDYA ANALİSTİ

Bu görseli alışveriş yeri uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "shoppingType": "alışveriş_türü",
  "storeTypes": ["mağaza_türü1", "mağaza_türü2"],
  "priceLevel": "fiyat_seviyesi",
  "targetAudience": "hedef_kitle",
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "interiorDesign": "iç_mekan_tasarımı",
  "lighting": "aydınlatma",
  "crowdLevel": "kalabalık_seviyesi",
  "openingHours": "açılış_saatleri",
  "parking": "otopark",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getParkAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
PARK VE BAHÇE ANALİZİ - UZMAN PEYZAJ VE SOSYAL MEDYA ANALİSTİ

Bu görseli park/bahçe uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "parkType": "park_türü",
  "size": "büyüklük",
  "vegetation": ["bitki1", "bitki2"],
  "flowers": ["çiçek1", "çiçek2"],
  "trees": ["ağaç1", "ağaç2"],
  "waterFeatures": ["su_özelliği1", "su_özelliği2"],
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "seasonalBeauty": "mevsimsel_güzellik",
  "activities": ["aktivite1", "aktivite2"],
  "facilities": ["tesis1", "tesis2"],
  "crowdLevel": "kalabalık_seviyesi",
  "safety": "güvenlik",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getBridgeAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
KÖPRÜ ANALİZİ - UZMAN MÜHENDİSLİK VE SOSYAL MEDYA ANALİSTİ

Bu görseli köprü uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "bridgeType": "köprü_türü",
  "length": "uzunluk",
  "height": "yükseklik",
  "span": "açıklık",
  "material": "malzeme",
  "constructionYear": "yapım_yılı",
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "nightLighting": "gece_aydınlatması",
  "viewFromBridge": "köprüden_manzara",
  "viewOfBridge": "köprü_manzarası",
  "crowdLevel": "kalabalık_seviyesi",
  "safety": "güvenlik",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  static String _getSquareAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
MEYDAN ANALİZİ - UZMAN ŞEHİR PLANLAMA VE SOSYAL MEDYA ANALİSTİ

Bu görseli meydan uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kesişim_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "squareType": "meydan_türü",
  "size": "büyüklük",
  "shape": "şekil",
  "surroundingBuildings": ["çevre_bina1", "çevre_bina2"],
  "monuments": ["anıt1", "anıt2"],
  "fountains": ["çeşme1", "çeşme2"],
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "events": ["etkinlik1", "etkinlik2"],
  "crowdLevel": "kalabalık_seviyesi",
  "safety": "güvenlik",
  "accessibility": "erişilebilirlik",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  // Road intersection analysis prompt
  static String _getRoadIntersectionAnalysisPrompt(
    String locationType,
    String architectureStyle,
    String geography,
    String roadType,
    String country,
  ) {
    return '''
YOL AYRIMI VE KAVŞAK ANALİZİ - UZMAN ULAŞIM VE TRAFİK ANALİSTİ

Bu görseli yol ayrımı ve kavşak uzmanı olarak analiz et. Önceki tespit: $locationType, $architectureStyle, $country

JSON FORMATI:
{
  "id": "unique_id",
  "name": "konum_adı",
  "description": "detaylı_açıklama",
  "address": "tam_adres",
  "country": "ülke",
  "city": "şehir",
  "coordinates": {"latitude": 0.0, "longitude": 0.0},
  "confidence": 0.85,
  "detectedAt": "2025-01-13T13:41:00Z",
  "accuracy": 0.0,
  "buildingType": "yapı_türü",
  "architecturalStyle": "mimari_tzar",
  "roadType": "yol_türü",
  "intersectionType": "kavşak_türü",
  "visualClues": ["ipucu1", "ipucu2"],
  "intersectionCategory": "kavşak_kategorisi",
  "roadCount": "yol_sayısı",
  "trafficFlow": "trafik_akışı",
  "trafficLights": "trafik_ışıkları",
  "roadSigns": ["yol_levhası1", "yol_levhası2"],
  "laneCount": "şerit_sayısı",
  "roadWidth": "yol_genişliği",
  "surfaceType": "yol_yüzeyi",
  "roadCondition": "yol_durumu",
  "safetyFeatures": ["güvenlik_özelliği1", "güvenlik_özelliği2"],
  "pedestrianCrossing": "yaya_geçidi",
  "bicycleLane": "bisiklet_yolu",
  "publicTransport": "toplu_taşıma",
  "parking": "otopark",
  "nearbyLandmarks": ["yakın_landmark1", "yakın_landmark2"],
  "trafficDensity": "trafik_yoğunluğu",
  "speedLimit": "hız_sınırı",
  "roadHierarchy": "yol_hierarşisi",
  "intersectionDesign": "kavşak_tasarımı",
  "visibility": "görüş_mesafesi",
  "lighting": "aydınlatma",
  "maintenance": "bakım_durumu",
  "accessibility": "erişilebilirlik",
  "safety": "güvenlik",
  "instagramWorthy": "instagram_değeri",
  "photoSpots": ["fotoğraf_noktası1", "fotoğraf_noktası2"],
  "bestTimeToVisit": "ziyaret_edilecek_en_iyi_zaman",
  "crowdLevel": "kalabalık_seviyesi",
  "socialMediaPresence": "sosyal_medya_varlığı",
  "viralPotential": "viral_potansiyel"
}

    ÖNEMLİ: SADECE JSON FORMATINDA YANIT VER. Hiçbir açıklama, metin, markdown veya ek bilgi ekleme. Sadece geçerli JSON objesi döndür. JSON dışında hiçbir şey yazma.
''';
  }

  /// Test API key validity
  static Future<bool> testApiKey() async {
    try {
      final testRequestBody = {
        "contents": [
          {
            "parts": [
              {"text": "Test"}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.1,
          "maxOutputTokens": 10,
        }
      };

      final response = await http.post(
        Uri.parse(
            '$_baseUrl/v1beta/models/gemini-1.5-pro:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'FindLoc/1.0',
        },
        body: jsonEncode(testRequestBody),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
