import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/custom_dropdown.dart';
import 'package:panamera_app/features/employee/main_page/repository/main_page_repo.dart';
import 'package:panamera_app/features/login/model/emp_login_res.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/values/colors.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  late AppLocalizations strings;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  EmployeeModel? _employeeModel;
  String? _selectedNationality;
  String _gender = Constant.MALE;
  DateTime? _selectedDob;
  DateTime? _selectedDoj;

  @override
  void initState() {
    super.initState();
    getEmployeeDetails(context);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.clear();
    _numberController.clear();
    _selectedNationality = null;
    _gender = Constant.MALE;
    _selectedDob = null;
    _selectedDoj = null;
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
    return Scaffold(
      backgroundColor: MColors.greyBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                    hintText: strings.name,
                    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                Text(strings.gender, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(color: MColors.white, borderRadius: BorderRadius.circular(8.0)),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent, hoverColor: Colors.transparent),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            activeColor: MColors.primaryGreen,
                            title: Text(strings.male),
                            value: Constant.MALE,
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            activeColor: MColors.primaryGreen,
                            title: Text(strings.female),
                            value: Constant.FEMALE,
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(strings.date_of_birth, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                _buildDobPicker(),
                const SizedBox(height: 20),
                Text(strings.date_of_joining, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                _buildDojPicker(),
                const SizedBox(height: 20),
                Text(strings.contact_number, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Row(
                  children: [
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
                Text(strings.nationality, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                MCustomDropdown<String>(
                  label: null,
                  labelStyle: null,
                  borderColor: MColors.white,
                  showSearch: false,
                  hintText: strings.select_nationality,
                  initialItem: _selectedNationality,
                  items: Constant.nationalityList,
                  onChanged: (value) {
                    setState(() {
                      _selectedNationality = value;
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
                            updateEmployee(context);
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

  Widget _buildDobPicker() {
    return InkWell(
      onTap: () => GlobalTap.safeTap(() {
        _showDatePicker(true);
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

  Widget _buildDojPicker() {
    return InkWell(
      onTap: () => GlobalTap.safeTap(() {
        _showDatePicker(false);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MColors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDoj != null ? DateFormat(Constant.dd_MM_yyyy_slash).format(_selectedDoj!) : strings.select_date,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Icon(Icons.calendar_today, color: MColors.primaryGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(bool isDob) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDob ? _selectedDob ?? TimeUtils.getCurrentDateTime() : _selectedDoj ?? TimeUtils.getCurrentDateTime(),
      firstDate: DateTime(1900),
      lastDate: isDob ? TimeUtils.getCurrentDateTime() : DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: isDob ? strings.select_date_of_birth : strings.select_date_of_join,
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
    FocusScope.of(context).requestFocus(FocusNode());
    if (picked != null && (isDob ? picked != _selectedDob : picked != _selectedDoj)) {
      setState(() {
        if (isDob) {
          _selectedDob = picked;
        } else {
          _selectedDoj = picked;
        }
      });
    }
  }

  updateEmployee(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        _numberController.text.isEmpty ||
        _selectedNationality == null ||
        _selectedDob == null ||
        _selectedDoj == null) {
      SnackBarMsg.showErrorMessage(context, strings.please_fill_all_fields);
      return;
    }
    try {
      context.showLoader();

      EmployeeModel employeeModel = EmployeeModel(
        fullName: _nameController.text.trim(),
        phoneNumber: _numberController.text.trim(),
        gender: _gender,
        nationality: _selectedNationality,
        dateOfBirth: DateFormat(Constant.yyyy_MM_dd).format(_selectedDob!),
        dateOfJoining: DateFormat(Constant.yyyy_MM_dd).format(_selectedDoj!),
      );

      final apiRes = await MainPageRepo().updateEmployee(employeeModel);
      if (apiRes.status!) {
        Pref.setEmpName(employeeModel.fullName ?? '');
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage!);
        Navigator.of(context).pop();
      } else {
        SnackBarMsg.showErrorMessage(context, apiRes.errorMessage ?? Helper.getLocalization()!.error_occurred_try_again);
      }
    } catch (e) {
      Log.e('Error while fetching customer: $e');
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
    }
  }

  getEmployeeDetails(BuildContext context) async {
    try {
      context.showLoader();
      final apiRes = await MainPageRepo().getEmployee();
      if (apiRes.successMessage != null && apiRes.data != null) {
        _employeeModel = apiRes.data;
        _nameController.text = apiRes.data!.fullName ?? '';
        _numberController.text = apiRes.data!.phoneNumber ?? '';
        _selectedNationality = apiRes.data!.nationality;
        _selectedDob = apiRes.data!.dateOfBirth != null ? DateTime.tryParse(apiRes.data!.dateOfBirth!) : null;
        _selectedDoj = apiRes.data!.dateOfJoining != null ? DateTime.tryParse(apiRes.data!.dateOfJoining!) : null;
        _gender = apiRes.data!.gender!;
      }
    } catch (e) {
      Log.e("Error in getEmployeeDetails: $e");
      SnackBarMsg.showError(context);
    } finally {
      context.hideLoader();
      setState(() {});
    }
  }
}
