import 'package:appointy/login/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildPage({
    required String imagePath,
    required String text,
    required Color textColor,
    required List<Color> colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 300),
          const SizedBox(height: 100),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: PageView(
          controller: controller,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: [
            _buildPage(
              imagePath: 'images/GoOn1.gif',
              text: 'Welcome to \n Go On'.tr,
              textColor: Colors.purple,
              colors: [
                const Color.fromARGB(255, 255, 255, 244),
                const Color.fromARGB(255, 255, 255, 244),
              ],
            ),
            _buildPage(
              imagePath: 'images/GoOn2.gif',
              text: 'Manage your appointments \n with ease.',
              textColor: Colors.white,
              colors: [
                const Color.fromARGB(255, 210, 64, 64),
                const Color.fromARGB(255, 210, 64, 64),
              ],
            ),
            _buildPage(
              imagePath: 'images/GoOn3.gif',
              text: 'Boost your business \n with us'.tr,
              textColor: Colors.purple,
              colors: [
                const Color.fromARGB(255, 255, 255, 254),
                const Color.fromARGB(255, 255, 255, 254)
              ],
            ),
          ],
        ),
      ),
      bottomSheet: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: isLastPage
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('ShowHome', true);

                  if (!mounted) return;

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => controller.jumpToPage(2),
                    child: const Text('Skip'),
                  ),
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: const WormEffect(
                      spacing: 16,
                      dotHeight: 12,
                      activeDotColor: Colors.purple,
                      dotColor: Colors.grey,
                    ),
                    onDotClicked: (index) => controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
      ),
    );
  }
}
