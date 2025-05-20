import 'package:flutter/foundation.dart';

class ProgressResponse {
  final int progress;

  ProgressResponse({required this.progress});

  factory ProgressResponse.fromJson(Map<String, dynamic> json) {
    return ProgressResponse(
      progress: json['progress'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progress': progress,
    };
  }
}