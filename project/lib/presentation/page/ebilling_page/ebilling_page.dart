import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class EBillingPage extends StatelessWidget {
  const EBillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 26, horizontal: 40),
      child: Text('E-Billing_Page'),
    );
  }
}
