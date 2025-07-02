import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';

class AuthForm extends StatelessWidget {
  final List<Widget> fields;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final Widget? footer;

  const AuthForm({
    super.key,
    required this.fields,
    required this.submitLabel,
    this.onSubmit,
    this.isLoading = false,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...fields,
          const SizedBox(height: 24),
          PrimaryButton(label: submitLabel, onPressed: onSubmit, isLoading: isLoading),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
        ],
      ),
    );
  }
}
