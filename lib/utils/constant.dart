// ignore_for_file: constant_identifier_names

enum SwipeDirection { LEFT, RIGHT, TOP, DOWN }

class Constant {
  //RoutesName
  static const String splashScreen = 'splashScreen';
  static const String loginScreen = 'loginScreen';
  static const String forgetPasswordScreen = 'forgetPasswordScreen';
  static const String mainPage = 'mainPage';
  static const String jobScreen = 'jobScreen';
  static const String customerMainPage = 'customerMainPage';
  static const String guestScreen = 'guestScreen';

  //response codes
  static const response_200 = 200;
  static const response_401 = 401;

  static const MALE = "Male";
  static const FEMALE = "Female";

  // pref
  static const String authDetail = 'authDetail';
  static const isLogin = "isLogin";
  static const token = "token";
  static const refreshToken = "refreshToken";
  static const userId = "userId";
  static const userName = "userName";
  static const name = "name";
  static const email = "email";
  static const language = "language";
  static const theme = "theme";
  static const roleName = "roleName";
  static const roleId = "roleId";
  static const groupNumber = "groupNumber";
  static const reportingToName = "reportingToName";
  static const functionality = 'functionality';
  static const customerStringId = 'customerStringId';
  static const empLoginId = 'empLoginId';
  static const empLoginPassword = 'empLoginPassword';
  static const customerLoginEmail = 'customerLoginEmail';
  static const customerLoginPassword = 'customerLoginPassword';
  static const isTeamLeader = 'isTeamLeader';
  static const developmentUrl = 'developmentUrl';
  static const localUrl = 'localUrl';

  //MARK: DATE FORMAT
  static const yyyy_MM_dd_T_HH_mm_ss_SSS_Z = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  static const yyyy_MM_dd_HH_mm_ss = "yyyy-MM-dd HH:mm:ss";
  static const dd_MM_yyyy = "dd-MM-yyyy";
  static const MMM_dd_yyyy = "MMM dd, yyyy";
  static const yyyyMMdd = "yyyyMMdd";
  static const MM = "MM";
  static const MMMM = "MMMM";
  static const yyyy = "yyyy";
  static const HH_mm = "HH:mm";
  static const dd_MM = "dd/MM";
  static const MMM = "MMM";
  static const yyyy_MM_dd = "yyyy-MM-dd";
  static const T_HH_mm_ss_SSS_Z = "'T'HH:mm:ss.SSS'Z'";
  static const MMM_d_yyyy = "MMM d, yyyy";
  static const MMM_dd_ = "MMM dd - ";
  static const MMMM_yyyy = "MMMM, yyyy";
  static const hh_mm_a = "hh:mm a";
  static const EEE = "EEE";
  static const dd_MM_yyyy_slash = "dd/MM/yyyy";
  static const dd_MM_yy_slash = "dd/MM/yy";
  static const MMM_dd_yyyy_hh_mm_a = "MMM dd, yyyy hh:mm a";
  static const EEEE_dd_MM_yyyy = "EEEE, dd/MM/yyyy";
  static const dd_MM_yyyy_hh_mm_a = "dd/MM/yyyy, hh:mm a";
  static const ddMMyyyy_hh_mm_a = "dd MMM yyyy, hh:mm a";

