import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:memory_weakness/router.dart';
import 'package:memory_weakness/ui/play/play_setting_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart' as provider;

void main() {
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (_) => SettingViewModel(),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: MyApp.new,
        ),
      ),
    ),
  );
}

const materialWhite = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        return MaterialApp.router(
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          title: 'Memory Weakness',
          builder: (context, widget) {
            ScreenUtil.init(
              constraints,
              context: context,
              designSize: const Size(360, 690),
            );
            return widget!;
          },
          theme: ThemeData(
            primarySwatch: materialWhite,
          ),
          darkTheme: ThemeData.dark(),
        );
      },
    );
  }
}
