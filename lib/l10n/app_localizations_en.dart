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

  @override
  String get bottomBarGoToWordNinja => 'Go to Word Ninja';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageTurkish => 'Turkish';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLicenses => 'Licenses';

  @override
  String get buyMeACoffee => 'Buy me a coffee';

  @override
  String get searchHint => 'Search tasks...';

  @override
  String get deleteConfirmationTitle => 'Confirm Deletion';

  @override
  String deleteConfirmationMessage(Object count) {
    return 'Are you sure you want to delete $count selected tasks? This action cannot be undone.';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get authInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get authUnexpectedLoginError =>
      'An unexpected error occurred during login. Please try again.';

  @override
  String get authUnexpectedRegisterError =>
      'An unexpected error occurred during registration. Please try again.';

  @override
  String get authUnexpectedLogoutError =>
      'An unexpected error occurred while logging out.';

  @override
  String get authNetworkErrorFallback =>
      'A network error occurred. Please try again.';

  @override
  String get loginWelcomeTitle => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in to your Kanban account';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailRequired => 'Email field cannot be empty';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordRequired => 'Password field cannot be empty';

  @override
  String get loginButton => 'Login';

  @override
  String get loginNoAccountCta => 'Don’t have an account? Register';

  @override
  String get registerAppBarTitle => 'Register';

  @override
  String get registerTitle => 'Create New Account';

  @override
  String get registerSubtitle => 'Enter your details to continue';

  @override
  String get registerFirstNameLabel => 'First Name';

  @override
  String get registerFirstNameRequired => 'First name field cannot be empty';

  @override
  String get registerLastNameLabel => 'Last Name';

  @override
  String get registerLastNameRequired => 'Last name field cannot be empty';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailRequired => 'Email field cannot be empty';

  @override
  String get registerEmailInvalid => 'Enter a valid email address';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordRequired => 'Password field cannot be empty';

  @override
  String registerPasswordMinLength(Object min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get registerConfirmPasswordLabel => 'Confirm Password';

  @override
  String get registerConfirmPasswordRequired =>
      'Confirm password field cannot be empty';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get registerButton => 'Register';

  @override
  String get registerSuccessSnackbar => 'Registration successful. Logged in.';

  @override
  String get profileAccountTitle => 'Account';

  @override
  String get profileLogoutButton => 'Logout';

  @override
  String get profileUnknownName => 'Unknown User';

  @override
  String get profileUnknownEmail => 'Email not available';

  @override
  String get workspaceDrawerTitle => 'Workspaces';

  @override
  String get workspaceDrawerNoWorkspaces =>
      'There is no workspace available for your account yet';

  @override
  String get workspaceDrawerMyWorkspaces => 'My Workspaces';

  @override
  String get workspaceDrawerSharedWithMe => 'Shared with Me';

  @override
  String get workspaceActionEdit => 'Edit';

  @override
  String get workspaceActionDelete => 'Delete';

  @override
  String get workspaceActionLeave => 'Leave';

  @override
  String workspaceOwnerLabel(Object ownerName) {
    return 'Owner: $ownerName';
  }

  @override
  String workspaceDeleteConfirmationMessage(Object workspaceName) {
    return 'Are you sure you want to delete workspace \"$workspaceName\"? This action cannot be undone.';
  }

  @override
  String workspaceLeaveConfirmationMessage(Object workspaceName) {
    return 'Are you sure you want to leave workspace \"$workspaceName\"?';
  }
}
