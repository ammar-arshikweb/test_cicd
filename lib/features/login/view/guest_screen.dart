import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:panamera_app/features/customer/home/model/project_model.dart';
import 'package:panamera_app/gen/assets.gen.dart';
import 'package:panamera_app/responsive/screen_size_config.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/utils/system_ui_manager.dart';
import 'package:panamera_app/values/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class GuestScreen extends StatelessWidget {
  final List<ProjectModel> projectImages;
  const GuestScreen({super.key, required this.projectImages});

  @override
  Widget build(BuildContext context) {
    var strings = Helper.getLocalization()!;
    var padding = 20.0;
    SystemUIManager.setSystemUI(context: context, statusBarColor: MColors.white);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: MColors.black, size: 30), onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop())),
        backgroundColor: MColors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Text(strings.welcome_to, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w400)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Text(strings.panamera_living, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 20),
            CarouselWithIndicator(imageList: projectImages),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Text(
                'Step into a world where your garden \nblooms with possibility, your pool \nbeckons with crystal-clear invitation, \nand your interiors reflect the very \nessence of your style. With us, you’re \nnot just getting a service; you’re \nembarking on a journey to elevate your \nspace from mundane to magnificent. \nWelcome to the art of living, \nre-imagined.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400,letterSpacing: 1),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(strings.get_inspired, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildContainer(Assets.images.instagram,'https://www.instagram.com/panameraliving/'),
                        const SizedBox(width: 10),
                        buildContainer(Assets.images.youtube,'https://www.youtube.com/@panameraliving'),
                        const SizedBox(width: 10),
                        buildContainer(Assets.images.linkedin,'https://www.linkedin.com/company/panamera-living/'),
                        const SizedBox(width: 10),
                        buildContainer(Assets.images.pinterest,'https://www.pinterest.com/panameralandscapes/'),
                        const SizedBox(width: 10),
                        buildContainer(Assets.images.whatsapp,'https://wa.me/971527419882?text='),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: ()=> GlobalTap.safeTap(() => _launchUrl('https://panameralandscape.com/')),
                      child: Text(
                        strings.visit_website,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  InkWell buildContainer(String asset,String url) {
    return InkWell(
      onTap: ()=> GlobalTap.safeTap(() => _launchUrl(url)),
      child: Container(
        height: 35,
        width: 35,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Color(0xFF182128), borderRadius: BorderRadius.circular(15)),
        child: SvgPicture.asset(asset, height: 18, width: 18),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}


class CarouselWithIndicator extends StatefulWidget {
  final List<ProjectModel> imageList;
  const CarouselWithIndicator({super.key, required this.imageList});

  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: 200.0,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            enlargeFactor: 0.1,
            viewportFraction: 0.95,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: [
            ...widget.imageList.map((project) {
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
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                widget.imageList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key, duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn),
                    child: Container(
                      width: 5.0,
                      height: 5.0,
                      margin: EdgeInsets.only(top: 8.0, right: 2.0, left: 2.0),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: MColors.white.withValues(alpha: _current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
