import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool safeArea;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.safeArea = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: body,
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
