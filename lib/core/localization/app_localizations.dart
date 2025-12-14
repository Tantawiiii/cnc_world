import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // App Info
      'appTitle': 'CNC World',

      // Onboarding
      'onboardingPage1Title': 'مرحباً بك في عالم CNC',
      'onboardingPage1Description':
          'منصة شاملة لجميع احتياجاتك في عالم الماكينات CNC\nمن بيع وشراء إلى خدمات الصيانة والتأمين',
      'onboardingPage2Title': 'خدمات متكاملة',
      'onboardingPage2Description':
          'شحن سريع • مواقع الماكينات • طلب تصميمات\nسوق مستلزمات • صيانة • تأمين شامل • مهندسين متخصصين',
      'onboardingPage3Title': 'ابدأ رحلتك الآن',
      'onboardingPage3Description':
          'انضم إلى مجتمع CNC World واستمتع بأفضل الخدمات\nوالتجربة الاحترافية في عالم التصنيع',

      // Buttons
      'skip': 'تخطي',
      'next': 'التالي',
      'previous': 'السابق',
      'startNow': 'ابدأ الآن',

      // Language
      'language': 'اللغة',
      'selectLanguage': 'اختر اللغة',
      'arabic': 'العربية',
      'english': 'English',

      // Settings
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'logoutConfirmation': 'هل أنت متأكد من تسجيل الخروج؟',
      'logoutDescription': 'سيتم تسجيل خروجك من التطبيق',
      'cancel': 'إلغاء',
      'profile': 'الملف الشخصي',

      // Login
      'login': 'تسجيل الدخول',
      'phone': 'رقم الهاتف',
      'password': 'كلمة المرور',
      'loginButton': 'تسجيل الدخول',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'register': 'سجل الآن',
      'phoneRequired': 'يرجى إدخال رقم الهاتف',
      'passwordRequired': 'يرجى إدخال كلمة المرور',

      // Register
      'selectRole': 'اختر نوع الحساب',
      'selectRoleSubtitle': 'اختر نوع حسابك للمتابعة',
      'registerTitle': 'إنشاء حساب جديد',
      'registerButton': 'تسجيل',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟',
      'backToLogin': 'تسجيل الدخول',
      'registerSuccess': 'تم التسجيل بنجاح',

      // Roles
      'roleUser': 'مستخدم',
      'roleEngineer': 'مهندس',
      'roleSeller': 'بائع',
      'roleMerchant': 'تاجر',

      // Register Fields
      'name': 'الاسم',
      'nameRequired': 'يرجى إدخال الاسم',
      'address': 'العنوان',
      'addressRequired': 'يرجى إدخال العنوان',
      'country': 'الدولة',
      'countryRequired': 'يرجى اختيار الدولة',
      'city': 'المدينة',
      'cityRequired': 'يرجى إدخال المدينة',
      'state': 'المنطقة',
      'stateRequired': 'يرجى إدخال المنطقة',
      'workshopName': 'اسم الورشة',
      'workshopNameRequired': 'يرجى إدخال اسم الورشة',
      'natureOfWork': 'طبيعة العمل',
      'natureOfWorkRequired': 'يرجى إدخال طبيعة العمل',
      'facebookLink': 'رابط الفيسبوك',
      'whatsappNumber': 'رقم الواتساب',
      'imageRequired': 'يرجى اختيار صورة',
      'uploadImage': 'رفع صورة',
      'imageUploadFailed': 'فشل رفع الصورة',
      'uploadingImage': 'جاري الرفع...',
      'pickingImage': 'جاري اختيار الصورة...',
      'tapToSelect': 'انقر للاختيار',

      // Home
      'home': 'الرئيسية',
      'welcome': 'مرحباً',
      'defaultUserName': 'المستخدم',
      'homeCategoryMaintenance': 'الصيانه',
      'homeCategoryUsedMachines': 'الماكينات المستعمله',
      'homeCategoryManufacturingSupplies': 'مستلزمات التصنيع',
      'homeCategoryCompanyDirectory': 'دليل الشركات',
      'homeCategoryDesigns': 'التصميمات',
      'homeCategoryWorkshopDirectory': 'دليل الورش',
      'errorLoadingSliders': 'خطأ في تحميل الشرائح',

      // Contact Us
      'contactUs': 'اتصل بنا',
      'contactSuccess': 'تم إرسال رسالتك بنجاح',
      'submitContact': 'إرسال',

      // Complaint
      'complaint': 'شكوى',
      'complaintSuccess': 'تم إرسال شكواك بنجاح',
      'submitComplaint': 'إرسال الشكوى',

      // Form Fields
      'email': 'البريد الإلكتروني',
      'emailRequired': 'يرجى إدخال البريد الإلكتروني',
      'invalidEmail': 'يرجى إدخال بريد إلكتروني صحيح',
      'subject': 'الموضوع',
      'subjectRequired': 'يرجى إدخال الموضوع',
      'subjectMinLength': 'يجب أن يكون الموضوع 5 أحرف على الأقل',
      'message': 'الرسالة',
      'messageHint': 'أدخل رسالتك',
      'messageRequired': 'يرجى إدخال الرسالة',
      'messageMinLength': 'يجب أن تكون الرسالة 10 أحرف على الأقل',
      'nameInvalidFormat': 'تنسيق الاسم غير صحيح',

      // Used Machines
      'usedMachines': 'الماكينات المستعملة',
      'addUsedMachine': 'إضافة ماكينة مستعملة',
      'machineName': 'اسم الماكينة',
      'machineNameHint': 'أدخل اسم الماكينة',
      'machineNameRequired': 'يرجى إدخال اسم الماكينة',
      'machinePrice': 'السعر',
      'machinePriceHint': 'أدخل السعر',
      'machinePriceRequired': 'يرجى إدخال السعر',
      'invalidPrice': 'يرجى إدخال سعر صحيح',
      'machineDescription': 'الوصف',
      'machineDescriptionHint': 'أدخل وصف الماكينة',
      'machineDescriptionRequired': 'يرجى إدخال الوصف',
      'uploadMachineImage': 'رفع صورة الماكينة',
      'addMachine': 'إضافة الماكينة',
      'machineAddedSuccess': 'تم إضافة الماكينة بنجاح',
      'noMachinesAvailable': 'لا توجد ماكينات متاحة',
      'retry': 'إعادة المحاولة',
      'sellerInfo': 'معلومات البائع',
      'createdAt': 'تاريخ الإضافة',
      'usedMachinesDisclaimer':
          'الابليكشن مسؤول بالكامل عن معاينه ونقل وتركيب والتدريب علي الماكينه',
      'maintenanceImageRequired': 'يرجى رفع صورة المشكلة',
      'imageUploadSuccess': 'تم رفع الصورة بنجاح',
      'errorPickingMedia': 'Error picking media:',
      'video': 'فيديو',
      'videoUnavailable': 'Video unavailable',
      'maintenanceUploadingImage': 'جاري رفع الصورة...',
    },
    'en': {
      // App Info
      'appTitle': 'CNC World',

      // Onboarding
      'onboardingPage1Title': 'Welcome to CNC World',
      'onboardingPage1Description':
          'A comprehensive platform for all your CNC machine needs\nFrom buying and selling to maintenance and insurance services',
      'onboardingPage2Title': 'Integrated Services',
      'onboardingPage2Description':
          'Fast shipping • Machine locations • Design requests\nSupplies market • Maintenance • Comprehensive insurance • Specialized engineers',
      'onboardingPage3Title': 'Start Your Journey Now',
      'onboardingPage3Description':
          'Join the CNC World community and enjoy the best services\nand professional experience in the manufacturing world',

      // Buttons
      'skip': 'Skip',
      'next': 'Next',
      'previous': 'Previous',
      'startNow': 'Start Now',

      // Language
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'arabic': 'العربية',
      'english': 'English',

      // Settings
      'settings': 'Settings',
      'logout': 'Logout',
      'logoutConfirmation': 'Are you sure you want to logout?',
      'logoutDescription': 'You will be logged out of the app',
      'cancel': 'Cancel',
      'profile': 'Profile',

      // Login
      'login': 'Login',
      'phone': 'Phone Number',
      'password': 'Password',
      'loginButton': 'Login',
      'dontHaveAccount': "Don't have an account?",
      'register': 'Sign Up',
      'phoneRequired': 'Please enter phone number',
      'passwordRequired': 'Please enter password',

      // Register
      'selectRole': 'Select Account Type',
      'selectRoleSubtitle': 'Choose your account type to continue',
      'registerTitle': 'Create New Account',
      'registerButton': 'Register',
      'alreadyHaveAccount': 'Already have an account?',
      'backToLogin': 'Login',
      'registerSuccess': 'Registration successful',

      // Roles
      'roleUser': 'User',
      'roleEngineer': 'Engineer',
      'roleSeller': 'Seller',
      'roleMerchant': 'Merchant',

      // Register Fields
      'name': 'Name',
      'nameRequired': 'Please enter name',
      'address': 'Address',
      'addressRequired': 'Please enter address',
      'country': 'Country',
      'countryRequired': 'Please select country',
      'city': 'City',
      'cityRequired': 'Please enter city',
      'state': 'State',
      'stateRequired': 'Please enter state',
      'workshopName': 'Workshop Name',
      'workshopNameRequired': 'Please enter workshop name',
      'natureOfWork': 'Nature of Work',
      'natureOfWorkRequired': 'Please enter nature of work',
      'facebookLink': 'Facebook Link',
      'whatsappNumber': 'WhatsApp Number',
      'imageRequired': 'Please select image',
      'uploadImage': 'Upload Image',
      'imageUploadFailed': 'Image upload failed',
      'uploadingImage': 'Uploading...',
      'pickingImage': 'Selecting image...',
      'tapToSelect': 'Tap to select',

      // Home
      'home': 'Home',
      'welcome': 'Welcome',
      'defaultUserName': 'User',
      'homeCategoryMaintenance': 'Maintenance',
      'homeCategoryUsedMachines': 'Used Machines',
      'homeCategoryManufacturingSupplies': 'Manufacturing Supplies',
      'homeCategoryCompanyDirectory': 'Company Directory',
      'homeCategoryDesigns': 'Designs',
      'homeCategoryWorkshopDirectory': 'Workshop Directory',
      'errorLoadingSliders': 'Error loading sliders',

      // Contact Us
      'contactUs': 'Contact Us',
      'contactSuccess': 'Your message has been sent successfully',
      'submitContact': 'Submit',

      // Complaint
      'complaint': 'Complaint',
      'complaintSuccess': 'Your complaint has been sent successfully',
      'submitComplaint': 'Submit Complaint',

      // Form Fields
      'email': 'Email',
      'emailRequired': 'Please enter email',
      'invalidEmail': 'Please enter a valid email',
      'subject': 'Subject',
      'subjectRequired': 'Please enter subject',
      'subjectMinLength': 'Subject must be at least 5 characters',
      'message': 'Message',
      'messageHint': 'Enter your message',
      'messageRequired': 'Please enter message',
      'messageMinLength': 'Message must be at least 10 characters',
      'nameInvalidFormat': 'Invalid name format',

      // Used Machines
      'usedMachines': 'Used Machines',
      'addUsedMachine': 'Add Used Machine',
      'machineName': 'Machine Name',
      'machineNameHint': 'Enter machine name',
      'machineNameRequired': 'Please enter machine name',
      'machinePrice': 'Price',
      'machinePriceHint': 'Enter price',
      'machinePriceRequired': 'Please enter price',
      'invalidPrice': 'Please enter a valid price',
      'machineDescription': 'Description',
      'machineDescriptionHint': 'Enter machine description',
      'machineDescriptionRequired': 'Please enter description',
      'uploadMachineImage': 'Upload Machine Image',
      'addMachine': 'Add Machine',
      'machineAddedSuccess': 'Machine added successfully',
      'noMachinesAvailable': 'No machines available',
      'retry': 'Retry',
      'sellerInfo': 'Seller Info',
      'createdAt': 'Created At',
      'usedMachinesDisclaimer':
          'The application is fully responsible for inspection, transfer, installation and training on the machine',
      'maintenanceImageRequired': 'Please upload problem image',
      'imageUploadSuccess': 'Image uploaded successfully',
      'errorPickingMedia': 'Error picking media:',
      'video': 'Video',
      'videoUnavailable': 'Video unavailable',
      'maintenanceUploadingImage': 'Uploading image...',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for common strings
  String get appTitle => translate('appTitle');
  String get onboardingPage1Title => translate('onboardingPage1Title');
  String get onboardingPage1Description =>
      translate('onboardingPage1Description');
  String get onboardingPage2Title => translate('onboardingPage2Title');
  String get onboardingPage2Description =>
      translate('onboardingPage2Description');
  String get onboardingPage3Title => translate('onboardingPage3Title');
  String get onboardingPage3Description =>
      translate('onboardingPage3Description');
  String get skip => translate('skip');
  String get next => translate('next');
  String get previous => translate('previous');
  String get startNow => translate('startNow');
  String get language => translate('language');
  String get selectLanguage => translate('selectLanguage');
  String get arabic => translate('arabic');
  String get english => translate('english');
  String get settings => translate('settings');
  String get logout => translate('logout');
  String get logoutConfirmation => translate('logoutConfirmation');
  String get logoutDescription => translate('logoutDescription');
  String get cancel => translate('cancel');
  String get profile => translate('profile');

  // Login
  String get login => translate('login');
  String get phone => translate('phone');
  String get password => translate('password');
  String get loginButton => translate('loginButton');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get register => translate('register');
  String get phoneRequired => translate('phoneRequired');
  String get passwordRequired => translate('passwordRequired');

  // Register
  String get selectRole => translate('selectRole');
  String get selectRoleSubtitle => translate('selectRoleSubtitle');
  String get registerTitle => translate('registerTitle');
  String get registerButton => translate('registerButton');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get backToLogin => translate('backToLogin');
  String get registerSuccess => translate('registerSuccess');

  // Roles
  String get roleUser => translate('roleUser');
  String get roleEngineer => translate('roleEngineer');
  String get roleSeller => translate('roleSeller');
  String get roleMerchant => translate('roleMerchant');

  // Register Fields
  String get name => translate('name');
  String get nameRequired => translate('nameRequired');
  String get address => translate('address');
  String get addressRequired => translate('addressRequired');
  String get country => translate('country');
  String get countryRequired => translate('countryRequired');
  String get city => translate('city');
  String get cityRequired => translate('cityRequired');
  String get state => translate('state');
  String get stateRequired => translate('stateRequired');
  String get workshopName => translate('workshopName');
  String get workshopNameRequired => translate('workshopNameRequired');
  String get natureOfWork => translate('natureOfWork');
  String get natureOfWorkRequired => translate('natureOfWorkRequired');
  String get facebookLink => translate('facebookLink');
  String get whatsappNumber => translate('whatsappNumber');
  String get imageRequired => translate('imageRequired');
  String get uploadImage => translate('uploadImage');
  String get imageUploadFailed => translate('imageUploadFailed');
  String get uploadingImage => translate('uploadingImage');
  String get pickingImage => translate('pickingImage');
  String get tapToSelect => translate('tapToSelect');

  // Home
  String get home => translate('home');
  String get welcome => translate('welcome');
  String get defaultUserName => translate('defaultUserName');
  String get homeCategoryMaintenance => translate('homeCategoryMaintenance');
  String get homeCategoryUsedMachines => translate('homeCategoryUsedMachines');
  String get homeCategoryManufacturingSupplies =>
      translate('homeCategoryManufacturingSupplies');
  String get homeCategoryCompanyDirectory =>
      translate('homeCategoryCompanyDirectory');
  String get homeCategoryDesigns => translate('homeCategoryDesigns');
  String get homeCategoryWorkshopDirectory =>
      translate('homeCategoryWorkshopDirectory');
  String get errorLoadingSliders => translate('errorLoadingSliders');

  // Contact Us
  String get contactUs => translate('contactUs');
  String get contactSuccess => translate('contactSuccess');
  String get submitContact => translate('submitContact');

  // Complaint
  String get complaint => translate('complaint');
  String get complaintSuccess => translate('complaintSuccess');
  String get submitComplaint => translate('submitComplaint');

  // Form Fields
  String get email => translate('email');
  String get emailRequired => translate('emailRequired');
  String get invalidEmail => translate('invalidEmail');
  String get subject => translate('subject');
  String get subjectRequired => translate('subjectRequired');
  String get subjectMinLength => translate('subjectMinLength');
  String get message => translate('message');
  String get messageHint => translate('messageHint');
  String get messageRequired => translate('messageRequired');
  String get messageMinLength => translate('messageMinLength');
  String get nameInvalidFormat => translate('nameInvalidFormat');

  // Used Machines
  String get usedMachines => translate('usedMachines');
  String get addUsedMachine => translate('addUsedMachine');
  String get machineName => translate('machineName');
  String get machineNameHint => translate('machineNameHint');
  String get machineNameRequired => translate('machineNameRequired');
  String get machinePrice => translate('machinePrice');
  String get machinePriceHint => translate('machinePriceHint');
  String get machinePriceRequired => translate('machinePriceRequired');
  String get invalidPrice => translate('invalidPrice');
  String get machineDescription => translate('machineDescription');
  String get machineDescriptionHint => translate('machineDescriptionHint');
  String get machineDescriptionRequired =>
      translate('machineDescriptionRequired');
  String get uploadMachineImage => translate('uploadMachineImage');
  String get addMachine => translate('addMachine');
  String get machineAddedSuccess => translate('machineAddedSuccess');
  String get noMachinesAvailable => translate('noMachinesAvailable');
  String get retry => translate('retry');
  String get sellerInfo => translate('sellerInfo');
  String get createdAt => translate('createdAt');
  String get usedMachinesDisclaimer => translate('usedMachinesDisclaimer');
  String get maintenanceImageRequired => translate('maintenanceImageRequired');
  String get imageUploadSuccess => translate('imageUploadSuccess');
  String get errorPickingMedia => translate('errorPickingMedia');
  String get video => translate('video');
  String get videoUnavailable => translate('videoUnavailable');
  String get maintenanceUploadingImage =>
      translate('maintenanceUploadingImage');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
