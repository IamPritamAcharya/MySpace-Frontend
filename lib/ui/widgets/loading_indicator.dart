import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double padding;

  const LoadingIndicator({super.key, this.padding = 48});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
