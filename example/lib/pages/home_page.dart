import 'package:flutter/material.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';
import 'package:provider/provider.dart';

/// Home page that demonstrates different features of the package
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final playerScreensController = context.read<NavigationControllerV3>();
    final pageController = playerScreensController.pageController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Listening Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: PageView.builder(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (int page) {},
            itemCount: 3,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const QuranListeningPage();
              } else if (index == 1 && context.read<PlayerScreensController>().reciter != null) {
                return const SurahPage();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

