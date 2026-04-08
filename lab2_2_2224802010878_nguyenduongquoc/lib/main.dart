import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ResponsiveHomePage(),
    );
  }
}

class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({super.key});

  // Màu
  static const colorBody = Color(0xFFF8E287);
  static const colorNav = Color(0xFFC5ECCE);
  static const colorPane = Color(0xFFEEE2BC);

  static const style = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const bodyWidget = Center(child: Text('Body', style: style));
  static const navWidget = Center(child: Text('Navigation', style: style));
  static const paneWidget = Center(child: Text('Pane', style: style));

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenWidth < 600
              ? 'Responsive UI - Phone'
              : screenWidth < 840
                  ? 'Responsive UI - Tablet'
                  : screenWidth < 1200
                      ? 'Responsive UI - Landscape'
                      : 'Responsive UI - Desktop',
        ),
      ),
      body: screenWidth < 600
          ? buildCompactScreen()
          : screenWidth < 840
              ? buildMediumScreen()
              : screenWidth < 1200
                  ? buildExpandedScreen()
                  : buildLargeScreen(),
    );
  }

  // Phone
  Widget buildCompactScreen() {
    return Column(
      children: [
        Expanded(
          child: Container(color: colorBody, child: bodyWidget),
        ),
        Container(
          height: 80,
          color: colorNav,
          child: navWidget,
        ),
      ],
    );
  }

  // Tablet
  Widget buildMediumScreen() {
    return Row(
      children: [
        Container(
          width: 80,
          color: colorNav,
          child: navWidget,
        ),
        Expanded(
          child: Container(color: colorBody, child: bodyWidget),
        ),
      ],
    );
  }

  // Landscape
  Widget buildExpandedScreen() {
    return Row(
      children: [
        Container(width: 80, color: colorNav, child: navWidget),
        Container(width: 360, color: colorBody, child: bodyWidget),
        Expanded(
          child: Container(color: colorPane, child: paneWidget),
        ),
      ],
    );
  }

  // Desktop
  Widget buildLargeScreen() {
    return Row(
      children: [
        Container(width: 360, color: colorNav, child: navWidget),
        Container(width: 360, color: colorBody, child: bodyWidget),
        Expanded(
          child: Container(color: colorPane, child: paneWidget),
        ),
      ],
    );
  }
}