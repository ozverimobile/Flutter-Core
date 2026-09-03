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
    - [Maintenance Manager](#maintenance-manager)
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
    - [Ülke Seçimli Telefon Alanı](#ülke-seçimli-telefon-alanı)

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

### Maintenance Manager

- Firebase Remote Config üzerinden bakım modu kontrolü yapmak için eklenmiştir. `Core.initialize`'dan tamamen bağımsızdır; `CoreMaintenanceManager.instance.checkMaintenanceMode` çağrılmadığı sürece hiçbir etkisi yoktur. Aynı şekilde Firebase kurulu değilse, remote config instance'ı hazır değilse veya fetch başarısız olursa fonksiyon sessizce hiçbir şey yapmadan geri döner.
- Remote Config'te `remoteConfigInstance` projenin kendisi tarafından oluşturulup parametre olarak verilir (fetch interval, default değerler vb. tamamen projenin kontrolündedir).
- `maintenance_mode` adında bir Remote Config key'i beklenir. Değeri aşağıdaki alanları içeren bir JSON string olmalıdır:

  ```json
  {
    "isMaintenanceModeActive": true,
    "title": "Bakım Çalışması",
    "content": "Uygulamamız kısa süreliğine bakımdadır.",
    "maintenanceIcon": "https://example.com/maintenance.png",
    "userIds": ["12345", "67890"],
    "url": "https://example.com/status"
  }
  ```

  - `isMaintenanceModeActive`: `true` değilse (null veya false) hiçbir şey gösterilmez.
  - `title` / `content`: `null` bırakılırsa paket varsayılan bir metin gösterir.
  - `maintenanceIcon`: `null` bırakılırsa varsayılan bir bakım ikonu gösterilir.
  - `userIds`: doluysa yalnızca `checkMaintenanceMode`'a verilen `currentUserId` bu listede varsa ekran gösterilir; `null`/boşsa herkese gösterilir.
  - `url`: doluysa varsayılan ekranda birincil aksiyon "Daha Fazla Bilgi" olur ve basılınca `CoreUrlLauncher` ile bu url açılır; altında ikincil bir "Tekrar Dene" metin butonu belirir (yalnızca `onRetry` verildiyse). `url` boşsa birincil aksiyon doğrudan "Tekrar Dene" olur.

- Ekran tam sayfa, kapatılamayan (`PopScope(canPop: false)`) bir dialog olarak açılır; kullanıcı sistem geri tuşuyla veya barrier'a dokunarak kapatamaz. Basılan "Tekrar Dene" remote config'i yeniden fetch eder: bakım modu hâlâ aktifse ekran açık kalır, aktif değilse otomatik kapanır. Varsayılan tasarım yeterli değilse `builder` parametresiyle projeye özgü bir tasarım verilebilir; builder'a da aynı retry callback'i (ve `info.url` üzerinden) aynı veriler geçilir.

  ```dart
  await CoreMaintenanceManager.instance.checkMaintenanceMode(
    context: context,
    remoteConfigInstance: myRemoteConfig,
    currentUserId: currentUser?.id,
    // builder: (context, info, onRetry) => MyCustomMaintenanceView(info: info, onRetry: onRetry),
  );
  ```

- Ekranı gören kullanıcıları loglamak için `onShown` callback'i verilebilir; ekran her açıldığında (fetch başarılı ve bakım aktifse) bir kez çağrılır. Paket herhangi bir analytics/logging aracını kendi sahiplenmez — hangi araç kullanılıyorsa (Firebase Analytics, kendi backend'iniz, vb.) çağrısı burada yapılır:

  ```dart
  await CoreMaintenanceManager.instance.checkMaintenanceMode(
    context: context,
    remoteConfigInstance: myRemoteConfig,
    currentUserId: currentUser?.id,
    onShown: (info) => FirebaseAnalytics.instance.logEvent(
      name: 'maintenance_mode_shown',
      parameters: {'title': info.title ?? ''},
    ),
  );
  ```

- Varsayılan görünümdeki illüstrasyon, pakete `assets/maintenance/maintenance_illustration.png` yolunda gömülüdür (bulunamazsa varsayılan bir ikona düşer). `maintenanceIcon` remote config'te verilirse onun yerine gösterilir.

- Varsayılan tasarımın renkleri projenin kendi `Theme`'inden gelir (ekstra parametre gerekmez): arka plan projenin `scaffoldBackgroundColor`'ı (düz renk), metinler `onSurface`/`onSurfaceVariant`, butonlar `primary`/`onPrimary` kullanır — böylece hangi tema verilirse verilsin kontrast Material'ın kendi "on" renkleriyle garanti altına alınmış olur, ayrıca metin/buton rengi için ayrı parametre geçmeye gerek kalmaz. Dekoratif renk lekeleri `colorScheme.secondary`/`colorScheme.tertiary`'den türetilir. Bir projeye göre renk uymuyorsa, o projenin `ColorScheme`'ini/`ThemeData`'sını güncellemek yeterlidir.

- İçerik ekranın altına yaslıdır; başlık/içerik metni uzayıp ekrana sığmazsa otomatik olarak scroll olur, kısa olduğunda ise alt kısımda sabit durur.

- Remote Config'e gitmeden, elde hazır bir `MaintenanceModeInfo` ile ekranı doğrudan göstermek için (test/QA amaçlı, örneğin) `showMaintenanceMode` kullanılabilir:

  ```dart
  await CoreMaintenanceManager.instance.showMaintenanceMode(
    context: context,
    info: const MaintenanceModeInfo(isMaintenanceModeActive: true),
    // onRetry veriliyorsa varsayılan görünümde "Tekrar Dene" butonu belirir.
  );
  ```

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

- `CorePhoneNumberTextField.withCountryPicker`: Aynı alanın ülke seçimli hâlidir. Ayrıntılar için bkz. [Ülke Seçimli Telefon Alanı](#ülke-seçimli-telefon-alanı).

- `CoreSearchTextField`: Bu sınıf, arama yapmak için bir `TextFormField` widget'ıdır. Kullanıcının metin girdisine göre bir iptal düğmesi gösterir ve bu düğme metni temizlemek için kullanılabilir.

<br>

### Ülke Seçimli Telefon Alanı

`CorePhoneNumberTextField.withCountryPicker`, telefon alanının ülke seçimli hâlidir. Alanın solundaki bayrak + ülke kodu butonuna basıldığında tam sayfa, aranabilir bir ülke seçim sayfası (bottom sheet) açılır. Seçilen ülkeye göre maske otomatik güncellenir.

Varsayılan `CorePhoneNumberTextField` kullanımına **hiç dokunulmamıştır**; mevcut ekranlar aynen çalışmaya devam eder.

Öne çıkanlar:

- Alandaki metin **yalnızca ulusal numarayı** tutar; ülke kodu solda ayrı gösterilir.
- 223 ülke, her biri kendi maskesiyle (`TR` -> `### ### ## ##`, `DE` -> `#### #######`).
- Bayraklar asset değildir; ISO kodundan emoji olarak üretilir.
- Ülke adları cihazın kendi dil verisinden gelir, uygulama dili değişince kendiliğinden güncellenir.

#### Kullanım

```dart
CorePhoneNumberTextField.withCountryPicker(
  hintText: 'Telefon',
  initialCountryIsoCode: 'TR', // varsayılan ülke
  onCountryChanged: (country) => print(country.isoCode),
  onPhoneNumberChanged: (phone) {
    phone.country.isoCode;   // TR
    phone.number;            // 5551112233
    phone.completeNumber;    // +905551112233
    phone.isValid;           // maske tamamen dolduysa true
  },
  phoneNumberValidator: (phone) => phone.isValid ? null : 'Geçersiz numara',
  countryPickerOptions: CoreCountryPickerOptions(
    title: 'Ülke Seçin',
    searchHintText: 'Ülke arayın...',
    favoriteIsoCodes: ['TR', 'DE'], // listenin başına sabitlenir
  ),
)
```

#### `CorePhoneNumberController`

`TextEditingController` yerine kullanılır; ülke ve numarayı tek yerden okumayı/yazmayı sağlar. `controller.text` aynen çalışmaya devam eder. Alana verildiğinde ülke seçimi ile controller birbirini otomatik günceller.

```dart
final controller = CorePhoneNumberController(isoCode: 'TR');

CorePhoneNumberTextField.withCountryPicker(controller: controller);

controller.text;                    // 555 111 22 33   (maskeli ulusal numara)
controller.number;                  // 5551112233
controller.country.isoCode;         // TR
controller.completeNumber;          // +905551112233   (numara boşsa '')
controller.formattedCompleteNumber; // +90 555 111 22 33
controller.isValid;                 // maske doldu mu
controller.phoneNumber;             // CorePhoneNumber

controller.country = CoreCountry.fromIsoCode('DE')!; // maske otomatik güncellenir
controller.number = '5551112233';
controller.clearNumber();           // numarayı temizler, ülkeyi korur
```

Controller bir `ChangeNotifier` olduğu için `addListener` ile ülke/numara değişimleri dinlenebilir.

#### Ülke adları ve dil

Ülke adları **cihazın kendi dil verisinden** (ICU) alınır; ne pakette ne de projede çeviri tutmak gerekir. iOS, macOS ve Android'de çalışır; diğer platformlarda paket içindeki `tr` / `en` adlarına düşülür.

Kullanıcı uygulama içinden dili değiştirdiğinde **ekstra bir şey yapmanız gerekmez**: ad `Localizations.localeOf(context)` üzerinden çözüldüğü için `MaterialApp.locale` değişimi ülke adlarını ve listenin alfabetik sırasını otomatik günceller. Yeni dilin adları arka planda yüklenir, hazır olduğunda liste kendini yeniler.

Çözümleme sırası:

1. `CoreCountryPickerOptions.nameResolver` (ekrana özel, en öncelikli)
2. `CoreCountryLocalizations.register(...)` ile elle kaydedilmiş adlar
3. Cihazdan gelen yerelleştirilmiş ad
4. Paket içindeki `tr` / `en` adları

Sadece belirli bir adı düzeltmek isterseniz:

```dart
CoreCountryLocalizations.register('tr', {'MK': 'Kuzey Makedonya'});
```

Cihazdan ad okumayı tamamen kapatmak için `CoreCountryLocalizations.useSystemNames = false;` yeterlidir.

> Seçim sayfasının başlığı ve arama placeholder'ı sabit metindir; çok dilli uygulamalarda bunları `CoreCountryPickerOptions` üzerinden kendi çevirinizle vermelisiniz.

#### `CoreCountryPickerSheet`

Ülke seçim sayfası alandan bağımsız olarak da kullanılabilir:

```dart
final country = await CoreCountryPickerSheet.show(
  context,
  selected: seciliUlke,
  options: const CoreCountryPickerOptions(favoriteIsoCodes: ['TR']),
);
```

`CoreCountryPickerOptions` başlıca seçenekleri:

| Seçenek | Açıklama |
| --- | --- |
| `title`, `searchHintText`, `emptyResultText` | Sayfadaki metinler |
| `countries` | Listelenecek ülkeler (varsayılan: `kCoreCountries`) |
| `favoriteIsoCodes` | Listenin başına sabitlenecek ülkeler |
| `showDialCode`, `showCloseButton`, `showDragHandle` | Görünüm anahtarları |
| `flagShape` | Bayrak şekli (`circle` / `rounded`) |
| `borderRadius`, `backgroundColor`, `barrierColor` | Sayfa görünümü |
| `isDismissible`, `enableDrag`, `useRootNavigator` | Sayfa davranışı |
| `nameResolver` | Ülke adını özelleştirir |
| `itemBuilder` | Liste satırını tamamen özelleştirir |

#### `CoreCountry` ve `CoreCountryFlag`

`CoreCountry`; ISO kodu, ülke kodu, ad ve maske bilgisini taşır. `CoreCountry.fromIsoCode('TR')` ve `CoreCountry.fromDialCode('+90')` ile erişilir; tüm liste `kCoreCountries` sabitindedir.

`CoreCountryFlag` bayrağı tek başına çizmek için kullanılır. `CoreCountryFlagShape.circle` (varsayılan) bayrağı daireye sığdırır ve kenarlardan bir miktar kırpar; `CoreCountryFlagShape.rounded` ise bayrağın tamamını kırpmadan gösterir. Alan ve seçim sayfası aynı şekli `CoreCountryPickerOptions.flagShape` üzerinden kullanır.

```dart
CoreCountryFlag(country: CoreCountry.fromIsoCode('TR')!, size: 28);
```
