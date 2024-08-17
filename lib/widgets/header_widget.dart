import 'package:flutter/material.dart';

class HeaderComponent extends StatefulWidget implements PreferredSizeWidget {
  const HeaderComponent({Key? key}) : super(key: key);

  @override
  _HeaderComponentState createState() => _HeaderComponentState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Default AppBar height
}

class _HeaderComponentState extends State<HeaderComponent> {
  final ValueNotifier<Color> _colorNotifier = ValueNotifier(const Color.fromARGB(255, 230, 141, 134));
  final ValueNotifier<Locale> _localeNotifier = ValueNotifier(const Locale('en', 'US'));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: _colorNotifier,
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
                      _colorNotifier.value = _colorNotifier.value == const Color.fromARGB(255, 230, 141, 134) ? const Color.fromARGB(255, 155, 192, 221) : const Color.fromARGB(255, 230, 141, 134);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      _localeNotifier.value = _localeNotifier.value.languageCode == 'en' ? const Locale('es', 'ES') : const Locale('en', 'US');
                      // You need to implement the actual language switching in your app
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