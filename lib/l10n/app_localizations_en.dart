// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appBarBacklog => 'Backlog';

  @override
  String get appBarToDo => 'To Do';

  @override
  String get appBarInProgress => 'Progress';

  @override
  String get appBarDone => 'Done';

  @override
  String get appBarTaskDetails => 'Task Details';

  @override
  String appBarNSelected(Object count) {
    return '$count Selected';
  }

  @override
  String get searchComingSoon => 'Search mode coming soon!';

  @override
  String get settingsComingSoon => 'Settings mode coming soon!';

  @override
  String get taskColumnConnectionError => 'Connection Error!';

  @override
  String taskColumnNoTasks(Object statusName) {
    return 'No tasks in $statusName';
  }

  @override
  String get taskDetailDescription => 'Description';

  @override
  String get taskDetailAssignees => 'Assignees';

  @override
  String get formEditTaskTitle => 'Edit Task';

  @override
  String get formNewTaskTitle => 'New Task';

  @override
  String get formTitleHint => 'Title';

  @override
  String get formDescriptionHint => 'Description';

  @override
  String get formAssigneesHint => 'Assignees';

  @override
  String get formSelectDeadlineHint => 'Select Deadline';

  @override
  String get formSaveChanges => 'Save Changes';

  @override
  String get formCreateTask => 'Create Task';

  @override
  String formCannotBeEmpty(Object fieldName) {
    return '$fieldName cannot be empty';
  }

  @override
  String get formTaskUpdatedSuccess => 'Task updated! ✏️';

  @override
  String get formTaskCreatedSuccess => 'Task created! 🚀';

  @override
  String formError(Object errorMessage) {
    return 'Error: $errorMessage';
  }

  @override
  String viewModelAnErrorOccurredWhileLoadingTasks(Object error) {
    return 'An error occurred while loading tasks: $error';
  }

  @override
  String viewModelAdditionFailed(Object error) {
    return 'Addition failed: $error';
  }

  @override
  String viewModelUpdateFailed(Object error) {
    return 'Update failed: $error';
  }

  @override
  String get viewModelUpdateFailedRolledBack => 'Update failed, rolled back.';

  @override
  String viewModelDeletionFailed(Object error) {
    return 'Deletion failed: $error';
  }

  @override
  String viewModelBulkDeleteError(Object error) {
    return 'Bulk delete error: $error';
  }
}
