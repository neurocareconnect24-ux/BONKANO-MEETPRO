class APIEndPoints {
  static const String appConfiguration = 'app-configuration';
  static const String aboutPages = 'page-list';
  //Auth & User
  static const String register = 'register';
  static const String socialLogin = 'social-login';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String changePassword = 'change-password';
  static const String forgotPassword = 'forgot-password';
  static const String userDetail = 'user-detail';
  static const String updateProfile = 'update-profile';
  static const String deleteUserAccount = 'delete-account';
  static const String getNotification = 'notification-list';
  static const String removeNotification = 'notification-remove';
  static const String clearAllNotification = 'notification-deleteall';

  //Chat API
  static const String getConversations = 'get-conversations';
  static const String getMessages = 'get-messages';
  static const String sendMessage = 'send-message';
  static const String createConversation = 'create-conversation';
  static const String getDoctorList = 'get-doctors';

  //home choose service api
  static const String vendorDashboardList = 'vendor-dashboard-list';
  static const String receptionistDashboardList = 'receptionist-dashboard-list';
  static const String doctorDashboardList = 'doctor-dashboard-list';

  static const String getSystemService = 'get-system-service';
  static const String getServices = 'get-services';
  static const String getServiceDetail = 'get-service-detail';
  static const String revenueDetails = 'get-revenue-chart-data';

  static const String getDoctors = 'get-doctors';

  //booking api-list
  static const String getAppointments = 'appointment-list';
  static const String getEncounterList = 'encounter-list';
  static const String saveBooking = 'save-booking';
  static const String savePayment = 'save-payment';
  static const String bookingUpdate = 'update-booking';
  static const String updateStatus = 'update-status';

  //booking detail-api
  static const String getAppointmentDetail = 'appointment-detail';

  //Review
  static const String saveRating = 'save-rating';
  static const String getRating = 'get-rating';
  static const String deleteRating = 'delete-rating';

  //Vendor
  static const String updateClinicService = 'update-clinic-service';
  static const String deleteService = 'delete-service';
  static const String getCategoryList = 'get-category-list';
  static const String doctorCommissionList = 'doctor-commission-list';
  static const String addService = 'service';
  static const String getRequestList = 'get-request-service';
  static const String saveRequestService = 'save-request-service';
  static const String getReceptionistList = 'get-receptionists';
  static const String saveReceptionist = 'save-receptionist';

  //Clinic
  static const String deleteClinic = 'delete-clinic';
  static const String updateClinic = 'update-clinic';
  static const String saveClinic = 'save-clinic';
  static const String getClinicGallery = 'get-clinic-gallery';
  static const String getClinics = 'get-clinics';
  static const String getClinicListToRegister = 'get-clinic-list';
  static const String getSpecializationList = 'specialization-list';
  static const String saveClinicSession = 'save-clinic-session';
  static const String clinicSessionList = 'clinic-session';
  static const String saveClinicGallery = 'save-clinic-gallery';
  static const String getClinicDetails = 'get-clinic-details';

  //Patient
  static const String getPatientsList = 'get-patients';
  static const String createPatient = 'create-patient';
  static const String getAgoraToken = 'get-agora-token';

  //Payout
  static const String getDoctorPayoutHistory = 'doctor-payout-history';

  //Doctor
  static const String updateDoctor = 'update-doctor';
  static const String saveDoctor = 'save-doctor';
  static const String deleteDoctor = 'delete-doctor';
  static const String deleteReceptionist = 'delete-receptionist';
  static const String saveSession = 'save-doctor-session';
  static const String getDoctorSession = 'get-doctors-session_list';
  static const String doctorDetails = 'doctor-details';
  static const String receptionistDetails = 'get-receptionist-details';
  static const String updateReceptionist = 'update-receptionist';
  static const String doctorSessionList = 'doctor-session';
  static const String assignDoctor = 'assign-doctor';

  //Encounter
  static const String saveEncounter = 'save-encounter';
  static const String editEncounter = 'update-encounter';
  static const String deleteEncounter = 'delete-encounter';
  static const String getEncProblemObservations = 'encounter-dropdown-list';
  static const String getMedicalReport = 'get-medical-report';
  static const String deleteMedicalReport = 'delete-medical-report';
  static const String saveMedicalReport = 'save-medical-report';
  static const String updateMedicalReport = 'update-medical-report';
  static const String billingRecordDetail = 'billing-record-detail';
  static const String encounterDetail = 'encounter-service-detail';
  static const String serviceDetail = 'service-detail';
  static const String saveBillingDetails = 'save-billing-details';
  static const String saveBillingItems = 'save-billing-items';
  static const String deleteBillingItems = 'delete-billing-item';
  static const String encounterDashboardDetail = 'encounter-dashboard-detail';
  static const String saveEncounterDashboard = 'save-encounter-dashboard';
  static const String getPrescription = 'get-prescription';
  static const String savePrescription = 'save-prescription';
  static const String updatePrescription = 'update-prescription';
  static const String deletePrescription = 'delete-prescription';
  static const String encounterInvoice = 'download-encounter-invoice';
  static const String downloadInvoice = 'download_invoice';
  static const String downloadPrescription = 'download-prescription';
  static const String saveBodychart = 'save-bodychart';
  static const String updateBodychart = 'update-bodychart';
  static const String deleteBodychart = 'delete-bodychart';
  static const String bodyChartDetails = 'bodychart-list';
  static const String getSOAP = 'get-soap';
  static const String saveSOAP = 'save-soap';
  static const String saveStructuredReport = 'save-structured-report';
  static const String getStructuredReport = 'get-structured-report';

  //Address
  static const String countryList = 'country-list';
  static const String stateList = 'state-list';
  static const String cityList = 'city-list';

  //Book Appointment
  static const String getTimeSlots = 'get-time-slots';

  //Booking for Other
  static const String otherMemberPatientList = 'other-members-list';
}
