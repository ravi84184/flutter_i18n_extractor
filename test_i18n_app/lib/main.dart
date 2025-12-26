import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:test_i18n_app/l10n/app_locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    _localization.init(
      mapLocales: [
        const MapLocale(
          'en',
          AppLocale.EN,
          countryCode: 'US',
          fontFamily: 'Font EN',
        ),
      ],
      initLanguageCode: 'en',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _localization.currentLocale,
      supportedLocales: _localization.supportedLocales,
      localizationsDelegates: _localization.localizationsDelegates,
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final FlutterLocalization _localization = FlutterLocalization.instance;

  final String textString = "textString";

  final String textString1 = "textString1";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocale.english.getString(context))),
      body: Builder(
        builder: (context) {
          final String textString2 = "textString2";
          return Column(
            children: [
              Text(
                "Welcome Back $textString test $textString2 and $textString",
              ),
              Text("Login"),
              Text("Invalid OTP"),
              Text("Invalid OTP"),
              Text("Invalid OTP"),
              ElevatedButton(
                child: const Text('English'),
                onPressed: () {
                  _localization.translate('en');
                },
              ),
              ElevatedButton(
                child: const Text('ភាសាខ្មែរ'),
                onPressed: () {
                  _localization.translate('km');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
