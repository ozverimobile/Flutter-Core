import 'package:flutter/foundation.dart';

@immutable
final class ErrorMessages {
  const ErrorMessages({
    this.connectionTimeout = 'Bağlantı zaman aşımına uğradı.',
    this.sendTimeout = 'İstek gönderim süresi aşıldı.',
    this.receiveTimeout = 'Veri alım süresi aşıldı..',
    this.badCertificate = 'Geçersiz sertifika.',
    this.cancel = 'İşlem iptal edildi.',
    this.socketException = 'İnternet bağlantısı yok.',
    this.httpException = 'Sunucuya bağlanırken bir hata oluştu. Lütfen tekrar deneyin.',
    this.handshakeException = 'Güvenlik sertifikası doğrulanamadı. Lütfen bağlantıyı kontrol edin.',
    this.certificateException = 'Sertifika hatası meydana geldi. Bağlantıyı kontrol edin veya tekrar deneyin.',
    this.somethingWentWrong = 'Bir şeyler ters gitti.',
    this.statusCodeMessages = const <int?, String?>{
      // 4xx Client Error
      400: 'Geçersiz istek.',
      401: 'Yetkisiz erişim.',
      402: 'Ödeme gerekli.',
      403: 'Erişim engellendi.',
      404: 'Kaynak bulunamadı.',
      405: 'Bu istek yöntemi desteklenmiyor.',
      406: 'Uygun içerik bulunamadı.',
      407: 'Proxy kimlik doğrulaması gerekli.',
      408: 'İstek zaman aşımına uğradı.',
      409: 'Sunucu durumu ile çakışma var.',
      410: 'Kaynak artık mevcut değil.',
      411: 'İçerik uzunluğu belirtilmeli.',
      412: 'Ön koşul başarısız oldu.',
      413: 'İçerik çok büyük.',
      414: 'URI çok uzun.',
      415: 'Desteklenmeyen medya türü.',
      416: 'İstenen aralık karşılanamıyor.',
      417: 'Beklenti başarısız oldu.',
      418: 'Ben bir çaydanlıyım.',
      421: 'Yanlış yönlendirilmiş istek.',
      422: 'İşlenemeyen içerik.',
      423: 'Kaynak kilitli.',
      424: 'Bağımlılık başarısız.',
      425: 'Çok erken gönderim.',
      426: 'Protokol yükseltmesi gerekli.',
      428: 'Ön koşul gerekli.',
      429: 'Çok fazla istek gönderildi.',
      431: 'İstek başlık alanları çok büyük.',
      451: 'Yasal nedenlerle kullanılamıyor.',

      // 5xx Server Error
      500: 'Sunucuda beklenmeyen bir hata oluştu.',
      501: 'Bu istek yöntemi sunucu tarafından desteklenmiyor.',
      502: 'Geçersiz ağ geçidi yanıtı alındı.',
      503: 'Hizmet geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
      504: 'Ağ geçidi yanıt vermedi. Zaman aşımı hatası.',
      505: 'HTTP sürümü sunucu tarafından desteklenmiyor.',
      506: 'Sunucu yapılandırma hatası: Çevrimsel referans algılandı.',
      507: 'Sunucu, bu isteği işlemek için yeterli depolama alanına sahip değil.',
      508: 'Sunucu isteği işlerken bir döngü tespit etti.',
      510: 'İstek işleme için gerekli uzantı desteklenmiyor.',
      511: 'Ağa erişim sağlamak için kimlik doğrulaması gerekiyor.',
    },
  });

  final String connectionTimeout;
  final String sendTimeout;
  final String receiveTimeout;
  final String badCertificate;
  final String cancel;
  final String socketException;
  final String httpException;
  final String handshakeException;
  final String certificateException;
  final String somethingWentWrong;
  final Map<int?, String?> statusCodeMessages;
}
