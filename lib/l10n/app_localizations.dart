import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

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
    Locale('sv'),
  ];

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @error_occurred_try_again.
  ///
  /// In en, this message translates to:
  /// **'Error occurred, please try again'**
  String get error_occurred_try_again;

  /// No description provided for @no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get no_internet_connection;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Panamera'**
  String get app_name;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get remember_me;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgot_password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @please_fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get please_fill_all_fields;

  /// No description provided for @please_enter_username.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get please_enter_username;

  /// No description provided for @panamera_living_copyright_2026.
  ///
  /// In en, this message translates to:
  /// **'Panamera Living. Copyright 2026.'**
  String get panamera_living_copyright_2026;

  /// No description provided for @are_you_sure_you_want_to_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get are_you_sure_you_want_to_logout;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @amc.
  ///
  /// In en, this message translates to:
  /// **'AMC'**
  String get amc;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @clock_in.
  ///
  /// In en, this message translates to:
  /// **'Clock In'**
  String get clock_in;

  /// No description provided for @clock_out.
  ///
  /// In en, this message translates to:
  /// **'Clock Out'**
  String get clock_out;

  /// No description provided for @supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @your_current_location.
  ///
  /// In en, this message translates to:
  /// **'Your Current Location'**
  String get your_current_location;

  /// No description provided for @this_month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get this_month;

  /// No description provided for @working_days.
  ///
  /// In en, this message translates to:
  /// **'Working Days'**
  String get working_days;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @overtime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get overtime;

  /// No description provided for @overtime_hrs.
  ///
  /// In en, this message translates to:
  /// **'Overtime (hrs)'**
  String get overtime_hrs;

  /// No description provided for @last_synced.
  ///
  /// In en, this message translates to:
  /// **'Last Synced'**
  String get last_synced;

  /// No description provided for @are_you_sure_you_want_to_check_in.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to check-in ?'**
  String get are_you_sure_you_want_to_check_in;

  /// No description provided for @are_you_sure_you_want_to_check_out.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to check-out ?'**
  String get are_you_sure_you_want_to_check_out;

  /// No description provided for @check_in_successful.
  ///
  /// In en, this message translates to:
  /// **'Check in successful'**
  String get check_in_successful;

  /// No description provided for @check_out_successful.
  ///
  /// In en, this message translates to:
  /// **'Check out successful'**
  String get check_out_successful;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @please_allow_location.
  ///
  /// In en, this message translates to:
  /// **'Please allow location'**
  String get please_allow_location;

  /// No description provided for @please_check_in_first.
  ///
  /// In en, this message translates to:
  /// **'Please check in first'**
  String get please_check_in_first;

  /// No description provided for @are_you_sure_you_want_to_check_out_with_overtime.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to check out with overtime ?'**
  String get are_you_sure_you_want_to_check_out_with_overtime;

  /// No description provided for @give_reason_for_overtime.
  ///
  /// In en, this message translates to:
  /// **'Give reason for overtime'**
  String get give_reason_for_overtime;

  /// No description provided for @overtime_reason.
  ///
  /// In en, this message translates to:
  /// **'Overtime reason'**
  String get overtime_reason;

  /// No description provided for @upload_photo.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get upload_photo;

  /// No description provided for @record_your_voice_note.
  ///
  /// In en, this message translates to:
  /// **'Record your voice note'**
  String get record_your_voice_note;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @prev.
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get prev;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @pageInfo.
  ///
  /// In en, this message translates to:
  /// **'Page {currentPage} of {totalPages}'**
  String pageInfo(Object currentPage, Object totalPages);

  /// No description provided for @my_attendance.
  ///
  /// In en, this message translates to:
  /// **'My Attendance'**
  String get my_attendance;

  /// No description provided for @team_attendance.
  ///
  /// In en, this message translates to:
  /// **'Team Attendance'**
  String get team_attendance;

  /// No description provided for @overtime_approval.
  ///
  /// In en, this message translates to:
  /// **'Overtime Approval'**
  String get overtime_approval;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @are_you_sure_you_dont_want_to_add_overtime_details.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you don\'t want to add overtime time details?'**
  String get are_you_sure_you_dont_want_to_add_overtime_details;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'(Hrs)'**
  String get hours;

  /// No description provided for @ot_approval.
  ///
  /// In en, this message translates to:
  /// **'OT APPROVAL'**
  String get ot_approval;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @break_in.
  ///
  /// In en, this message translates to:
  /// **'Break In'**
  String get break_in;

  /// No description provided for @break_out.
  ///
  /// In en, this message translates to:
  /// **'Break Out'**
  String get break_out;

  /// No description provided for @break_out_successful.
  ///
  /// In en, this message translates to:
  /// **'Break out successful'**
  String get break_out_successful;

  /// No description provided for @break_in_successful.
  ///
  /// In en, this message translates to:
  /// **'Break in successful'**
  String get break_in_successful;

  /// No description provided for @are_you_sure_you_want_to_break_out.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to break out ?'**
  String get are_you_sure_you_want_to_break_out;

  /// No description provided for @are_you_sure_you_want_to_break_in.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to break in ?'**
  String get are_you_sure_you_want_to_break_in;

  /// No description provided for @you_are_not_authorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to access'**
  String get you_are_not_authorized;

  /// No description provided for @please_break_in_first.
  ///
  /// In en, this message translates to:
  /// **'Please break in first'**
  String get please_break_in_first;

  /// No description provided for @error_loading_audio.
  ///
  /// In en, this message translates to:
  /// **'Error loading audio'**
  String get error_loading_audio;

  /// No description provided for @error_loading_audio_file.
  ///
  /// In en, this message translates to:
  /// **'Error loading audio file'**
  String get error_loading_audio_file;

  /// No description provided for @failed_to_initialize_camera_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize camera please try again.'**
  String get failed_to_initialize_camera_please_try_again;

  /// No description provided for @location_permissions_are_permanently_denied_please_enable_them_in_app_settings.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied. Please enable them in app settings.'**
  String
  get location_permissions_are_permanently_denied_please_enable_them_in_app_settings;

  /// No description provided for @please_authenticate_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to continue'**
  String get please_authenticate_to_continue;

  /// No description provided for @authentication_failed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authentication_failed;

  /// No description provided for @would_you_like_to_try_again.
  ///
  /// In en, this message translates to:
  /// **'Would you like to try again?'**
  String get would_you_like_to_try_again;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @give_reason_for_early_leave.
  ///
  /// In en, this message translates to:
  /// **'Give reason for early leave'**
  String get give_reason_for_early_leave;

  /// No description provided for @early_leave_reason.
  ///
  /// In en, this message translates to:
  /// **'Early leave reason'**
  String get early_leave_reason;

  /// No description provided for @are_you_sure_you_dont_want_to_add_early_leave_reason.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you don\'t want to add early leave reason?'**
  String get are_you_sure_you_dont_want_to_add_early_leave_reason;

  /// No description provided for @your_shift_has_been_changed_do_you_want_to_sync_your_data.
  ///
  /// In en, this message translates to:
  /// **'Your shift has been changed\nDo you want to sync your data?'**
  String get your_shift_has_been_changed_do_you_want_to_sync_your_data;

  /// No description provided for @overtime_request_saved.
  ///
  /// In en, this message translates to:
  /// **'Overtime request saved'**
  String get overtime_request_saved;

  /// No description provided for @do_you_want_to_add_overtime_or_early_reason_information.
  ///
  /// In en, this message translates to:
  /// **'Do you want to add overtime or early leave reason information?'**
  String get do_you_want_to_add_overtime_or_early_reason_information;

  /// No description provided for @early_reason_request_saved.
  ///
  /// In en, this message translates to:
  /// **'Early leave reason request saved'**
  String get early_reason_request_saved;

  /// No description provided for @early_leave.
  ///
  /// In en, this message translates to:
  /// **'Early Leave'**
  String get early_leave;

  /// No description provided for @clock_out_not_found.
  ///
  /// In en, this message translates to:
  /// **'Clock out not found'**
  String get clock_out_not_found;

  /// No description provided for @el_approval.
  ///
  /// In en, this message translates to:
  /// **'EL APPROVAL'**
  String get el_approval;

  /// No description provided for @overtime_duration.
  ///
  /// In en, this message translates to:
  /// **'Overtime Duration'**
  String get overtime_duration;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @no_notification.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get no_notification;

  /// No description provided for @early_leave_approval.
  ///
  /// In en, this message translates to:
  /// **'Early Leave Approval'**
  String get early_leave_approval;

  /// No description provided for @media_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The image or audio is not available or was removed after a certain time period'**
  String get media_unavailable;

  /// No description provided for @no_reason_provided.
  ///
  /// In en, this message translates to:
  /// **'No reason provided.'**
  String get no_reason_provided;

  /// No description provided for @please_solve_the_captcha_first.
  ///
  /// In en, this message translates to:
  /// **'Please solve the CAPTCHA first.'**
  String get please_solve_the_captcha_first;

  /// No description provided for @captcha_solved_successfully.
  ///
  /// In en, this message translates to:
  /// **'Captcha solved successfully!'**
  String get captcha_solved_successfully;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @amc_jobs.
  ///
  /// In en, this message translates to:
  /// **'AMC Jobs'**
  String get amc_jobs;

  /// No description provided for @team_name.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get team_name;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @in_progress.
  ///
  /// In en, this message translates to:
  /// **'In-progress'**
  String get in_progress;

  /// No description provided for @not_started.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get not_started;

  /// No description provided for @start_work.
  ///
  /// In en, this message translates to:
  /// **'Start Work'**
  String get start_work;

  /// No description provided for @end_work.
  ///
  /// In en, this message translates to:
  /// **'End Work'**
  String get end_work;

  /// No description provided for @team_leader.
  ///
  /// In en, this message translates to:
  /// **'Team Leader'**
  String get team_leader;

  /// No description provided for @comments_and_photos.
  ///
  /// In en, this message translates to:
  /// **'Comments And Photos'**
  String get comments_and_photos;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @issues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get issues;

  /// No description provided for @add_new_issue.
  ///
  /// In en, this message translates to:
  /// **'Add New Issue'**
  String get add_new_issue;

  /// No description provided for @issue_title.
  ///
  /// In en, this message translates to:
  /// **'Issue Title'**
  String get issue_title;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @my_pending_tasks.
  ///
  /// In en, this message translates to:
  /// **'My Pending Tasks'**
  String get my_pending_tasks;

  /// No description provided for @my_overdue_tasks.
  ///
  /// In en, this message translates to:
  /// **'My Overdue Tasks'**
  String get my_overdue_tasks;

  /// No description provided for @my_tasks_due_today.
  ///
  /// In en, this message translates to:
  /// **'My Tasks Due Today'**
  String get my_tasks_due_today;

  /// No description provided for @all_tasks.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get all_tasks;

  /// No description provided for @issues_assigned_to_me.
  ///
  /// In en, this message translates to:
  /// **'Issues Assigned to Me'**
  String get issues_assigned_to_me;

  /// No description provided for @all_issues.
  ///
  /// In en, this message translates to:
  /// **'All Issues'**
  String get all_issues;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @task_description.
  ///
  /// In en, this message translates to:
  /// **'Task Description'**
  String get task_description;

  /// No description provided for @issue_description.
  ///
  /// In en, this message translates to:
  /// **'Issue Description'**
  String get issue_description;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @pool_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Pool Maintenance'**
  String get pool_maintenance;

  /// No description provided for @garden_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Garden Maintenance'**
  String get garden_maintenance;

  /// No description provided for @no_jobs_found.
  ///
  /// In en, this message translates to:
  /// **'No Jobs Found'**
  String get no_jobs_found;

  /// No description provided for @are_you_sure_you_want_to_start_work.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start work?'**
  String get are_you_sure_you_want_to_start_work;

  /// No description provided for @are_you_sure_you_want_to_end_work.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end work?'**
  String get are_you_sure_you_want_to_end_work;

  /// No description provided for @are_you_sure_you_want_to_update_task.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update task?'**
  String get are_you_sure_you_want_to_update_task;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @please_enter_comment.
  ///
  /// In en, this message translates to:
  /// **'Please enter comment'**
  String get please_enter_comment;

  /// No description provided for @please_enter_issue_details.
  ///
  /// In en, this message translates to:
  /// **'Please enter issue details'**
  String get please_enter_issue_details;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @please_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get please_enter_email;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @my_properties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get my_properties;

  /// No description provided for @book_service.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get book_service;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// No description provided for @raise_issue.
  ///
  /// In en, this message translates to:
  /// **'Raise Issue'**
  String get raise_issue;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @raise_an_issue.
  ///
  /// In en, this message translates to:
  /// **'Raise an Issue'**
  String get raise_an_issue;

  /// No description provided for @cleaning_task.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Task'**
  String get cleaning_task;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @villa.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get villa;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @select_villa.
  ///
  /// In en, this message translates to:
  /// **'Select Villa'**
  String get select_villa;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @are_you_sure_you_want_to_update_issue.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update issue?'**
  String get are_you_sure_you_want_to_update_issue;

  /// No description provided for @no_media_attached.
  ///
  /// In en, this message translates to:
  /// **'No media attached'**
  String get no_media_attached;

  /// No description provided for @my_issues.
  ///
  /// In en, this message translates to:
  /// **'My Issues'**
  String get my_issues;

  /// No description provided for @are_you_sure_you_want_to_update_status.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update status?'**
  String get are_you_sure_you_want_to_update_status;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @are_you_sure_you_want_to_close_the_task.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the task?'**
  String get are_you_sure_you_want_to_close_the_task;

  /// No description provided for @please_start_work_to_go_ahead.
  ///
  /// In en, this message translates to:
  /// **'Please start work to go ahead'**
  String get please_start_work_to_go_ahead;

  /// No description provided for @no_tasks_found.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get no_tasks_found;

  /// No description provided for @no_data_found.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get no_data_found;

  /// No description provided for @garden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get garden;

  /// No description provided for @pool.
  ///
  /// In en, this message translates to:
  /// **'Pool'**
  String get pool;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get select_date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @home_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Home\nMaintenance'**
  String get home_maintenance;

  /// No description provided for @no_amc_found_for_this_villa.
  ///
  /// In en, this message translates to:
  /// **'No AMC found for this villa'**
  String get no_amc_found_for_this_villa;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @update_your_profile.
  ///
  /// In en, this message translates to:
  /// **'Update your profile'**
  String get update_your_profile;

  /// No description provided for @emirate.
  ///
  /// In en, this message translates to:
  /// **'Emirate'**
  String get emirate;

  /// No description provided for @contact_number.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contact_number;

  /// No description provided for @select_emirate.
  ///
  /// In en, this message translates to:
  /// **'Select Emirate'**
  String get select_emirate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @please_enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid email'**
  String get please_enter_valid_email;

  /// No description provided for @pending_tasks.
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks'**
  String get pending_tasks;

  /// No description provided for @create_new_task.
  ///
  /// In en, this message translates to:
  /// **'Create New Task'**
  String get create_new_task;

  /// No description provided for @overdue_tasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue Tasks'**
  String get overdue_tasks;

  /// No description provided for @tasks_due_today.
  ///
  /// In en, this message translates to:
  /// **'Tasks Due Today'**
  String get tasks_due_today;

  /// No description provided for @no_issues_found.
  ///
  /// In en, this message translates to:
  /// **'No issues found'**
  String get no_issues_found;

  /// No description provided for @select_supervisor.
  ///
  /// In en, this message translates to:
  /// **'Select Supervisor'**
  String get select_supervisor;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @on_hold.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get on_hold;

  /// No description provided for @select_date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get select_date_of_birth;

  /// No description provided for @date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get date_of_birth;

  /// No description provided for @update_task_status.
  ///
  /// In en, this message translates to:
  /// **'Update Task Status'**
  String get update_task_status;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @comments_cannot_be_added_after_the_status_is_closed.
  ///
  /// In en, this message translates to:
  /// **'Comments cannot be added after the status is closed'**
  String get comments_cannot_be_added_after_the_status_is_closed;

  /// No description provided for @latest_panamera_projects.
  ///
  /// In en, this message translates to:
  /// **'Latest Panamera Projects'**
  String get latest_panamera_projects;

  /// No description provided for @due_date.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get due_date;

  /// No description provided for @start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get start_date;

  /// No description provided for @select_start_date.
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get select_start_date;

  /// No description provided for @select_due_date.
  ///
  /// In en, this message translates to:
  /// **'Select Due Date'**
  String get select_due_date;

  /// No description provided for @task_title.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get task_title;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @select_customer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get select_customer;

  /// No description provided for @select_reminder.
  ///
  /// In en, this message translates to:
  /// **'Select Reminder'**
  String get select_reminder;

  /// No description provided for @please_enter_task_title.
  ///
  /// In en, this message translates to:
  /// **'Please enter task title'**
  String get please_enter_task_title;

  /// No description provided for @please_select_customer.
  ///
  /// In en, this message translates to:
  /// **'Please select customer'**
  String get please_select_customer;

  /// No description provided for @please_select_villa.
  ///
  /// In en, this message translates to:
  /// **'Please select villa'**
  String get please_select_villa;

  /// No description provided for @please_select_priority.
  ///
  /// In en, this message translates to:
  /// **'Please select priority'**
  String get please_select_priority;

  /// No description provided for @please_select_reminder.
  ///
  /// In en, this message translates to:
  /// **'Please select reminder'**
  String get please_select_reminder;

  /// No description provided for @please_select_supervisor.
  ///
  /// In en, this message translates to:
  /// **'Please select supervisor'**
  String get please_select_supervisor;

  /// No description provided for @please_select_start_date.
  ///
  /// In en, this message translates to:
  /// **'Please select start date'**
  String get please_select_start_date;

  /// No description provided for @please_select_due_date.
  ///
  /// In en, this message translates to:
  /// **'Please select due date'**
  String get please_select_due_date;

  /// No description provided for @due_date_should_be_after_start_date.
  ///
  /// In en, this message translates to:
  /// **'Due date should be after start date'**
  String get due_date_should_be_after_start_date;

  /// No description provided for @please_enter_task_description.
  ///
  /// In en, this message translates to:
  /// **'Please enter task description'**
  String get please_enter_task_description;

  /// No description provided for @select_priority.
  ///
  /// In en, this message translates to:
  /// **'Select Priority'**
  String get select_priority;

  /// No description provided for @ex_garden_cleaning_pool_cleaning.
  ///
  /// In en, this message translates to:
  /// **'Ex: Garden Cleaning, Pool Cleaning, etc.'**
  String get ex_garden_cleaning_pool_cleaning;

  /// No description provided for @please_provide_brief_about_your_requirement.
  ///
  /// In en, this message translates to:
  /// **'Please provide brief about your requirement'**
  String get please_provide_brief_about_your_requirement;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @awaiting_gate_pass.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Gate Pass'**
  String get awaiting_gate_pass;

  /// No description provided for @select_date_of_join.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Join'**
  String get select_date_of_join;

  /// No description provided for @date_of_joining.
  ///
  /// In en, this message translates to:
  /// **'Date of Joining'**
  String get date_of_joining;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @select_nationality.
  ///
  /// In en, this message translates to:
  /// **'Select Nationality'**
  String get select_nationality;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @max_20_images.
  ///
  /// In en, this message translates to:
  /// **'Max. 20 Images'**
  String get max_20_images;

  /// No description provided for @you_are_not_authorized_to_access_this_action.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to access this action'**
  String get you_are_not_authorized_to_access_this_action;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @continue_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continue_as_guest;

  /// No description provided for @welcome_to.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcome_to;

  /// No description provided for @panamera_living.
  ///
  /// In en, this message translates to:
  /// **'Panamera Living'**
  String get panamera_living;

  /// No description provided for @get_inspired.
  ///
  /// In en, this message translates to:
  /// **'Get Inspired'**
  String get get_inspired;

  /// No description provided for @visit_website.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visit_website;

  /// No description provided for @amc_jobs_history.
  ///
  /// In en, this message translates to:
  /// **'AMC Jobs History'**
  String get amc_jobs_history;

  /// No description provided for @villa_customer.
  ///
  /// In en, this message translates to:
  /// **'Villa (Customer)'**
  String get villa_customer;

  /// No description provided for @garden_team_leader.
  ///
  /// In en, this message translates to:
  /// **'Garden Team Leader'**
  String get garden_team_leader;

  /// No description provided for @pool_team_leader.
  ///
  /// In en, this message translates to:
  /// **'Pool Team Leader'**
  String get pool_team_leader;

  /// No description provided for @emergency_requests.
  ///
  /// In en, this message translates to:
  /// **'Emergency Requests'**
  String get emergency_requests;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @track_request.
  ///
  /// In en, this message translates to:
  /// **'Track Request'**
  String get track_request;

  /// No description provided for @coming_soon_text.
  ///
  /// In en, this message translates to:
  /// **'Our new service is on its way.\nWe appreciate your patience!'**
  String get coming_soon_text;

  /// No description provided for @feedback_text.
  ///
  /// In en, this message translates to:
  /// **'Your opinion matters to us. We’re working hard to make our service the best it can be, and your honest feedback is key to helping us get there.'**
  String get feedback_text;

  /// No description provided for @enter_your_feedback_here.
  ///
  /// In en, this message translates to:
  /// **'Enter your feedback here'**
  String get enter_your_feedback_here;

  /// No description provided for @feedback_sent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent'**
  String get feedback_sent;

  /// No description provided for @no_requests_found.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get no_requests_found;

  /// No description provided for @update_required.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get update_required;

  /// No description provided for @update_available.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get update_available;

  /// No description provided for @critical_update_message.
  ///
  /// In en, this message translates to:
  /// **'A critical update ({version}) is required.\nPlease update now to continue using the app.'**
  String critical_update_message(Object version);

  /// No description provided for @update_available_message.
  ///
  /// In en, this message translates to:
  /// **'A new version ({version}) is available.\nUpdate now to enjoy the latest features and improvements.'**
  String update_available_message(Object version);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get later;

  /// No description provided for @update_now.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get update_now;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @you_cannot_login_in_offline_mode_please_try_again_in_online_mode.
  ///
  /// In en, this message translates to:
  /// **'You cannot login in offline mode. Please try again in online mode.'**
  String get you_cannot_login_in_offline_mode_please_try_again_in_online_mode;

  /// No description provided for @submit_enquiry.
  ///
  /// In en, this message translates to:
  /// **'Submit Enquiry'**
  String get submit_enquiry;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @holidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get holidays;

  /// No description provided for @select_status.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get select_status;

  /// No description provided for @amc_job.
  ///
  /// In en, this message translates to:
  /// **'AMC Job'**
  String get amc_job;

  /// No description provided for @please_complete_task_or_update_photos_to_end_work.
  ///
  /// In en, this message translates to:
  /// **'Please complete task or update photos to end work'**
  String get please_complete_task_or_update_photos_to_end_work;

  /// No description provided for @please_complete_your_regular_shift.
  ///
  /// In en, this message translates to:
  /// **'Please complete your regular shift'**
  String get please_complete_your_regular_shift;

  /// No description provided for @emergency_check_in_out.
  ///
  /// In en, this message translates to:
  /// **'Emergency Check In/Out'**
  String get emergency_check_in_out;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @emergency_reason.
  ///
  /// In en, this message translates to:
  /// **'Emergency Reason'**
  String get emergency_reason;

  /// No description provided for @please_check_out_first.
  ///
  /// In en, this message translates to:
  /// **'Please check out first.'**
  String get please_check_out_first;

  /// No description provided for @please_add_images_or_audio_files.
  ///
  /// In en, this message translates to:
  /// **'Please add images or audio files.'**
  String get please_add_images_or_audio_files;

  /// No description provided for @emergency_details_saved.
  ///
  /// In en, this message translates to:
  /// **'Emergency details saved.'**
  String get emergency_details_saved;

  /// No description provided for @please_enter_reason.
  ///
  /// In en, this message translates to:
  /// **'Please enter reason.'**
  String get please_enter_reason;

  /// No description provided for @please_enter_emergency_details_first.
  ///
  /// In en, this message translates to:
  /// **'Please enter emergency details first.'**
  String get please_enter_emergency_details_first;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @emergency_hours.
  ///
  /// In en, this message translates to:
  /// **'Emergency Hours'**
  String get emergency_hours;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @leave_application.
  ///
  /// In en, this message translates to:
  /// **'Leave Application'**
  String get leave_application;

  /// No description provided for @leave_requests.
  ///
  /// In en, this message translates to:
  /// **'Leave Requests'**
  String get leave_requests;

  /// No description provided for @apply_for_leave.
  ///
  /// In en, this message translates to:
  /// **'Apply For Leave'**
  String get apply_for_leave;

  /// No description provided for @end_date.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get end_date;

  /// No description provided for @reporting_date.
  ///
  /// In en, this message translates to:
  /// **'Reporting Date'**
  String get reporting_date;

  /// No description provided for @select_end_date.
  ///
  /// In en, this message translates to:
  /// **'Select End Date'**
  String get select_end_date;

  /// No description provided for @select_reporting_date.
  ///
  /// In en, this message translates to:
  /// **'Select Reporting Date'**
  String get select_reporting_date;

  /// No description provided for @number_of_leave_days.
  ///
  /// In en, this message translates to:
  /// **'Number of Leave Days'**
  String get number_of_leave_days;

  /// No description provided for @date_of_reporting_after_leave.
  ///
  /// In en, this message translates to:
  /// **'Date of Reporting After Leave'**
  String get date_of_reporting_after_leave;

  /// No description provided for @my_requests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get my_requests;

  /// No description provided for @team_leave_requests.
  ///
  /// In en, this message translates to:
  /// **'Team Leave Requests'**
  String get team_leave_requests;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @sick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get sick;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @leave_type.
  ///
  /// In en, this message translates to:
  /// **'Leave Type'**
  String get leave_type;

  /// No description provided for @select_leave_type.
  ///
  /// In en, this message translates to:
  /// **'Select Leave Type'**
  String get select_leave_type;

  /// No description provided for @reason_incase_of_emergency.
  ///
  /// In en, this message translates to:
  /// **'Reason Incase of Emergency'**
  String get reason_incase_of_emergency;

  /// No description provided for @contact_address_during_leave.
  ///
  /// In en, this message translates to:
  /// **'Contact Address During Leave'**
  String get contact_address_during_leave;

  /// No description provided for @contact_number_during_leave.
  ///
  /// In en, this message translates to:
  /// **'Contact Number During Leave'**
  String get contact_number_during_leave;

  /// No description provided for @please_select_start_date_first.
  ///
  /// In en, this message translates to:
  /// **'Please select start date first'**
  String get please_select_start_date_first;

  /// No description provided for @upload_sick_leave_certificate.
  ///
  /// In en, this message translates to:
  /// **'Upload Sick Leave Certificate'**
  String get upload_sick_leave_certificate;

  /// No description provided for @tap_to_upload_certificate.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload certificate'**
  String get tap_to_upload_certificate;

  /// No description provided for @view_certificate.
  ///
  /// In en, this message translates to:
  /// **'View Certificate'**
  String get view_certificate;

  /// No description provided for @assigned_to.
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get assigned_to;

  /// No description provided for @select_tl.
  ///
  /// In en, this message translates to:
  /// **'Select TL'**
  String get select_tl;

  /// No description provided for @amc_history.
  ///
  /// In en, this message translates to:
  /// **'AMC History'**
  String get amc_history;
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
      <String>['en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
