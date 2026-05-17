import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'JRR (bloc)',
      home: Scaffold(
        body: Center(child: Text('jrr_f_bloc — scaffold')),
      ),
    );
  }
}
