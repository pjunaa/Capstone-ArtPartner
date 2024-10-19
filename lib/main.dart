import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'services/hiveService.dart';
import 'utils/timerProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: MaterialApp(
        title: 'Art Partner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFC6BFA6)),
          scaffoldBackgroundColor: Color(0xffF0DFC8),
        ),
        home: const Home(),
      ),
    );
  }
}