  // Api Params
  static const Authorization = "Authorization";
  static const Bearer = "Bearer";
  static const jwt = "jwt";
  static const data = "data";
  static const error = "error";
  static const code = "code";
  static const id = "id";
  static const datetime = "datetime";
  static const role = "role";
  static const access = "access";
  static const password = "password";
  static const attendanceId = "attendanceId";
  static const clockInTime = "clockInTime";
  static const shiftId = "shiftId";
  static const dateTime = "dateTime";
  static const latitude = "latitude";
  static const longitude = "longitude";
  static const clockOutTime = "clockOutTime";
  static const workingHours = "workingHours";
  static const status = "status";
  static const date = "date";
  static const clockInStatus = "clockInStatus";
  static const clockOutStatus = "clockOutStatus";
  static const isSynced = "isSynced";
  static const successMessage = "successMessage";
  static const errorMessage = "errorMessage";
  static const overtimeHours = "overtimeHours";
  static const overtimeRequestId = "overtimeRequestId";
  static const photoFiles = "photoFiles";
  static const voiceFiles = "voiceFiles";
  static const photoPaths = "photoPaths";
  static const voiceNotePaths = "voiceNotePaths";
  static const attendanceRecordId = "attendanceRecordId";
  static const checkInTime = "checkInTime";
  static const checkOutTime = "checkOutTime";
  static const employeeId = "employeeId";
  static const totalHours = "totalHours";
  static const fullName = "fullName";
  static const checkInLat = "checkInLat";
  static const checkInLong = "checkInLong";
  static const checkOutLat = "checkOutLat";
  static const checkOutLong = "checkOutLong";
  static const attendanceStatus = "attendanceStatus";
  static const overtime = "overtime";
  static const overtimeStatus = "overtimeStatus";
  static const reason = "reason";
  static const imageUrls = "imageUrls";
  static const audioUrls = "audioUrls";
  static const contactNumber = "contactNumber";
  static const phoneNumber = "phoneNumber";
  static const nationality = "nationality";
  static const gender = "gender";
  static const dateOfBirth = "dateOfBirth";
  static const dateOfJoining = "dateOfJoining";
  static const department = "department";
  static const reportingToId = "reportingToId";
  static const employmentStatus = "employmentStatus";
  static const skillSet = "skillSet";
  static const functionalityKey = "functionalityKey";
  static const functionalityKeys = "functionalityKeys";
  static const employeeData = "employeeData";
  static const breakOutTime = "breakOutTime";
  static const breakInTime = "breakInTime";
  static const filterByReportingToId = "filterByReportingToId";
  static const startDate = "startDate";
  static const endDate = "endDate";
  static const page = "page";
  static const pageSize = "pageSize";
  static const reasonText = "reasonText";
  static const earlyReason = "earlyReason";
  static const checkInDeviceId = "checkInDeviceId";
  static const checkOutDeviceId = "checkOutDeviceId";
  static const workingDaysInMonth = "workingDaysInMonth";
  static const absentDaysInMonth = "absentDaysInMonth";
  static const totalOvertimeInMonth = "totalOvertimeInMonth";
  static const shiftUpdateTime = "shiftUpdateTime";
  static const clockOutId = "clockOutId";
  static const earlyReasonStatus = "earlyReasonStatus";
  static const fcmToken = "fcmToken";
  static const notificationType = "notificationType";
  static const notificationId = "notificationId";
  static const overtime_request = "overtime_request";
  static const early_request = "early_request";
  static const check_out_reminder = "check_out_reminder";
  static const title = "title";
  static const body = "body";
  static const isRead = "isRead";
  static const createdAt = "createdAt";
  static const results = "results";
  static const pagination = "pagination";
  static const totalRecords = "totalRecords";
  static const totalPages = "totalPages";
  static const currentPage = "currentPage";
  static const amcJobName = "amcJobName";
  static const amcStatus = "amcStatus";
  static const amcId = "amcId";
  static const completionPercentage = "completionPercentage";
  static const roleOrderId = "roleOrderId";
  static const supervisorId = "supervisorId";
  static const teamLeaderId = "teamLeaderId";
  static const customerName = "customerName";
  static const supervisorName = "supervisorName";
  static const teamLeaderName = "teamLeaderName";
  static const issues = "issues";
  static const comments = "comments";
  static const poolTask = "poolTask";
  static const gardenTask = "gardenTask";
  static const dueDate = "dueDate";
  static const category = "category";
  static const taskName = "taskName";
  static const visitTaskId = "visitTaskId";
  static const completedAt = "completedAt";
  static const amcJobStatus = "amcJobStatus";
  static const amcJobId = "amcJobId";
  static const updatedBy = "updatedBy";
  static const audio = "audio";
  static const images = "images";
  static const severity = "severity";
  static const comment = "comment";
  static const logDate = "logDate";
  static const issueId = "issueId";
  static const issueDescription = "issueDescription";
  static const emailId = "emailId";
  static const customerData = "customerData";
  static const customerId = "customerId";
  static const isCustomer = "isCustomer";
  static const villaId = "villaId";
  static const jobType = "jobType";
  static const notes = "notes";
  static const approvalStatus = "approvalStatus";
  static const taskType = "taskType";
  static const taskStatus = "taskStatus";
  static const wasRequested = "wasRequested";
  static const emirate = "emirate";
  static const villaName = "villaName";
  static const community = "community";
  static const villaList = "villaList";
  static const priority = "priority";
  static const villaImage = "villaImage";
  static const dateType = "dateType";
  static const amcJobsCount = "amcJobsCount";
  static const tasksCount = "tasksCount";
  static const issuesCount = "issuesCount";
  static const attachmentType = "attachmentType";
  static const path = "path";
  static const taskManagerId = "taskManagerId";
  static const employeeName = "employeeName";
  static const imageUrl = "imageUrl";
  static const getAll = "getAll";
  static const reminder = "reminder";
  static const startTime = "startTime";
  static const endTime = "endTime";
  static const gardenSupervisorName = "gardenSupervisorName";
  static const gardenTeamLeaderName = "gardenTeamLeaderName";
  static const poolSupervisorName = "poolSupervisorName";
  static const poolTeamLeaderName = "poolTeamLeaderName";
  static const gardenTeamLeaderId = "gardenTeamLeaderId";
  static const poolTeamLeaderId = "poolTeamLeaderId";
  static const gardenSupervisorId = "gardenSupervisorId";
  static const poolSupervisorId = "poolSupervisorId";
  static const appTrackingTransparency = "appTrackingTransparency";
  static const feedbackText = "feedbackText";
  static const isOfflineData = "isOfflineData";
  static const requestId = "requestId";
  static const latestVersion = "latestVersion";
  static const minSupportedVersion = "minSupportedVersion";
  static const androidUrl = "androidUrl";
  static const iosUrl = "iosUrl";
  static const updateLaterClickedTime = "updateLaterClickedTime";
  static const isExport = "isExport";
  static const latestIosVersion = "latestIosVersion";
  static const minIosVersion = "minIosVersion";
  static const holidaysInMonth = "holidaysInMonth";
  static const visitType = "visitType";
  static const emergencyReason = "emergencyReason";
  static const emergency = "emergency";
  static const emergencyStatus = 'emergencyStatus';
  static const emergencyCheckInTime = 'emergencyCheckInTime';
  static const emergencyCheckInLatitude = 'emergencyCheckInLatitude';
  static const emergencyCheckInLongitude = 'emergencyCheckInLongitude';
  static const emergencyCheckInDeviceId = 'emergencyCheckInDeviceId';
  static const emergencyCheckOutTime = 'emergencyCheckOutTime';
  static const emergencyCheckOutLatitude = 'emergencyCheckOutLatitude';
  static const emergencyCheckOutLongitude = 'emergencyCheckOutLongitude';
  static const emergencyCheckOutDeviceId = 'emergencyCheckOutDeviceId';
  static const emergencyHours = 'emergencyHours';
  static const emergencyCheckOutImages = 'emergencyCheckOutImages';
  static const emergencyCheckOutAudio = 'emergencyCheckOutAudio';
  static const leaveId = 'leaveId';
  static const leaveType = 'leaveType';
  static const reportingDate = 'reportingDate';
  static const contactAddress = 'contactAddress';
  static const leaveCertificate = 'leaveCertificate';
  static const leaveStatus = 'leaveStatus';
  static const timeRemainingForCertificate = 'timeRemainingForCertificate';

