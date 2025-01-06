import 'package:clinic_project/config.dart';
import 'package:clinic_project/login_page.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "./lib/assets/onboarding1.png",
      "title": "Selamat Datang",
      "description":
          "Aplikasi kami membantu Anda mengelola janji temu dengan mudah."
    },
    {
      "image": "./lib/assets/onboarding2.png",
      "title": "Pantau Kesehatan Anda",
      "description":
          "Lihat rekam medis dan kelola informasi kesehatan Anda di satu tempat."
    },
    {
      "image": "./lib/assets/onboarding3.png",
      "title": "Mulai Sekarang",
      "description":
          "Buat akun dan mulai perjalanan kesehatan Anda bersama kami."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingData(
                  title: _onboardingData[index]["title"]!,
                  image: _onboardingData[index]["image"]!,
                  description: _onboardingData[index]["description"]!,
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: (_currentPage != _onboardingData.length - 1)
                    ? Components.textButton(
                        text: "Skip",
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        })
                    : const Text(""),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 16 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppConfig.colorA
                          : AppConfig.colorB,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: _currentPage == _onboardingData.length - 1
                    ? Components.textButton(
                        text: "Mulai",
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        })
                    : IconButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_forward
                        )
                      )
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class OnboardingData extends StatelessWidget {
  final String title;
  final String image;
  final String description;

  const OnboardingData({
    super.key,
    required this.title,
    required this.image,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          image,
          height: 250,
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
