import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peche_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class OnboardingController extends GetxController {
  late VideoPlayerController controller;

  @override
  void onInit() {
    super.onInit();
    controller = VideoPlayerController.asset('assets/vid/fish_on.mp4')
      ..initialize().then((_) {
        controller.setLooping(true);
        controller.play();
        update();
      });
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  Future<void> completeOnboarding() async {
    controller.pause();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Get.offAll(() => const LoginScreen());
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingController = Get.put(OnboardingController());

    return Scaffold(
      body: GetBuilder<OnboardingController>(
        builder: (_) {
          return Stack(
            children: [
              onboardingController.controller.value.isInitialized
                  ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: onboardingController.controller.value.size.width,
                        height:
                            onboardingController.controller.value.size.height,
                        child: VideoPlayer(onboardingController.controller),
                      ),
                    ),
                  )
                  : const Center(child: CircularProgressIndicator()),

              // Correction appliquée ici
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha((0.5 * 255).toInt()),
                ),
              ),

              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Le goût authentique de la mer sans intermédiaires',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Découvrez le meilleur de la pêche, sélectionné avec soin pour vous en simples clics",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 100),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        child: MaterialButton(
                          onPressed:
                              () => onboardingController.completeOnboarding(),
                          minWidth: double.infinity,
                          child: const Text(
                            "Commencer",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        child: Text(
                          "Pêche en toute confiance",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
