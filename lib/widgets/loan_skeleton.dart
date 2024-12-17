import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoanSkeleton extends StatelessWidget {
  const LoanSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(height: 24, width: 400),
                const SizedBox(height: 8),
                _buildShimmerBox(height: 16, width: 250),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildShimmerBox(height: 16, width: 80),
                    const SizedBox(width: 2),
                    _buildShimmerBox(height: 16, width: 100),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
