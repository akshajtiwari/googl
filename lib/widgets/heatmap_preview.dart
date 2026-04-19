import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HeatmapPreview extends StatelessWidget {
  const HeatmapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(20.5937, 78.9629),
        initialZoom: 5.0,
        minZoom: 4,
        maxZoom: 10,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),

        /// 👉 keep it LIGHT (preview only)
        CircleLayer(
          circles: [
            CircleMarker(
              point: LatLng(28.62, 77.21),
              radius: 30,
              color: Colors.red.withOpacity(0.2),
              borderColor: Colors.red,
              borderStrokeWidth: 2,
            )
          ],
        ),
      ],
    );
  }
}