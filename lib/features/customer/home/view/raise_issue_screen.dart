import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panamera_app/comman_widget/custom_loader.dart';
import 'package:panamera_app/comman_widget/custom_dropdown.dart';
import 'package:panamera_app/comman_widget/image_widgets.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/customer/home/model/task_model.dart';
import 'package:panamera_app/features/customer/home/repository/customer_home_repo.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/snackbar_messages.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';

class RaiseIssueScreen extends StatefulWidget {
  final bool isRaiseIssue;
  final List<VillaModel> villaList;

  const RaiseIssueScreen({super.key, required this.isRaiseIssue, required this.villaList});

  @override
  State<RaiseIssueScreen> createState() => _RaiseIssueScreenState();
}

class _RaiseIssueScreenState extends State<RaiseIssueScreen> {
  late AppLocalizations strings;
  final picker = ImagePicker();
  final List<XFile> _images = [];
  int? _selectedVilla;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _images.clear();
    _titleController.clear();
    _descController.clear();
  }

  Future<void> pickFromGallery(BuildContext context, bool isCamera) async {
    if (isCamera) {
      // Camera allows only single image (already compressed by imageQuality param)
      final file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (file != null) {
        context.showLoader();

        final XFile? timestampedFile = await ImageWidgets.addTimestampFast(file);

        if (timestampedFile != null) {
          _images.add(timestampedFile);
        }
        context.hideLoader();
        setState(() {});
      }
    } else {
      // Gallery allows multiple images
      context.showLoader(); // Show loader BEFORE picking

      final List<XFile> files = await picker.pickMultiImage(
        imageQuality: 60, // Note: This param is ignored for gallery in most cases
        maxWidth: 1920,
        maxHeight: 1920,
      );

      final limitedFiles = files.take(Constant.IMAGE_LIMIT - _images.length).toList();

      if (limitedFiles.isNotEmpty) {
        // Process images in parallel for faster processing
        final results = await Future.wait(
          limitedFiles.map((file) async {
            try {
              return await ImageWidgets.addTimestampFast(file);
            } catch (e) {
              Log.e('Error processing image: $e');
              return null;
            }
          }),
        );

        for (final timestampedFile in results) {
          if (timestampedFile != null) {
            _images.add(timestampedFile);
          }
        }
        setState(() {});
      }

      context.hideLoader();
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
    SystemUIManager.setSystemUI(context: context,statusBarColor: MColors.green.withValues(alpha: 0.2));
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => GlobalTap.safeTap(() => FocusScope.of(context).unfocus()), // Dismiss keyboard on tap outside
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
                  const SizedBox(height: 40),
                  Text(strings.book_service.toUpperCase(), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 50),
                  Text(
                    widget.isRaiseIssue ? strings.raise_an_issue.toUpperCase() : strings.cleaning_task.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Text('${strings.title} *', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MColors.white,
                      hintText: strings.ex_garden_cleaning_pool_cleaning,
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('${strings.villa} *', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  MCustomDropdown<int>(
                    label: null,
                    labelStyle: null,
                    borderColor: MColors.white,
                    showSearch: false,
                    // enable search since villa list can be long
                    initialItem: _selectedVilla,
                    hintText: strings.select_villa,
                    items: widget.villaList.map((villa) => villa.villaId!).toList(),
                    headerBuilder: (context, item, isSelected) {
                      final villa = widget.villaList.firstWhere(
                        (v) => v.villaId == item,
                        orElse: () => VillaModel(villaId: -1, villaName: strings.select_villa),
                      );
                      return Text(
                        villa.villaName ?? strings.select_villa,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black, fontWeight: FontWeight.w500),
                      );
                    },
                    listItemBuilder: (context, item, isSelected, onItemSelect) {
                      final villa = widget.villaList.firstWhere(
                        (v) => v.villaId == item,
                        orElse: () => VillaModel(villaId: -1, villaName: strings.select_villa),
                      );
                      return GestureDetector(
                        onTap: () => GlobalTap.safeTap(onItemSelect),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: Colors.transparent,
                          child: Text(villa.villaName ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black)),
                        ),
                      );
                    },
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedVilla = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('${strings.description} *', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MColors.white,
                      hintText: strings.please_provide_brief_about_your_requirement,
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(strings.images, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  buildUploadPhotoView(strings),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          // width: 200,
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
                          // width: 200,
                          decoration: BoxDecoration(color: MColors.lightGreen, borderRadius: BorderRadius.circular(2)),
                          child: TextButton(
                            onPressed: () => GlobalTap.safeTap(() {
                              addTaskOrIssue(context);
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
                  // const SizedBox(height: 10),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUploadPhotoView(AppLocalizations strings) {
    if (_images.isEmpty) {
      return InkWell(
        onTap: () => GlobalTap.safeTap(() {
          showCupertinoModalPopup(
            context: context,
            builder:
                (ctx) => CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                      child: Text(strings.gallery),
                      onPressed: () => GlobalTap.safeTap(() {
                        Navigator.of(ctx).pop();
                        pickFromGallery(context, false);
                      }),
                    ),
                    CupertinoActionSheetAction(
                      child: Text(strings.camera),
                      onPressed: () => GlobalTap.safeTap(() {
                        Navigator.of(ctx).pop();
                        pickFromGallery(context, true);
                      }),
                    ),
                  ],
                ),
          );
        }),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(border: Border.all(color: MColors.primaryGreen, width: 2), borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Icon(Icons.camera_alt, color: MColors.primaryGreen, size: 32),
              SizedBox(height: 8),
              Text(strings.upload_photo, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 5,),
              Text(strings.max_20_images, style: TextStyle(color: MColors.grey),),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 150,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(border: Border.all(color: MColors.primaryGreen, width: 2), borderRadius: BorderRadius.circular(8)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ..._images.asMap().entries.map((entry) {
                    int index = entry.key;
                    var imageFile = entry.value;
                    return InkWell(
                      onTap: () => GlobalTap.safeTap(() => ImageWidgets.showFileImageDialog(context, imageFile.path, _images.map((e) => e.path).toList())),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(imageFile.path), width: 40, height: 40, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => GlobalTap.safeTap(() => removeImage(index)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: MColors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 14, color: MColors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_images.length < 5)
                    GestureDetector(
                      onTap: () => GlobalTap.safeTap(() {
                        showCupertinoModalPopup(
                          context: context,
                          builder:
                              (ctx) => CupertinoActionSheet(
                                actions: [
                                  CupertinoActionSheetAction(
                                    child: Text(strings.gallery),
                                    onPressed: () => GlobalTap.safeTap(() {
                                      Navigator.of(ctx).pop();
                                      pickFromGallery(context, false);
                                    }),
                                  ),
                                  CupertinoActionSheetAction(
                                    child: Text(strings.camera),
                                    onPressed: () => GlobalTap.safeTap(() {
                                      Navigator.of(ctx).pop();
                                      pickFromGallery(context, true);
                                    }),
                                  ),
                                ],
                              ),
                        );
                      }),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: MColors.primaryGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.add, color: MColors.primaryGreen, size: 30),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5,),
              Align(alignment: Alignment.centerLeft, child: Text(strings.max_20_images, style: TextStyle(color: MColors.grey),)),
            ],
          ),
        ),
      );
    }
  }

  addTaskOrIssue(BuildContext context) async {
    try {
      if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty || _selectedVilla == null) {
        SnackBarMsg.showErrorMessage(context, strings.please_fill_all_fields);
        return;
      }
      context.showLoader();

      TaskModel task = TaskModel(
        taskName: _titleController.text.trim(),
        customerId: Pref.getCustomerStringId(),
        villaId: _selectedVilla,
        jobType: 0,
        notes: _descController.text.trim(),
        approvalStatus: 0,
        taskType: widget.isRaiseIssue ? 1 : 0,
        taskStatus: 0,
        imagesFile: _images,
        wasRequested: true,
      );

      final apiRes = await CustomerHomeRepo().addTask(task);
      if (apiRes.status == true) {
        if (!context.mounted) return;
        SnackBarMsg.showSuccessMessage(context, apiRes.successMessage);
        Navigator.of(context).pop();
      }
    } catch (e) {
      Log.e('Error addTaskOrIssue: $e');
    } finally {
      context.hideLoader();
      setState(() {});
    }
  }
}
