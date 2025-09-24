import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderStepperWidget extends StatelessWidget {
  final OrderStatus currentStatus;
  final bool isPreview;

  const OrderStepperWidget({
    super.key,
    required this.currentStatus,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_bag, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          currentStatus.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }
}
