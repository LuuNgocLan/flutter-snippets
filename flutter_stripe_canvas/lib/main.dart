import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'diagonal_stripe/diagonal_stripe_pattern_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stripe Canvas Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
      ),
      body: _buildMedia(1.0),
    );
  }

  Widget _buildMedia(double ratio) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Center(
          child: Stack(
            children: [
              Image.asset(
                'assets/images/img_sample.png',
                width: width,
                height: ratio * width,
                fit: BoxFit.cover,
              ),
              // SvgPicture.asset(
              //   'assets/images/img_pattern.svg',
              //   width: width,
              //   height: ratio * width,
              //   fit: BoxFit.cover,
              // ),
              SizedBox(
                width: width,
                height: ratio * width,
                child: const DiagonalStripePatternView(),
              ),
            ],
          ),
        );
      },
    );
  }
}
