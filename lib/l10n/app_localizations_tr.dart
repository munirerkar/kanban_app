// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appBarBacklog => 'Backlog';

  @override
  String get appBarToDo => 'To Do';

  @override
  String get appBarInProgress => 'Progress';

  @override
  String get appBarDone => 'Done';

  @override
  String get appBarTaskDetails => 'Görev Detayları';

  @override
  String appBarNSelected(Object count) {
    return '$count Seçildi';
  }

  @override
  String get searchComingSoon => 'Arama yakında gelecek!';

  @override
  String get settingsComingSoon => 'Ayarlar yakında gelecek!';

  @override
  String get taskColumnConnectionError => 'Bağlantı Hatası!';

  @override
  String taskColumnNoTasks(Object statusName) {
    return '$statusName içinde görev yok';
  }

  @override
  String get taskDetailDescription => 'Açıklama';

  @override
  String get taskDetailAssignees => 'Atananlar';

  @override
  String get formEditTaskTitle => 'Görevi Düzenle';

  @override
  String get formNewTaskTitle => 'Yeni Görev';

  @override
  String get formTitleHint => 'Başlık';

  @override
  String get formDescriptionHint => 'Açıklama';

  @override
  String get formAssigneesHint => 'Atananlar';

  @override
  String get formSelectDeadlineHint => 'Bitiş Tarihi Seç';

  @override
  String get formSaveChanges => 'Değişiklikleri Kaydet';

  @override
  String get formCreateTask => 'Görevi Oluştur';

  @override
  String formCannotBeEmpty(Object fieldName) {
    return '$fieldName boş olamaz';
  }

  @override
  String get formTaskUpdatedSuccess => 'Görev güncellendi! ✏️';

  @override
  String get formTaskCreatedSuccess => 'Görev oluşturuldu! 🚀';

  @override
  String formError(Object errorMessage) {
    return 'Hata: $errorMessage';
  }

  @override
  String viewModelAnErrorOccurredWhileLoadingTasks(Object error) {
    return 'Görevler yüklenirken bir hata oluştu: $error';
  }

  @override
  String viewModelAdditionFailed(Object error) {
    return 'Ekleme başarısız: $error';
  }

  @override
  String viewModelUpdateFailed(Object error) {
    return 'Güncelleme başarısız: $error';
  }

  @override
  String get viewModelUpdateFailedRolledBack =>
      'Güncelleme başarısız oldu, değişiklikler geri alındı.';

  @override
  String viewModelDeletionFailed(Object error) {
    return 'Silme başarısız: $error';
  }

  @override
  String viewModelBulkDeleteError(Object error) {
    return 'Toplu silme hatası: $error';
  }

  @override
  String get bottomBarGoToWordNinja => 'Word Ninja\'ya Git';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Aydınlık';

  @override
  String get settingsThemeDark => 'Karanlık';

  @override
  String get settingsLanguageEnglish => 'İngilizce';

  @override
  String get settingsLanguageTurkish => 'Türkçe';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get settingsLicenses => 'Lisanslar';

  @override
  String get buyMeACoffee => 'Bana bir kahve ısmarla';

  @override
  String get searchHint => 'Görev ara...';

  @override
  String get deleteConfirmationTitle => 'Silmeyi Onayla';

  @override
  String deleteConfirmationMessage(Object count) {
    return 'Seçili $count görevi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get deleteButton => 'Sil';

  @override
  String get cancelButton => 'İptal';

  @override
  String get authInvalidCredentials => 'E-posta veya şifre hatalı.';

  @override
  String get authUnexpectedLoginError =>
      'Giriş sırasında beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get authUnexpectedRegisterError =>
      'Kayıt sırasında beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get authUnexpectedLogoutError =>
      'Çıkış yapılırken beklenmeyen bir hata oluştu.';

  @override
  String get authNetworkErrorFallback =>
      'Ağ hatası oluştu. Lütfen tekrar deneyin.';

  @override
  String get loginWelcomeTitle => 'Hoş Geldin';

  @override
  String get loginSubtitle => 'Kanban hesabına giriş yap';

  @override
  String get loginEmailLabel => 'E-posta';

  @override
  String get loginEmailRequired => 'E-posta alanı boş bırakılamaz';

  @override
  String get loginPasswordLabel => 'Şifre';

  @override
  String get loginPasswordRequired => 'Şifre alanı boş bırakılamaz';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get loginNoAccountCta => 'Hesabın yok mu? Kayıt Ol';

  @override
  String get registerAppBarTitle => 'Kayıt Ol';

  @override
  String get registerTitle => 'Yeni Hesap Oluştur';

  @override
  String get registerSubtitle => 'Bilgilerini girerek devam et';

  @override
  String get registerFirstNameLabel => 'İsim';

  @override
  String get registerFirstNameRequired => 'İsim alanı boş bırakılamaz';

  @override
  String get registerLastNameLabel => 'Soyisim';

  @override
  String get registerLastNameRequired => 'Soyisim alanı boş bırakılamaz';

  @override
  String get registerEmailLabel => 'E-posta';

  @override
  String get registerEmailRequired => 'E-posta alanı boş bırakılamaz';

  @override
  String get registerEmailInvalid => 'Geçerli bir e-posta adresi gir';

  @override
  String get registerPasswordLabel => 'Şifre';

  @override
  String get registerPasswordRequired => 'Şifre alanı boş bırakılamaz';

  @override
  String registerPasswordMinLength(Object min) {
    return 'Şifre en az $min karakter olmalı';
  }

  @override
  String get registerConfirmPasswordLabel => 'Şifre Tekrarı';

  @override
  String get registerConfirmPasswordRequired =>
      'Şifre tekrarı alanı boş bırakılamaz';

  @override
  String get registerPasswordMismatch => 'Şifreler eşleşmiyor';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get registerSuccessSnackbar => 'Kayıt başarılı. Oturum açıldı.';

  @override
  String get profileAccountTitle => 'Hesap';

  @override
  String get profileLogoutButton => 'Çıkış Yap';

  @override
  String get profileUnknownName => 'Bilinmeyen Kullanıcı';

  @override
  String get profileUnknownEmail => 'E-posta bilgisi yok';

  @override
  String get workspaceDrawerTitle => 'Çalışma Alanları';

  @override
  String get workspaceDrawerNoWorkspaces =>
      'Henüz erişebildiğiniz bir çalışma alanı bulunmuyor';
}
