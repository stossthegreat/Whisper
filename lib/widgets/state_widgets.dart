import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  final String message;
  
  const LoadingStateWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const CircularProgressIndicator(color: Colors.tealAccent),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String error;
  
  const ErrorStateWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "❌ $error",
          style: const TextStyle(color: Colors.redAccent, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String text;
  
  const EmptyStateWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white54, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
