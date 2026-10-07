import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'data/waitlist_repository.dart';
import 'state/waitlist_controller.dart';
import 'ui/waitlist_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.open();
  final controller = WaitlistController(WaitlistRepository(database));
  await controller.load();
  runApp(ChangeNotifierProvider.value(value: controller, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waitlist',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const WaitlistScreen(),
    );
  }
}
