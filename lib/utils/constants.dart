// ignore_for_file: constant_identifier_names
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../generated/assets.dart';
import '../screens/auth/model/common_model.dart';
import '../screens/auth/model/login_roles_model.dart';

//region DateFormats
class Constants {
  static const perPageItem = 20;
  static var labelTextSize = 16;
  static const mapLinkForIOS = 'http://maps.apple.com/?q=';
  static var googleMapPrefix = 'https://www.google.com/maps/search/?api=1&query=';
  // SECURITY FIX P0-4: Supprimer les identifiants par défaut en production
  // En debug uniquement, les identifiants de test sont disponibles
  static const DEFAULT_EMAIL = '';
  static const DEFAULT_PASS = '';
  static const appLogoSize = 120.0;
  static const DECIMAL_POINT = 2;
}
//endregion

//region DateFormats
class DateFormatConst {
  static const DD_MM_YY = "dd-MM-yy"; // Use to show only in UI
  static const MMMM_D_yyyy = "MMMM d, y"; // Use to show only in UI
  static const D_MMMM_yyyy = "d MMMM, y"; // Use to show only in UI
  static const D_MMM_yyyy = "d MMM, y"; // Use to show only in UI
  static const MMMM_D_yyyy_At_HH_mm_a = "MMMM d, y @ hh:mm a"; // Use to show only in UI
  static const EEEE_D_MMMM_At_HH_mm_a = "EEEE d MMMM @ hh:mm a"; // Use to show only in UI
  static const dd_MMM_yyyy_HH_mm_a = "dd MMM y, hh:mm a"; // Use to show only in UI
  static const yyyy_MM_dd_HH_mm = 'yyyy-MM-dd HH:mm';
  static const yyyy_MM_dd = 'yyyy-MM-dd';
  static const HH_mm12Hour = 'hh:mm a';
  static const HH_mm24Hour = 'HH:mm';
}
//endregion

//region THEME MODE TYPE
const THEME_MODE_LIGHT = 0;
const THEME_MODE_DARK = 1;
const THEME_MODE_SYSTEM = 2;
//endregion

//region UserKeys
class UserKeys {
  static String firstName = 'first_name';
  static String lastName = 'last_name';
  static String userType = 'user_type';
  static String username = 'username';
  static String email = 'email';
  static String password = 'password';
  static String mobile = 'mobile';
  static String address = 'address';
  static String gender = 'gender';
  static String displayName = 'display_name';
  static String profileImage = 'profile_image';
  static String oldPassword = 'old_password';
  static String newPassword = 'new_password';
  static String loginType = 'login_type';
  static String contactNumber = 'contact_number';
  static String dateOfBirth = 'date_of_birth';
  static String city = 'city';
  static String state = 'state';
  static String country = 'country';
  static String pinCode = 'pinCode';
}
//endregion

//region LOGIN TYPE
class LoginTypeConst {
  static const LOGIN_TYPE_USER = 'user';
  static const LOGIN_TYPE_GOOGLE = 'google';
  static const LOGIN_TYPE_APPLE = 'apple';
}
//endregion

//region SharedPreference Keys
class SharedPreferenceConst {
  static const IS_LOGGED_IN = 'IS_LOGGED_IN';
  static const USER_DATA = 'USER_LOGIN_DATA';
  static const USER_EMAIL = 'USER_EMAIL';
  static const USER_PASSWORD = 'USER_PASSWORD';
  static const FIRST_TIME = 'FIRST_TIME';
  static const IS_REMEMBER_ME = 'IS_REMEMBER_ME';
  static const USER_NAME = 'USER_NAME';
}
//endregion

//region SettingsLocalConst
class SettingsLocalConst {
  static const THEME_MODE = 'THEME_MODE';
}
//endregion

//region defaultCountry
Country get defaultCountry => Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 91,
      geographic: true,
      level: 1,
      name: 'India',
      example: '23456789',
      displayName: 'India (IN) [+91]',
      displayNameNoCountryCode: 'India (IN)',
      e164Key: '91-IN-0',
      fullExampleWithPlusSign: '+919123456789',
    );
//endregion

//region LocatinKeys
class LocatinKeys {
  static const LATITUDE = 'LATITUDE';
  static const LONGITUDE = 'LONGITUDE';
  static const CURRENT_ADDRESS = 'CURRENT_ADDRESS';
  static const ZIP_CODE = 'ZIP_CODE';
}
//endregion

