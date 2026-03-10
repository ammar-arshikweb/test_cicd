import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/custom_dropdown.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/customer/home/repository/customer_home_repo.dart';
import 'package:panamera_app/features/customer/main_page/repository/customer_main_page_repo.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late AppLocalizations strings;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  CustomerModel? _customerModel;
  String? _selectedEmirate;
  String _selectedCountryCode = '+971'; // Default to UAE
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    getCustomerDetails(context);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.clear();
    _emailController.clear();
    _numberController.clear();
    _selectedEmirate = null;
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
    SystemUIManager.setSystemUI(context: context,statusBarColor: MColors.green.withValues(alpha: 0.2));
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MColors.green.withValues(alpha: 0.2), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(strings.update_your_profile.toUpperCase(), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 50),
                Text(strings.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                TextField(
                  controller: _nameController,
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MColors.white,
                    hintText: strings.title,
                    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                Text(strings.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MColors.white,
                    hintText: strings.email,
                    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                Text(strings.date_of_birth, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                _buildDatePicker(),
                const SizedBox(height: 20),
                Text(strings.contact_number, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: MColors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        border: Border(right: BorderSide(color: MColors.grey.withValues(alpha: 0.5))),
                      ),
                      child: CountryCodePicker(
                        onChanged: (code) => setCountryCode(code),
                        initialSelection: _selectedCountryCode,
                        favorite: ['+971', '+91'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        textStyle: TextStyle(fontSize: 14, color: MColors.black),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _numberController,
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 12,
                        decoration: InputDecoration(
                          counter: const SizedBox(),
                          filled: true,
                          fillColor: MColors.white,
                          hintText: strings.contact_number,
                          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.grey),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(strings.emirate, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                MCustomDropdown<String>(
                  label: null,
                  labelStyle: null,
                  borderColor: MColors.white,
                  showSearch: false,
                  hintText: strings.select_emirate,
                  initialItem: _selectedEmirate,
                  items: Constant.emiratesList,
                  onChanged: (value) {
                    setState(() {
                      _selectedEmirate = value;
                    });
                  },
                ),
                const SizedBox(height: 70),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: MColors.primaryGreen.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(2)),
                        child: TextButton(
                          onPressed: () => GlobalTap.safeTap(() {
                            Navigator.of(context).pop();
                          }),
                          child: Text(
                            strings.back,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: MColors.lightGreen, borderRadius: BorderRadius.circular(2)),
                        child: TextButton(
                          onPressed: () => GlobalTap.safeTap(() {
                            updateCustomer(context);
                          }),
                          child: Text(
                            strings.submit,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => GlobalTap.safeTap(() {
        _showDatePicker();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MColors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDob != null ? DateFormat(Constant.dd_MM_yyyy_slash).format(_selectedDob!) : strings.select_date,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Icon(Icons.calendar_today, color: MColors.primaryGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? TimeUtils.getCurrentDateTime(),
      firstDate: DateTime(1900),
      lastDate: TimeUtils.getCurrentDateTime(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: strings.select_date_of_birth,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: MColors.primaryGreen, primary: MColors.primaryGreen),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            datePickerTheme: DatePickerThemeData(
              headerHelpStyle: Theme.of(context).textTheme.displaySmall?.copyWith(color: MColors.white, fontWeight: FontWeight.w600),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  void setCountryCode(CountryCode value) {
    _selectedCountryCode = value.dialCode!;
    setState(() {});
  }

  updateCustomer(BuildContext context) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _numberController.text.isEmpty || _selectedEmirate == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_fill_all_fields);
      return;
    }
    if (!isValidEmail(_emailController.text)) {
      SnackBarMsg.showErrorMessage(context, strings.please_enter_valid_email);
      return;
    }
    try {
      context.showLoader();

      CustomerModel customerModel = CustomerModel(
        customerId: Pref.getCustomerStringId(),
        customerName: _nameController.text,
        email: _emailController.text,
        contactNumber: '$_selectedCountryCode ${_numberController.text}',
        emirate: _selectedEmirate,
        dateOfBirth: _selectedDob != null ? DateFormat(Constant.yyyy_MM_dd).format(_selectedDob!) : null,
        villaList: _customerModel?.villaList,
      );

      final apiRes = await CustomerMainPageRepo().updateCustomer(customerModel);
      if (apiRes.data != null && apiRes.status!) {
        Pref.setCustomerName(apiRes.data!.customerName ?? '');
        Pref.setCustomerEmail(apiRes.data!.email ?? '');
        Pref.setCustomerContactNumber(apiRes.data!.contactNumber ?? '');
        Pref.setCustomerEmirate(apiRes.data!.emirate ?? '');
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        Navigator.of(context).pop();
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? strings.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error while fetching customer: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
  }

  getCustomerDetails(BuildContext context) async {
    try {
      context.showLoader();
      final apiRes = await CustomerHomeRepo().getCustomerDetail();
      if (apiRes.successMessage != null && apiRes.data != null) {
        _customerModel = apiRes.data;
        _nameController.text = apiRes.data!.customerName ?? '';
        _emailController.text = apiRes.data!.email ?? '';
        _numberController.text = apiRes.data!.contactNumber?.split(' ').last ?? '';
        _selectedCountryCode = apiRes.data!.contactNumber?.split(' ').first ?? '+971';
        _selectedEmirate = apiRes.data!.emirate ?? '';
        _selectedDob = DateTime.tryParse(apiRes.data!.dateOfBirth ?? '');
      }
    } catch (e) {
      Log.e("Error in getCustomerDetails: $e");
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      setState(() {});
    }
  }

  bool isValidEmail(String email) {
    String emailPattern = r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$';
    return RegExp(emailPattern).hasMatch(email);
  }
}
