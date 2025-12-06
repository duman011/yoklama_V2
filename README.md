# Yoklama Amasya (Mobile) — Frontend

> frontend ok

Kısa açıklama
- Bu depo, Amasya Üniversitesi için geliştirilmiş mobil yoklama uygulamasının Flutter (Dart) frontend kodlarını içerir.
- Ana özellikler uygulamanın şu ana kadarki durumu:
	- Ders listesi (akademisyen ve öğrenci görünümleri)
	- "Dersi Başlat" akışı: dakika seçimi (çark veya sayısal giriş), oturum başlatma
	- Oturum başlatıldığında oluşturulan 8 haneli oturum kodu gösterimi (şimdilik lokal üretim, backend eklendiğinde değiştirilecek)
	- Yoklama oturumu ekranı: sayaç (geri sayım), durdur/devam, öğrenciler ve durumları
	- `MinuteClockPicker` — dairesel dakika seçim düğmesi
	- Splash / Login ekranlarında üniversite logosu (bundled asset)

Durum / Notlar
- Frontend geliştirildi ve temel akışlar çalışır — `frontend ok`.
- Backend entegrasyonu (oturum kodu, gerçek öğrenci verisi, yoklama sonuçlarının kaydı) henüz tamamlanmadı. Şu an oturum kodu yerel olarak üretiliyor; backend hazır olduğunda `_generateSessionCode()` veya ilgili yerler API'ye bağlanacaktır.
- Depoda şu anda bazı çalışma dizini değişiklikleri henüz commitlenmemiş olabilir; isterseniz kalan değişiklikleri de commitleyip push edebilirim.

Nasıl çalıştırılır (kısa)
1. Flutter SDK yüklü olmalı (repo `.dart_tool/version`: 3.38.3 olarak kaydedildi).
2. Bağımlılıkları yükleyin:

```bash
flutter pub get
```

3. Uygulamayı çalıştırın (örnek Android):

```bash
flutter run
```

Geri dönmek / devam etmek
- Bu README'ye daha sonra backend entegrasyonu ve ekstra dokümantasyon (API uç noktaları, test senaryoları) eklenecektir — ihtiyacınız olduğunda buraya geri dönebiliriz.

İletişim / not
- README açıklamasına `frontend ok` olarak işaretlendi. Backend entegrasyonu için gereken endpointleri sağladığınızda, gerekli ağ çağrılarını ekleyip akışı test edebilirim.