//region Currency position
class CurrencyPosition {
  static const CURRENCY_POSITION_LEFT = 'left';
  static const CURRENCY_POSITION_RIGHT = 'right';
  static const CURRENCY_POSITION_LEFT_WITH_SPACE = 'left_with_space';
  static const CURRENCY_POSITION_RIGHT_WITH_SPACE = 'right_with_space';
}
//endregion

//region Gender TYPE
class GenderTypeConst {
  static const MALE = 'male';
  static const FEMALE = 'female';
}
//endregion

//region Status
class StatusConst {
  static const pending = 'pending';
  static const upcoming = 'upcoming';
  static const confirmed = 'confirmed';
  static const completed = 'completed';
  static const reject = 'reject';
  static const cancel = 'cancel';
  static const inprogress = 'inprogress';
  static const check_in = 'check_in';
  static const checkout = 'checkout';
  static const cancelled = 'cancelled';
}

//region PaymentStatus
class PaymentStatus {
  static const PAID = 'paid';
  static const ADVANCE_PAID = 'advance_paid';
  static const pending = 'pending';
  static const failed = 'failed';
  static const ADVANCE_REFUNDED = 'advance_refunded';
  static const REFUNDED = 'refunded';
}
//endregion

//region Firebase Topic keys
class FirebaseTopicConst {
  static const additionalDataKey = 'additional_data';
  static const vendorApp = 'vendorApp';
  static const vendor = EmployeeKeyConst.vendor;
  static const doctor = EmployeeKeyConst.doctor;
  static const receptionist = EmployeeKeyConst.receptionist;

  //Other Consts
  static const topicSubscribed = 'topic-----subscribed---->';
  static const topicUnSubscribed = 'topic-----UnSubscribed---->';
  static const userWithUnderscoreKey = 'user_';

  static const notificationDataKey = 'Notification Data';
  static const notificationKey = 'Notification';
  static const notificationTitleKey = 'Notification Title';
  static const notificationBodyKey = 'Notification Body';
  static const fcmNotificationTokenKey = 'FCM Notification Token';
  static const apnsNotificationTokenKey = 'APNS Notification Token';
  static const messageDataCollapseKey = 'MessageData Collapse Key';
  static const messageDataMessageIdKey = 'MessageData Message Id';
  static const messageDataMessageTypeKey = 'MessageData Type';
  static const notificationErrorKey = 'Notification Error';
  static const onMessageListen = "Error On Message Listen";
  static const onMessageOpened = "Error On Message Opened App";
  static const onGetInitialMessage = 'Error On Get Initial Message';
  static const notificationChannelIdKey = 'notification';
  static const notificationChannelNameKey = 'Notification';
}
//endregion

//region PaymentStatus
class RequestStatus {
  static const approved = 'approved';
  static const pending = 'pending';
  static const accept = 'accept';
  static const rejected = 'rejected';
  static const hold = 'hold';
  static const CANCELLED = 'cancelled';
}
//endregion

//region TaxType Keys
class TaxType {
  static const FIXED = 'fixed';
  static const PERCENT = 'percent';
  static const PERCENTAGE = 'percentage';

  static const exclusiveTax = 'exclusive';

  static const inclusiveTax = 'inclusive';
}
//endregion

//region DiscountType Keys
class DiscountType {
  static const FIXED = 'fixed';
  static const PERCENTAGE = 'percentage';
}
//endregion

//region Payment Methods
class PaymentMethods {
  static const PAYMENT_METHOD_CASH = 'cash';
  static const PAYMENT_METHOD_STRIPE = 'stripe';
  static const PAYMENT_METHOD_RAZORPAY = 'razorpay';
  static const PAYMENT_METHOD_PAYPAL = 'paypal';
  static const PAYMENT_METHOD_PAYSTACK = 'paystack';
  static const PAYMENT_METHOD_FLUTTER_WAVE = 'flutterwave';
  static const PAYMENT_METHOD_AIRTEL = 'airtel';
  static const PAYMENT_METHOD_PHONEPE = 'phonepe';
  static const PAYMENT_METHOD_MIDTRANS = 'midtrans';
}
//endregion

