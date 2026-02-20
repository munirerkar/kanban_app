import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appBarBacklog.
  ///
  /// In en, this message translates to:
  /// **'Backlog'**
  String get appBarBacklog;

  /// No description provided for @appBarToDo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get appBarToDo;

  /// No description provided for @appBarInProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get appBarInProgress;

  /// No description provided for @appBarDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get appBarDone;

  /// No description provided for @appBarTaskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get appBarTaskDetails;

  /// No description provided for @appBarNSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String appBarNSelected(Object count);

  /// No description provided for @searchComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Search mode coming soon!'**
  String get searchComingSoon;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings mode coming soon!'**
  String get settingsComingSoon;

  /// No description provided for @taskColumnConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error!'**
  String get taskColumnConnectionError;

  /// No description provided for @taskColumnNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks in {statusName}'**
  String taskColumnNoTasks(Object statusName);

  /// No description provided for @taskDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDetailDescription;

  /// No description provided for @taskDetailAssignees.
  ///
  /// In en, this message translates to:
  /// **'Assignees'**
  String get taskDetailAssignees;

  /// No description provided for @formEditTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get formEditTaskTitle;

  /// No description provided for @formNewTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get formNewTaskTitle;

  /// No description provided for @formTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get formTitleHint;

  /// No description provided for @formDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get formDescriptionHint;

  /// No description provided for @formAssigneesHint.
  ///
  /// In en, this message translates to:
  /// **'Assignees'**
  String get formAssigneesHint;

  /// No description provided for @formSelectDeadlineHint.
  ///
  /// In en, this message translates to:
  /// **'Select Deadline'**
  String get formSelectDeadlineHint;

  /// No description provided for @formSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get formSaveChanges;

  /// No description provided for @formCreateTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get formCreateTask;

  /// No description provided for @formCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} cannot be empty'**
  String formCannotBeEmpty(Object fieldName);

  /// No description provided for @formTaskUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task updated! ✏️'**
  String get formTaskUpdatedSuccess;

  /// No description provided for @formTaskCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task created! 🚀'**
  String get formTaskCreatedSuccess;

  /// No description provided for @formError.
  ///
  /// In en, this message translates to:
  /// **'Error: {errorMessage}'**
  String formError(Object errorMessage);

  /// No description provided for @viewModelAnErrorOccurredWhileLoadingTasks.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading tasks: {error}'**
  String viewModelAnErrorOccurredWhileLoadingTasks(Object error);

  /// No description provided for @viewModelAdditionFailed.
  ///
  /// In en, this message translates to:
  /// **'Addition failed: {error}'**
  String viewModelAdditionFailed(Object error);

  /// No description provided for @viewModelUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String viewModelUpdateFailed(Object error);

  /// No description provided for @viewModelUpdateFailedRolledBack.
  ///
  /// In en, this message translates to:
  /// **'Update failed, rolled back.'**
  String get viewModelUpdateFailedRolledBack;

  /// No description provided for @viewModelDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed: {error}'**
  String viewModelDeletionFailed(Object error);

  /// No description provided for @viewModelBulkDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Bulk delete error: {error}'**
  String viewModelBulkDeleteError(Object error);

  /// No description provided for @bottomBarGoToWordNinja.
  ///
  /// In en, this message translates to:
  /// **'Go to Word Ninja'**
  String get bottomBarGoToWordNinja;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get settingsLanguageTurkish;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get settingsLicenses;

  /// No description provided for @buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get buyMeACoffee;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchHint;

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get deleteConfirmationTitle;

  /// No description provided for @deleteConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} selected tasks? This action cannot be undone.'**
  String deleteConfirmationMessage(Object count);

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authUnexpectedLoginError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during login. Please try again.'**
  String get authUnexpectedLoginError;

  /// No description provided for @authUnexpectedRegisterError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during registration. Please try again.'**
  String get authUnexpectedRegisterError;

  /// No description provided for @authUnexpectedLogoutError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while logging out.'**
  String get authUnexpectedLogoutError;

  /// No description provided for @authNetworkErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Please try again.'**
  String get authNetworkErrorFallback;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginWelcomeTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Kanban account'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email field cannot be empty'**
  String get loginEmailRequired;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password field cannot be empty'**
  String get loginPasswordRequired;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginNoAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? Register'**
  String get loginNoAccountCta;

  /// No description provided for @registerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerAppBarTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to continue'**
  String get registerSubtitle;

  /// No description provided for @registerFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get registerFirstNameLabel;

  /// No description provided for @registerFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name field cannot be empty'**
  String get registerFirstNameRequired;

  /// No description provided for @registerLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get registerLastNameLabel;

  /// No description provided for @registerLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name field cannot be empty'**
  String get registerLastNameRequired;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email field cannot be empty'**
  String get registerEmailRequired;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get registerEmailInvalid;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password field cannot be empty'**
  String get registerPasswordRequired;

  /// No description provided for @registerPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String registerPasswordMinLength(Object min);

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password field cannot be empty'**
  String get registerConfirmPasswordRequired;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordMismatch;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Logged in.'**
  String get registerSuccessSnackbar;

  /// No description provided for @profileAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountTitle;

  /// No description provided for @profileLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutButton;

  /// No description provided for @profileUnknownName.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get profileUnknownName;

  /// No description provided for @profileUnknownEmail.
  ///
  /// In en, this message translates to:
  /// **'Email not available'**
  String get profileUnknownEmail;

  /// No description provided for @workspaceDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get workspaceDrawerTitle;

  /// No description provided for @workspaceDrawerNoWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'There is no workspace available for your account yet'**
  String get workspaceDrawerNoWorkspaces;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
