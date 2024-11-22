import 'package:flutter/material.dart';
import '../models/property.dart';
import 'package:url_launcher/url_launcher.dart';

class LoanerCard extends StatefulWidget {
  final LoanerResponse loaner;
  const LoanerCard({
    super.key,
    required this.loaner,
  });

  @override
  State<LoanerCard> createState() => _LoanerCardState();
}

class _LoanerCardState extends State<LoanerCard> {
  int _currentImageIndex = 0;

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Handle error - show snackbar or dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: Color.fromARGB(255, 153, 152, 152),
          width: 2.0,
        ),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Image.network(
                  widget.loaner.loaner.logo ?? "",
                  width: 24,
                  height: 24,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  widget.loaner.loaner.name,
                  style: const TextStyle(
                    color: Color(0xFF252525),
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.loaner.description,
              style: const TextStyle(
                color: Color(0xFF252525),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _launchPhoneDialer(widget.loaner.loaner.phone ?? ""),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Color(0xFF252525)),
                  const SizedBox(width: 8),
                  Text(
                    widget.loaner.loaner.phone ?? "",
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
