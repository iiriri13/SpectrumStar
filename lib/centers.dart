import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CentersPage extends StatelessWidget {
  const CentersPage({super.key});

  // Function to open Google Maps with a search for nearby autism centers
  Future<void> _openNearbyAutismCenters() async {
    const String url = 'https://www.google.com/maps/search/Autism+Centers+near+me/';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centers'),
        backgroundColor: const Color(0xFFB2A4D4),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _openNearbyAutismCenters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB2A4D4),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          ),
          child: const Text('Show Nearby Autism Centers'),
        ),
      ),
    );
  }
}