  static const all = 'All';
  static const something_went_wrong_please_try_again = 'Something went wrong. Please try again.';
  static const paginationPageSize = 6;
  static const xDeviceType = "Device-Type";
  static const xAppVersion = "App-Version";
  static const xMacId = "Mac-Id";
  static const Mobile = "Mobile";

  static const String amcJobs = "amcJobs";
  static const String taskManager = "taskManager";
  static const String taskManagerPriority = "taskManagerPriority";

  static const int IMAGE_LIMIT = 20;
  static const int AUDIO_LIMIT = 3;

  // Overtime Status
  static const int NA = 0;
  static const int PENDING = 1;
  static const int APPROVED = 2;
  static const int REJECTED = 3;
  static const int TL_APPROVED = 4;

  // AMC Job Status
  static const int AMC_JOB_PENDING = 0;
  static const int AMC_JOB_IN_PROGRESS = 1;
  static const int AMC_JOB_COMPLETED = 2;

  // AMC Job Task Status
  static const int AMC_JOB_TASK_OPEN = 0;
  static const int AMC_JOB_TASK_CLOSED = 1;

  static const int VISIT_TYPE_GARDEN = 1;
  static const int VISIT_TYPE_POOL = 2;

  static const int LEAVE_TYPE_EMERGENCY = 0;
  static const int LEAVE_TYPE_ANNUAL = 1;
  static const int LEAVE_TYPE_SICK = 2;