//region Status
class ServiceFilterStatusConst {
  static const all = 'all';
  static const addedByMe = 'added_by_me';
  static const assignByAdmin = 'assign_by_admin';
  static const createdByAdmin = 'created_by_admin';
}
//endregion

//region CacheConst Keys
class EmployeeKeyConst {
  static const vendor = 'vendor';
  static const doctor = 'doctor';
  static const receptionist = 'receptionist';
}
//endregion

//region CacheConst Keys
class ServiceTypes {
  static const inClinic = 'in_clinic';
  static const online = 'online';
}
//endregion

//region CacheConst Keys
class EncounterDropdownTypes {
  static const encounterProblem = 'encounter_problem';
  static const encounterObservations = 'encounter_observations';
  static const encounterNotes = 'encounter_notes';
}
//endregion

//region Genders Consts
RxList<CMNModel> genders = [
  CMNModel(id: 1, name: "Male", slug: "male"),
  CMNModel(id: 2, name: "Female", slug: "female"),
  CMNModel(id: 3, name: "Other", slug: "other"),
].obs;

class EncounterStatus {
  static const ACTIVE = 'active';
  static const CLOSED = 'closed';
}

//region Update Status constants
// Fonction déplacée dans app_common.dart pour supporter la localisation

//endregion

//region Post Status constants
String postStatus({required String status}) {
  switch (status) {
    case "Confirm":
      return StatusConst.confirmed;
    case "Check-In":
      return StatusConst.check_in;
    case "Check-Out":
      return StatusConst.checkout;
    case "Complete":
      return StatusConst.completed;
    case "Cancel":
      return StatusConst.cancelled;
    default:
      return StatusConst.confirmed;
  }
}
//endregion

// SECURITY FIX P0-4: Demo credentials protégés par kDebugMode
// En release, les identifiants sont vides — aucun accès non autorisé possible
LoginRoleData vendorLoginRole = LoginRoleData(
  id: 1,
  userType: EmployeeKeyConst.vendor,
  roleName: 'AdminCentre',
  icon: Assets.iconsIcVendor,
  email: kDebugMode ? "vendor@bonkanomeet.com" : "",
  password: kDebugMode ? "12345678" : "",
);

//region Login Roles
RxList<LoginRoleData> loginRoles = [
  vendorLoginRole,
  LoginRoleData(
    id: 2,
    userType: EmployeeKeyConst.doctor,
    roleName: 'Praticien',
    icon: Assets.iconsIcDoctor,
    email: kDebugMode ? "doctor@bonkanomeet.com" : "",
    password: kDebugMode ? "12345678" : "",
  ),
  LoginRoleData(
    id: 3,
    userType: EmployeeKeyConst.receptionist,
    roleName: 'Secrétaire médical',
    icon: Assets.iconsIcReceptionist,
    email: kDebugMode ? "receptionist@bonkanomeet.com" : "",
    password: kDebugMode ? "12345678" : "",
  ),
].obs;
//endregion

//region Status
class NotificationConst {
  static const newAppointment = 'new_appointment';
  static const checkoutAppointment = 'checkout_appointment';
  static const rejectAppointment = 'reject_appointment';
  static const acceptAppointment = 'accept_appointment';
  static const cancelAppointment = 'cancel_appointment';
  static const rescheduleAppointment = 'reschedule_appointment';
  static const quickAppointment = 'quick_appointment';
  static const changePassword = 'change_password';
  static const forgetEmailPassword = 'forget_email_password';
}
//endregion

//region Cancellation
class CancellationStatusKeys {
  static num id = 0;
  static String status = 'status';
  static String cancellationChargeAmount = 'cancellation_charge_amount';
  static String reason = 'reason';
  static String cancellationCharge = 'cancellation_charge';
  static String cancellationType = 'cancellation_type';
  static String advancePaidAmount = "advance_paid_amount";
}
//endregion

class BookingUpdateKeys {
  static String reason = 'reason';
  static String startAt = 'start_at';
  static String endAt = 'end_at';
  static String date = 'date';

  static String durationDiff = 'duration_diff';
  static String paymentStatus = 'payment_status';

  static String serviceAddon = 'service_addon';

  static String type = 'type';
}

const SERVICE_PAYMENT_STATUS_ADVANCE_PAID = 'advanced_paid';