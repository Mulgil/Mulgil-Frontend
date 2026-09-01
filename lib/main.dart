import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'constants/routes.dart';
import 'app_routes_map.dart';

void main() {
  runApp(const MulgilApp());
}

class MulgilApp extends StatelessWidget {
  const MulgilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mulgil',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: generateAppRoute,
    );
  }
}
