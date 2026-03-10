// ignore_for_file: constant_identifier_names

class ApiConstant {
  static const String ENVIRONMENT_URLS = 'http://34.18.195.208:8080/environmentURLs';
  // Base url
  static const String BASEURL_LIVE = 'https://panameraliving.app/'; // Development server
  static const String BASEURL_DEV = 'http://34.18.195.208:8080/'; // Development server
  static const String BASEURL_LOCAL = 'http://192.168.1.37:8000/';

  // End points
  static const String LOGIN = 'login';
  static const String CUSTOMER_LOGIN = 'customerLogin';
  static const String LOGOUT = 'logout';
  static const String FORGOT_PASSWORD = 'customerForgotPassword';
  static const String REFRESH = 'refresh';
  static const String CLOCK_IN = 'clockIn';
  static const String CLOCK_OUT = 'clockOut';
  static const String CLOCK_IN_OUT_STATUS = 'clockInOutStatus';
  static const String UPLOAD_OVERTIME_DETAILS = 'uploadOvertimeDetails';
  static const String UPLOAD_OVERTIME_STATUS = 'updateOvertimeStatus';
  static const String ATTENDANCE_LIST = 'attendanceList';
  static const String BREAK_IN = 'breakIn';
  static const String BREAK_OUT = 'breakOut';
  static const String EARLY_LEAVE_REASON = 'earlyLeaveReason';
  static const String UPLOAD_EARLY_REASON_STATUS = 'updateEarlyReasonStatus';
  static const String STORE_FCM_TOKEN = 'storeFCMToken';
  static const String MARK_NOTIFICATIONS_READ = 'markNotificationsRead';
  static const String NOTIFICATIONS = 'notifications';
  static const String AMC_JOBS = 'amcJobs';
  static const String USER_HIERARCHY = 'userHierarchy';
  static const String AMC_JOB_DETAILS = 'amcJobDetails';
  static const String AMC_JOB_TASK_UPDATE = 'amcJobTaskUpdate';
  static const String AMC_COMMENTS = 'amcComments';
  static const String AMC_ISSUES = 'amcIssues';
  static const String TASK_MANAGER = 'taskManager';
  static const String CUSTOMER_STORE_FCM_TOKEN = 'customerStoreFCMToken';
  static const String CUSTOMER = 'customer';
  static const String CUSTOMER_LOGOUT = 'customerLogout';
  static const String TASK_STATUS_UPDATE = 'taskStatusUpdate';
  static const String COUNT_OF_JOB_STATS = 'countOfJobStats';
  static const String AMC_JOBS_CALENDAR = 'amcJobsCalendar';
  static const String TASK_COMMENTS_ISSUES = 'taskCommentsIssues';
  static const String EMPLOYEE_BY_ORDER_ROLE_LIST = 'employeeByOrderRoleList';
  static const String PROJECT_IMAGES = 'projectImages';
  static const String ALL_CUSTOMERS = 'allCustomers';
  static const String EMPLOYEE = 'employee';
  static const String FEEDBACK = 'feedback';
  static const String CHECK_APP_VERSION = 'checkAppVersion';
  static const String EMERGENCY_CLOCK_IN = 'emergencyClockIn';
  static const String EMERGENCY_CLOCK_OUT = 'emergencyClockOut';
  static const String EMERGENCY_CLOCK_IN_OUT_STATUS = 'emergencyCheckInOutStatus';
  static const String EMERGENCY_MEDIA_UPLOAD = 'emergencyMediaUpload';
  static const String LEAVE_APPLICATION = 'leaveApplications';
}
