// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appBarBacklog => 'Beklemede';

  @override
  String get appBarToDo => 'Yapılacak';

  @override
  String get appBarInProgress => 'Sürüyor';

  @override
  String get appBarDone => 'Bitti';

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
}
