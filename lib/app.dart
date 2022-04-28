import 'package:flutter/material.dart';
import 'package:timer/timer/view/timer_page.dart';
import 'package:timer/utils.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      title: 'Flutter Timer',
      theme: ThemeData.light(),
      home: const TimerPage(),
    );
  }
}