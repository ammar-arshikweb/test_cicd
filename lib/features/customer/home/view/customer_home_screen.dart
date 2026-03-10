import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:panamera_app/comman_widget/confirmation_dialog.dart';
import 'package:panamera_app/features/customer/home/model/customer_model.dart';
import 'package:panamera_app/features/customer/home/view/feedback_screen.dart';
import 'package:panamera_app/features/customer/home/view/home_maintenance_screen.dart';
import 'package:panamera_app/features/customer/home/view/raise_issue_screen.dart';
import 'package:panamera_app/features/customer/home/view/track_request_screen.dart';
import 'package:panamera_app/features/customer/home/view_model/customer_home_view_model.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/preference.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/utils/time_utils.dart';
import 'package:panamera_app/utils/utils.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:provider/provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late AppLocalizations strings;
  late CustomerHomeViewModel _customerHomeViewModel;
  final horizontalPadding = 15.0;

  @override
  void initState() {
    super.initState();
    _customerHomeViewModel = Provider.of<CustomerHomeViewModel>(context, listen: false);
    _customerHomeViewModel.initModel(context);
  }

  @override
  void dispose() {
    super.dispose();
    _customerHomeViewModel.resetModel();
  }

  @override
  Widget build(BuildContext context) {
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.green.withValues(alpha: 0.2));
    strings = Helper.getLocalization()!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MColors.green.withValues(alpha: 0.2), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: MColors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Consumer<CustomerHomeViewModel>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: buildNameAndDateText(),
                    ),
                    const SizedBox(height: 28),
                    _buildMyPropertiesSection(provider),
                    const SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: _buildBookServiceSection(provider),
                    ),
                    const SizedBox(height: 22),
                    _buildLatestProjectsSection(provider),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNameAndDateText() {
    var name = Pref.getCustomerName().toUpperCase();
    var time = TimeUtils.getCurrentDateTimeInLocal(Constant.EEEE_dd_MM_yyyy);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Utils.getGreetingBasedOnTime(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Text('${strings.hello}, $name!', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('${strings.date} : $time', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMyPropertiesSection(CustomerHomeViewModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding + 10),
          child: Text(strings.my_properties, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        CarouselWithIndicator(villaList: provider.villaList),
      ],
    );
  }

  Widget _buildBookServiceSection(CustomerHomeViewModel provider) {
    final List<ServiceCardItem> serviceCards = [
      ServiceCardItem(
        title: strings.raise_issue,
        image: Assets.images.raiseIssue,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RaiseIssueScreen(isRaiseIssue: true, villaList: provider.villaList)));
        },
      ),
      ServiceCardItem(
        title: strings.emergency_requests,
        image: Assets.images.emergencyRequest,
        onTap: () {
          comingSoonDialog(context: context);
        },
      ), // ServiceCardItem(
      //   title: strings.payments,
      //   image: Assets.images.payments,
      //   onTap: () {
      //     comingSoonDialog(context: context);
      //   },
      // ),
      ServiceCardItem(
        title: strings.track_request,
        image: Assets.images.trackRequest,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TrackRequestScreen()));
        },
      ),
      ServiceCardItem(
        title: strings.feedback,
        image: Assets.images.feedback,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen()));
        },
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.services, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: serviceCards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // number of columns
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1, // adjust based on your card shape
          ),
          itemBuilder: (context, index) {
            final item = serviceCards[index];
            return _buildServiceCard(item.title, item.image, item.onTap);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(String title, String icon, VoidCallback onTap) {
    return InkWell(
      onTap: () => GlobalTap.safeTap(onTap),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: MColors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: MColors.black, width: 0.3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 40, height: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, height: 1),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestProjectsSection(CustomerHomeViewModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding + 10),
          child: Text(
            strings.latest_panamera_projects,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        CarouselSlider(
          // carouselController: _controller,
          options: CarouselOptions(height: 180.0, enableInfiniteScroll: false, enlargeCenterPage: true, enlargeFactor: 0.2, viewportFraction: 0.9),
          items: [
            ...provider.projectImages.map((project) {
              return Builder(
                builder: (BuildContext context) {
                  return Card(
                    elevation: 2,
                    shadowColor: MColors.black,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: project.imageUrl ?? '',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.image_not_supported, size: 80, color: MColors.primaryGreen)],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}

class CarouselWithIndicator extends StatefulWidget {
  final List<VillaModel> villaList;
  const CarouselWithIndicator({super.key, required this.villaList});

  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: 120.0,
            enableInfiniteScroll: widget.villaList.length > 1,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: widget.villaList.map((villa) {
            return Builder(
              builder: (BuildContext context) {
                return Card(
                  elevation: 5,
                  shadowColor: MColors.black,
                  child: Container(
                    decoration: BoxDecoration(color: MColors.green.withValues(alpha: 0.2), borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CachedNetworkImage(
                              imageUrl: villa.villaImage ?? '',
                              width: 120,
                              height: 100,
                              fit: BoxFit.cover,
                              errorWidget: (context, error, stackTrace) {
                                return Icon(Icons.home, size: 80, color: MColors.primaryGreen);
                              },
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  villa.villaName ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  villa.community ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => GlobalTap.safeTap(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeMaintenanceScreen(villaId: villa.villaId ?? 0, villaName: villa.villaName ?? ''),
                                      ),
                                    );
                                  }),
                                  child: Row(
                                    children: [
                                      Text(
                                        Helper.getLocalization()!.view_details,
                                        style: const TextStyle(
                                          color: MColors.blue,
                                          decoration: TextDecoration.underline,
                                          decorationColor: MColors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward, color: MColors.blue, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.villaList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key, duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn),
              child: Container(
                width: 10.0,
                height: 10.0,
                margin: EdgeInsets.only(top: 8.0, right: 4.0, left: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MColors.primaryGreen.withValues(alpha: _current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ServiceCardItem {
  final String title;
  final String image;
  final VoidCallback onTap;

  ServiceCardItem({required this.title, required this.image, required this.onTap});
}
