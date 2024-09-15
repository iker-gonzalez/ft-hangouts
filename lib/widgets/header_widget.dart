import 'package:flutter/material.dart';

class HeaderComponent extends StatefulWidget implements PreferredSizeWidget {
  final ValueNotifier<Locale> localeNotifier;

  const HeaderComponent({super.key, required this.localeNotifier});

  @override
  HeaderComponentState createState() => HeaderComponentState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Default AppBar height
}

class HeaderComponentState extends State<HeaderComponent> {
  final ValueNotifier<Color> colorNotifier = ValueNotifier(const Color.fromARGB(255, 230, 141, 134));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: colorNotifier,
      builder: (context, color, child) {
        return AppBar(
          backgroundColor: color,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/logo.png', height: 50), // replace with your logo
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () {
                      colorNotifier.value = colorNotifier.value == const Color.fromARGB(255, 230, 141, 134) ? const Color.fromARGB(255, 155, 192, 221) : const Color.fromARGB(255, 230, 141, 134);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      widget.localeNotifier.value = widget.localeNotifier.value.languageCode == 'en' ? const Locale('es', 'ES') : const Locale('en', 'US');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}