  // Functionality Keys
  static const String MOBILE_LOGIN = "mobile_login";
  static const String MOBILE_FEED = "mobile_feed";
  static const String MOBILE_ATTENDANCE = "mobile_attendance";
  static const String MOBILE_AMC = "mobile_amc";
  static const String MOBILE_AMC_HISTORY = "mobile_amc_history";
  static const String MOBILE_PROJECTS = "mobile_projects";
  static const String MOBILE_NOTIFICATION = "mobile_notification";
  static const String MOBILE_ATTENDANCE_MY_ATTENDANCE = "mobile_attendance_my_attendance";
  static const String MOBILE_ATTENDANCE_TEAM_ATTENDANCE = "mobile_attendance_team_attendance";
  static const String MOBILE_DASHBOARD_ADMIN = "mobile_dashboard_admin";
  static const String MOBILE_LEAVE_APPLICATION = "mobile_leave_application";

  // Department Types
  static const String DEPARTMENT_PROJECT = "Project";

  // Attendance Status
  static const String PRESENT = "Present";
  static const String ABSENT = "Absent";
  static const String NORMAL = "Normal";
  static const String HALFDAY = "Halfday";
  static const String OVERTIME = "Overtime";

  static const List<String> reminderList = ['None', 'Daily', 'Weekly Twice', 'Weekly Once'];
  static const List<String> emiratesList = ['Abu Dhabi', 'Dubai', 'Sharjah', 'Ajman', 'Umm Al Quwain', 'Ras Al Khaimah', 'Fujairah'];
  static const List<String> nationalityList = [
    "Afghan",
    "Albanian",
    "Algerian",
    "American",
    "Argentinian",
    "Australian",
    "Austrian",
    "Bangladeshi",
    "Belgian",
    "Bolivian",
    "Brazilian",
    "British",
    "Bulgarian",
    "Cambodian",
    "Canadian",
    "Chilean",
    "Chinese",
    "Colombian",
    "Costa Rican",
    "Croatian",
    "Cuban",
    "Czech",
    "Danish",
    "Dominican",
    "Dutch",
    "Ecuadorian",
    "Egyptian",
    "Emirati",
    "Estonian",
    "Ethiopian",
    "Fijian",
    "Filipino",
    "Finnish",
    "French",
    "German",
    "Ghanaian",
    "Greek",
    "Guatemalan",
    "Haitian",
    "Honduran",
    "Hungarian",
    "Icelandic",
    "Indian",
    "Indonesian",
    "Iranian",
    "Iraqi",
    "Irish",
    "Israeli",
    "Italian",
    "Jamaican",
    "Japanese",
    "Jordanian",
    "Kazakhstani",
    "Kenyan",
    "Kuwaiti",
    "Latvian",
    "Lebanese",
    "Libyan",
    "Lithuanian",
    "Malaysian",
    "Malian",
    "Mexican",
    "Mongolian",
    "Moroccan",
    "Nepalese",
    "New Zealander",
    "Nicaraguan",
    "Nigerian",
    "North Korean",
    "Norwegian",
    "Omani",
    "Pakistani",
    "Panamanian",
    "Paraguayan",
    "Peruvian",
    "Polish",
    "Portuguese",
    "Qatari",
    "Romanian",
    "Russian",
    "Salvadoran",
    "Saudi Arabian",
    "Senegalese",
    "Serbian",
    "Singaporean",
    "Slovak",
    "Slovenian",
    "Somali",
    "South African",
    "South Korean",
    "Spanish",
    "Sri Lankan",
    "Sudanese",
    "Swedish",
    "Swiss",
    "Syrian",
    "Taiwanese",
    "Tanzanian",
    "Thai",
    "Tunisian",
    "Turkish",
    "Ugandan",
    "Ukrainian",
    "Uruguayan",
    "Uzbekistani",
    "Venezuelan",
    "Vietnamese",
    "Welsh",
    "Yemeni",
    "Zambian",
    "Zimbabwean",
  ];
}
