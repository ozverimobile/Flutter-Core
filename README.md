# Flutter Core Paket

---

### İçindekiler

- [Paket Kurulumu](#paket-kurulumu)
- [Paket İçeriği](#paket-i̇çeriği)
  - [Common](#common)
    - [Base Model](#base-model)
    - [Constants](#constants)
    - [Device Type](#device-type)
    - [Empty Object](#empty-object)
    - [Extensions](#extensions)
    - [Logger](#logger)
    - [Retriable](#retriable)
  - [Core](#core)
  - [Utils](#utils)
    - [App Settings](#app-settings)
    - [Device Info](#device-info)
    - [Input Formatter](#input-formatter)
    - [Jwt Decoder](#jwt-decoder)
    - [Network Manager](#network-manager)
    - [Overlay Manager](#overlay-manager)
    - [Package Info](#package-info)
    - [Path Provider](#path-provider)
    - [Permission Manager](#permission-manager)
    - [Popup Manager](#popup-manager)
    - [Share](#share)
    - [Shared Preferences Manager](#shared-preferences-manager)
    - [Sqflite Manager](#sqflite-manager)
    - [Url Launcher](#url-launcher)
  - [Widgets](#widgets)
    - [Builder](#builder)
    - [Buttons](#buttons)
    - [Data Provider](#data-provider)
    - [Image Viewer](#image-viewer)
    - [ListView](#listview)
    - [Relative Size](#relative-size)
    - [Reorderable List View](#reorderable-list-view)
    - [Responsive Layout](#responsive-layout)
    - [Single Child Scroll View](#single-child-scroll-view)
    - [Sized Box](#sized-box)
    - [Text](#text)
    - [Text Field](#text-field)

<br>

# Paket Kurulumu

---

- Kullanılacak projede `paket ismi`, `url bilgisi` ve `ref` aşağıdaki gibi `pubspec.yaml` dosyasına eklenir. Ekranda çıkan kullanıcı adı ve şifre alanına devops bilgileri girilmelidir.

- pubspec.yaml

```yaml
flutter_core:
  git:
    url: https://devops.ozdilek.com.tr/OZVERIDEVOPS/Ozveri-Mobile/_git/Ozd-Core
    ref: development # Buraya en güncel versiyon'da eklenebilir.
```

<br>

# Paket İçeriği

## Common

---

<br>

### Base Model

- `Json Serializable` yapılacak olan her model `BaseModel`'den kalıtılmalıdır. Network modellerinde genel olarak `toJson` ve `fromJson` yapıldığı için bu modelden kalıtılmıştır.

<br>

### Constants

- Uygulamada tasarım aşamasında kullanılması için temel olarak `emptyBox`, `largeBox`, `verticalBox` ve `horizontalBox` gibi sabitler burada tanımlanmıştır. Buradaki içerik daha da zenginleştirilebilir.

<br>

### Device Type

- `DeviceType.deviceType` static bir getter fonksiyonudur. Ekran boyutlarına göre bize cihazın telefon, tablet ya da masaüstü bilgisini verir. Ayrıca `isTablet()` ve `isHuawei()` gibi fonksiyonları da içermektedir.

<br>

### Empty Object

- `EmptyObject` boş bir sınıftır. Genelde `Insert`, `Update`, `Delete` ve `BulkUpsert` gibi servisler geriye data dönmezler. Bu servislere Response Model verebilmek için hazırlanmıştır.

<br>

### Extensions

- Her projede ihtiyaç olan fakat flutter'da gömülü olmayan önemli `extension`'ları içerir. Bunlar `BuildContext`, `DateTime` ve `Duration` gibi sınıfların `extension`'larıdır.

<br>

### Logger

- Uzun metinleri karakter sınırlamasına takılmadan console'a renkli bir şekilde yazdırmak için kullanılır. `NetworkManager`'da kullanılmıştır.

<br>

### Retriable

- Bir fonksiyon hata alma durumuna göre birden fazla kez çalıştırmak istendiğinde bu sınıf yardımıyla default'da 3 kez istenirse verilen parametre değeri kadar fonksiyon çalıştırılmaktadır. Eğer ki başarılı sonuç alınmışsa tekrar çağırılmaz son başarılı sonuç döner. Splash ekranlarında servisler hataya düşerse tekrar tekrar istek atılabilmesi için eklenmiştir.

<br>

## Core

---

- Projelerde genel olarak kullandığımız fonksiyonları içermektedir. `closeKeyboard`, `doubleToCurrency` ve `updateApp` gibi fonksiyonlar içerimektedir. `initialize` fonksiyonu `runApp` fonksiyonundan önce çağırılmalıdır.

<br>

## Utils

---

<br>

### App Settings

- Telefon ayarlar ekranında herhangi bir ayarın detayına gitmek için kullanılır.

<br>

### Device Info

- Cihaz ve işletim sistemi bilgilerini almak için kullanılır.

<br>

### Input Formatter

- TextField içerisindeki metni maskelemek için yazıldı. Örnek: Telefon numarası (5XX XXX XXXX).

<br>

### Jwt Decoder

- Token içeriğini decode etmek için eklendi.

<br>

### Network Manager

- Network altyapısı tüm projelerde standart olması için `CoreNetworkManager` sınıfı yazılmıştır. Tüm projeler Network işlemlerini bu sınıfı kalıtarak yapmaktadır.

<br>

### Overlay Manager

- `Toast` gibi UI componentlerinin gösterilmesi için yazıldı. Örneğin projede `Toast` dışında custom bir component gösterilmek isteniyor. Bunun için `showOverlay` fonksiyonu kullanılmalıdır. Buraya builder ve id verilip verilen id üzerinden widget show ve hide işlemi yapılabilmektedir.

<br>

### Package Info

- Uygulamanın `appName`, `packageName`, `version` ve `buildNumber` gibi bilgilerini alabilmek için kullanılır.

<br>

### Path Provider

- Telefon dosya sisteminin path'lerini almak için eklendi.

<br>

### Permission Manager

- Proje izin yönetimini standardize etmek için yazılmıştır.

<br>

### Popup Manager

- Projelerde gösterilecek `Loader`, `Dialog` ve `Bottom Sheet`'leri aynı yapıda kullanabilmek için eklenmiştir. `AdaptiveInfoDialog`, `DefaultAdaptiveAlertDialog`, `AdaptiveDatePicker`, `AdaptivePicker`, `UpdateAvailableDialog` ve `AdaptiveInputDialog` gibi işletim sistemi uyumlu dialog'lar eklenmiştir. Bu popup'ların hepsine id verilerek istenilen sırayla kapatılabilmesi mümkündür.

<br>

### Share

- İşletim sisteminin dosya paylaşma ekranı üzerinden dosya paylaşmak için kullanılır.

<br>

### Shared Preferences Manager

- Projelerde SharedPrefrences kullanımını standartlaştırmak için yazılmıştır. Veriler şifrelenmiş bir şekilde kaydedilebilir. Alıştığımız Shared'ın dışında liste ve sınıfları kayıt edebilmekteyiz.

<br>

### Sqflite Manager

- Sqlite veritabanını tüm projelerde standart kalıplarla kullanabilmek için yazılmıştır. Farklı olarak select komutu çalıştırıldığında veri tabanından gelen map'i manager içerisinde serializable edebilmekteyiz.

<br>

### Url Launcher

- Telefonun içerisindeki `Email`, `Phone`, `Sms` ve `Store` gibi uygulamaları açmak için yazılmıştır. DeepLink işlemleri'de buradan yapılmaktadır.

<br>

## Widgets

---

<br>

### Builder

- `CoreBuilder` `MaterialApp`'in builder'i içerisine eklenmesi gereken bir widget'tır. `ValueNotifier` kullanarak ekranda indicator gösterimi yapılmaktadır. Ekranda boş bir yere tıklandığında klavye kapatma işlemi yapmaktadır.

<br>

### Buttons

- Material butonlarının android ve ios platformlarında tıklanma efektini adaptive yapmak için hazırlanmıştır. Android'de splash efekti varken iOS'da opacity efekti vardır. Flutter'ın default material butonları yerine bu butonlar kullanılmalıdır.

<br>

### Data Provider

- `DataProvider`, tek bir veri nesnesini `data` widget ağacı boyunca paylaşır. `DataProviderExtension` ile bir uzantı fonksiyonu eklenir, böylece widget'lar `context.get<T>()` kullanarak belirli türdeki veriyi kolayca alabilir. Bu yapı, uygulamada belirli veri türlerini widget ağacı içinde taşımayı ve paylaşmayı kolaylaştırır.

<br>

### Image Viewer

- `CoreImageViewer`, Flutter uygulamalarında kullanıcıların resimleri etkili bir şekilde görüntüleyebilmeleri için tasarlanmış güçlü bir widget'tır. Hem ağ (`network`) üzerinden, hem cihazın yerel depolamasından (`asset`, `file`), hem de bellekten (`memory`) görüntüleri destekler. Çeşitli özelleştirme seçenekleri sunar; arka plan rengini, görüntü yükleme ve hata durumları için özel widget'ları, yakınlaştırma ve kaydırma özelliklerini, sayfa göstergelerini ve kapatma düğmelerini içerecek şekilde yapılandırılabilir. Ayrıca, dikey sürükleme hareketiyle uygulamayı kapatma işlevselliği de sağlar. Kullanıcılar, çift dokunma ve sürükleme gibi etkileşimlerle resimleri yakınlaştırabilir ve kaydırabilir, böylece görseller üzerinde tam kontrol sahibi olabilirler. Bu widget, kullanıcıların görselleri daha etkileyici ve kullanışlı bir şekilde deneyimlemesine olanak tanır.

<br>

### ListView

- `CoreListView`, `CoreListView.builder` ve `CoreListView.separated` işlevselliklerini birleştirir. `ScrollController` kullanarak liste sonuna ulaşıldığında daha fazla veri yüklemeyi tetikleyen lazy loading işlevi ekler. Ayrıca, liste sonuna yaklaşıldığında bir yükleme göstergesi (`CircularProgressIndicator`) ekler. Kullanıcı, widget'ı yapılandırırken kaydırma yönü, öğe yapısı, öğe aralıkları ve daha fazlasını özelleştirebilir. `onReachedEnd` fonksiyonu, daha fazla veri yüklemek için kullanılır. `onRefresh` parametresi verilir ise `Android` ve `iOS`'a özel adaptif `Pull to Refresh` özelliği kazandırır.

<br>

### Relative Size

- `CoreRelativeHeight` ve `CoreRelativeWidth`, Flutter uygulamalarında göreceli boyutlandırma sağlayan iki widget'tır. `CoreRelativeHeight`, ekran yüksekliğinin belirli bir yüzdesine göre yükseklik ayarlar. `CoreRelativeWidth` ise ekran genişliğinin belirli bir yüzdesine göre genişlik ayarlar. Her iki widget da, yüzde değerlerinin 0 ile 1 arasında olmasını gerektirir, bu da kullanıcıların çeşitli ekran boyutlarında esnek ve duyarlı tasarımlar oluşturmasını sağlar.

<br>

### Reorderable List View

- Flutter'da yeniden sıralanabilir `Reorderable` bir liste oluşturmak için yazılmıştır. İki ana tür (`normal` ve `builder`) sunar ve liste elemanlarının sıralanmasını sağlar. Temel Parametreler: `itemBuilder`, `itemCount`, `onReorder`, `onReorderStart`, `onReorderEnd` gibi parametrelerle liste elemanlarının oluşturulmasını ve sıralanmasını yönetir. `onReachedEnd` ile listenin sonuna ulaşıldığında yapılacak işlemleri tanımlar. Widget Yapısı: Liste elemanları `ReorderableListView` veya `ReorderableListView.builder` aracılığıyla oluşturulur. `Material` widget'ı ile liste elemanlarına `elevation` animasyonu ekler. Özelleştirme: `proxyDecorator`, `autoScrollerVelocityScalar`, `dragStartBehavior`, `keyboardDismissBehavior`, `clipBehavior` gibi ek özelliklerle liste davranışını ve stilini özelleştirir. Scroll ve Refresh: Özel kaydırma ve yenileme davranışları için `ScrollController`, `RefreshIndicator` ve `CupertinoSliverRefreshControl` kullanılır. Bu yapı, Flutter uygulamalarında yeniden sıralanabilir, esnek ve özelleştirilebilir listeler oluşturmayı sağlar.

<br>

### Responsive Layout

- `CoreResponsiveLayout`, Flutter uygulamalarında cihaz türüne göre farklı arayüzler sunmayı sağlar. Telefon, tablet ve masaüstü cihazlar için ayrı düzenler tanımlanabilir. DeviceType sınıfı, cihaz türünü belirler ve uygun düzeni seçer. Bu widget, her cihazda optimize edilmiş ve uyumlu bir kullanıcı deneyimi sağlar.

<br>

### Single Child Scroll View

- Bu `CoreSingleChildScrollView` sınıfı, Android ve iOS platformlarına özgü kaydırma ve yenileme işlevselliğini sağlayan bir Flutter bileşenidir. Android'de, `RefreshIndicator` ile sarmalanmış bir `SingleChildScrollView` kullanırken, iOS'ta `CupertinoSliverRefreshControl` ve `CustomScrollView` kullanır. Kullanıcı kaydırma hareketiyle içeriği yenileyebilir.

<br>

### Sized Box

- `CoreSizedBox`, Flutter'da boyutlandırma için kullanılan bir widget'tır. Standart `SizedBox`'un özelliklerini genişletir ve ek operatörler sağlar. `CoreSizedBox`, genişlik ve yükseklik değerlerini toplama (+) ve çıkarma (-) operatörleriyle ayarlama imkanı sunar. Ayrıca, `shrink` ve `expand` gibi hazır yapıcılar içerir, bu da çeşitli boyutlandırma senaryolarında esneklik sağlar.

<br>

### Text

- `CoreAutoSizeText`, Flutter uygulamalarında metin boyutunu otomatik olarak ayarlayan bir widget'tır. `CoreAutoSizeText`, metin boyutunu verilen sınırlar içinde tutarak okunabilirliği artırır ve aşırı büyük metinlerin taşmasını engeller. Ayrıca, minimum font boyutu, metin yönü, hizalama gibi çeşitli parametrelerle özelleştirilebilir. Bu widget, metin boyutunu otomatik olarak ayarlayarak kullanıcı arayüzünde daha esnek ve duyarlı tasarımlar oluşturmayı sağlar.

- `CoreText` adında bir Flutter widget'ını tanımlar. `CoreText`, çeşitli metin stillerini destekler ve farklı ekran boyutlarına uyum sağlar. Kullanıcılar, `CoreText.displayLarge`, `CoreText.headlineSmall`, `CoreText.bodyMedium` gibi çeşitli ön tanımlı stillerle metin oluşturabilirler. Metin rengi, hizalaması, yönü, ve taşması gibi özellikler ayarlanabilir.

<br>

### Text Field

- `CoreCreditCardExpirationTextField`: Bu sınıf, kredi kartı son kullanma tarihini girmek için bir `TextFormField` widget'ıdır. Tarih formatını (##/##) otomatik olarak uygulamak için bir maske kullanır ve kullanıcı girdilerini yalnızca sayılarla sınırlar.

- `CoreCreditCardSecurityCodeTextField`: Bu sınıf, kredi kartı güvenlik kodunu (CVV) girmek için bir `TextFormField` widget'ıdır. Girdiyi 4 karakterle sınırlar ve yalnızca sayısal karakterlere izin verir.

- `CoreCreditCardTextField`: Bu sınıf, kredi kartı numarasını girmek için bir `TextFormField` widget'ıdır. Kredi kartı numarası formatını (#### #### #### ####) otomatik olarak uygulamak için bir maske kullanır ve kullanıcı girdilerini yalnızca sayılarla sınırlar.

- `CoreCurrencyTextField`: Bu sınıf, para birimi girdisi için bir `TextFormField` widget'ıdır. Girdiyi ondalık sayıya göre biçimlendirir ve odağa alındığında tüm metni seçer, odaktan çıkıldığında girdiyi belirli bir ondalık sayıya göre biçimlendirir.

- `CorePasswordTextField`: Bu sınıf, şifre girmek için bir `TextFormField` widget'ıdır. Şifrenin gizli görünmesini sağlar ve kullanıcıya şifreyi gösterme/gizleme seçeneği sunar.

- `CorePhoneNumberTextField`: Bu sınıf, telefon numarası girmek için bir `TextFormField` widget'ıdır. Telefon numarası formatını (### ### ## ##) otomatik olarak uygulamak için bir maske kullanır ve kullanıcı girdilerini yalnızca sayılarla sınırlar.

- `CoreSearchTextField`: Bu sınıf, arama yapmak için bir `TextFormField` widget'ıdır. Kullanıcının metin girdisine göre bir iptal düğmesi gösterir ve bu düğme metni temizlemek için kullanılabilir.
