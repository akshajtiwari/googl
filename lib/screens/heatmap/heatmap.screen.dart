import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/sidebar.dart';

// ─── Mock data — replace with real API calls ───────────────────────────
final _mockNeeds = [
  _Need(
      lat: 28.620,
      lng: 77.210,
      type: 'food',
      intensity: 0.9,
      ward: 'Ward-3',
      volunteers: 1),
  _Need(
      lat: 28.635,
      lng: 77.225,
      type: 'medical',
      intensity: 0.7,
      ward: 'Ward-5',
      volunteers: 3),
  _Need(
      lat: 28.610,
      lng: 77.200,
      type: 'shelter',
      intensity: 0.8,
      ward: 'Ward-2',
      volunteers: 0),
  _Need(
      lat: 28.645,
      lng: 77.195,
      type: 'education',
      intensity: 0.5,
      ward: 'Ward-7',
      volunteers: 2),
  _Need(
      lat: 28.625,
      lng: 77.240,
      type: 'food',
      intensity: 0.6,
      ward: 'Ward-8',
      volunteers: 1),
  _Need(
      lat: 28.615,
      lng: 77.215,
      type: 'medical',
      intensity: 0.95,
      ward: 'Ward-4',
      volunteers: 0),
  _Need(
      lat: 28.650,
      lng: 77.230,
      type: 'shelter',
      intensity: 0.4,
      ward: 'Ward-9',
      volunteers: 4),
  _Need(
      lat: 28.605,
      lng: 77.235,
      type: 'food',
      intensity: 0.85,
      ward: 'Ward-1',
      volunteers: 1),
];

final _mockVolunteers = [
  _Volunteer(lat: 28.622, lng: 77.218, name: 'Riya Sharma'),
  _Volunteer(lat: 28.638, lng: 77.228, name: 'Arjun Mehta'),
  _Volunteer(lat: 28.612, lng: 77.205, name: 'Priya Singh'),
  _Volunteer(lat: 28.648, lng: 77.200, name: 'Kunal Verma'),
];

const _typeColors = {
  'food': Color(0xFFEF4444),
  'medical': Color(0xFF3B82F6),
  'shelter': Color(0xFFF59E0B),
  'education': Color(0xFF10B981),
};
// ────────────────────────────────────────────────────────────────────────

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});
  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final Set<String> _activeTypes = {'food', 'medical', 'shelter', 'education'};
  bool _showVolunteers = true;
  String _timePeriod = 'week'; // 'week' | 'month'
  _Need? _selectedZone;

  List<_Need> get _filtered => _mockNeeds
      .where((n) => _activeTypes.contains(n.type))
      .where((n) => _timePeriod == 'month' ? true : n.intensity > 0.3)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: '/heatmap'),
          Expanded(
            child: Stack(
              children: [
                // ── MAP ──────────────────────────────────────────────
                FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        const LatLng(20.5937, 78.9629), // Center of India
                    initialZoom: 5.0,
                    minZoom: 4.0,
                    maxZoom: 18.0,
                    onTap: (_, __) => setState(() => _selectedZone = null),
                  ),
                  children: [
                    // Map tiles
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),

                    // Underserved zone circles
                    CircleLayer(
                      circles: _filtered
                          .where((n) => n.volunteers < 2 && n.intensity > 0.6)
                          .map((n) => CircleMarker(
                                point: LatLng(n.lat, n.lng),
                                radius: 40,
                                color: const Color(0xFFDC2626).withOpacity(0.2),
                                borderColor: const Color(0xFFDC2626),
                                borderStrokeWidth: 2,
                                useRadiusInMeter: true,
                              ))
                          .toList(),
                    ),

                    // Clickable zone markers
                    MarkerLayer(
                      markers: _filtered
                          .map((n) => Marker(
                                point: LatLng(n.lat, n.lng),
                                width: 36,
                                height: 36,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedZone = n),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          (_typeColors[n.type] ?? Colors.grey)
                                              .withOpacity(0.85),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 4,
                                            color: Colors.black26)
                                      ],
                                    ),
                                    child: Icon(_typeIcon(n.type),
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    // Volunteer markers
                    if (_showVolunteers)
                      MarkerLayer(
                        markers: _mockVolunteers
                            .map((v) => Marker(
                                  point: LatLng(v.lat, v.lng),
                                  width: 32,
                                  height: 32,
                                  child: Tooltip(
                                    message: v.name,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.person_pin,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),

                // ── CONTROLS PANEL (top-left) ─────────────────────────
                Positioned(
                  top: 16,
                  left: 16,
                  child: _ControlPanel(
                    activeTypes: _activeTypes,
                    showVolunteers: _showVolunteers,
                    timePeriod: _timePeriod,
                    onToggleType: (t) => setState(() => _activeTypes.contains(t)
                        ? _activeTypes.remove(t)
                        : _activeTypes.add(t)),
                    onToggleVolunteers: (v) =>
                        setState(() => _showVolunteers = v),
                    onTimePeriod: (t) => setState(() => _timePeriod = t),
                  ),
                ),

                // ── LEGEND ───────────────────────────────────────────
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: _Legend(),
                ),

                // ── ZONE DETAIL PANEL (top-right) ─────────────────────
                if (_selectedZone != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _ZoneDetailPanel(
                      need: _selectedZone!,
                      onClose: () => setState(() => _selectedZone = null),
                    ),
                  ),

                // ── HEADER ───────────────────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        const Text('Heatmap & Geospatial View',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A3A5C))),
                        const Spacer(),
                        Chip(
                          avatar: const Icon(Icons.circle,
                              color: Color(0xFFEF4444), size: 12),
                          label: Text(
                              '${_filtered.where((n) => n.volunteers < 2).length} Underserved Zones'),
                          backgroundColor: const Color(0xFFFEE2E2),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          avatar: const Icon(Icons.circle,
                              color: Color(0xFF22C55E), size: 12),
                          label: Text(
                              '${_mockVolunteers.length} Volunteers Active'),
                          backgroundColor: const Color(0xFFDCFCE7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── CONTROL PANEL WIDGET ────────────────────────────────────────────────
class _ControlPanel extends StatelessWidget {
  final Set<String> activeTypes;
  final bool showVolunteers;
  final String timePeriod;
  final void Function(String) onToggleType;
  final void Function(bool) onToggleVolunteers;
  final void Function(String) onTimePeriod;

  const _ControlPanel({
    required this.activeTypes,
    required this.showVolunteers,
    required this.timePeriod,
    required this.onToggleType,
    required this.onToggleVolunteers,
    required this.onTimePeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(top: 56),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📍 Need Types',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ..._typeColors.entries.map((e) => _TypeToggle(
                type: e.key,
                color: e.value,
                active: activeTypes.contains(e.key),
                onToggle: () => onToggleType(e.key),
              )),
          const Divider(height: 20),
          _SwitchRow(
            label: '🟢 Volunteers',
            value: showVolunteers,
            onChanged: onToggleVolunteers,
          ),
          const Divider(height: 20),
          const Text('🕐 Time Filter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          _RadioRow(
              label: 'Past 7 days',
              value: 'week',
              group: timePeriod,
              onTap: () => onTimePeriod('week')),
          _RadioRow(
              label: 'Past 30 days',
              value: 'month',
              group: timePeriod,
              onTap: () => onTimePeriod('month')),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String type;
  final Color color;
  final bool active;
  final VoidCallback onToggle;
  const _TypeToggle(
      {required this.type,
      required this.color,
      required this.active,
      required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: active ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(type[0].toUpperCase() + type.substring(1),
              style: TextStyle(
                  fontSize: 13, color: active ? Colors.black87 : Colors.grey)),
        ]),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _SwitchRow(
      {required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1A3A5C)),
        ],
      );
}

class _RadioRow extends StatelessWidget {
  final String label, value, group;
  final VoidCallback onTap;
  const _RadioRow(
      {required this.label,
      required this.value,
      required this.group,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Row(children: [
          Radio<String>(
              value: value,
              groupValue: group,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFF1A3A5C)),
          Text(label, style: const TextStyle(fontSize: 13)),
        ]),
      );
}

// ── ZONE DETAIL PANEL ────────────────────────────────────────────────────
class _ZoneDetailPanel extends StatelessWidget {
  final _Need need;
  final VoidCallback onClose;
  const _ZoneDetailPanel({required this.need, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isUnderserved = need.volunteers < 2;
    return Container(
      width: 260,
      margin: const EdgeInsets.only(top: 56),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📍 ${need.ward}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, size: 18, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
              'Type',
              need.type[0].toUpperCase() + need.type.substring(1),
              _typeColors[need.type] ?? Colors.grey),
          _DetailRow(
              'Intensity', '${(need.intensity * 100).round()}%', Colors.orange),
          _DetailRow('Volunteers', '${need.volunteers} assigned',
              need.volunteers < 2 ? Colors.red : Colors.green),
          if (isUnderserved) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(children: [
                Icon(Icons.warning_amber, color: Colors.red, size: 16),
                SizedBox(width: 6),
                Expanded(
                    child: Text('Underserved — needs more volunteers',
                        style: TextStyle(color: Colors.red, fontSize: 12))),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Assign Volunteer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3A5C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _DetailRow(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        ]),
      );
}

// ── LEGEND ──────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Legend',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            _LegendItem(
                color: const Color(0xFFEF4444), label: 'High need density'),
            _LegendItem(
                color: const Color(0xFFF59E0B), label: 'Medium density'),
            _LegendItem(color: Colors.blue, label: 'Low density'),
            _LegendItem(
                color: const Color(0xFF22C55E),
                label: 'Volunteer location',
                isCircle: true),
            _LegendItem(
                color: const Color(0xFFDC2626),
                label: 'Underserved zone',
                isDash: true),
          ],
        ),
      );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isCircle;
  final bool isDash;
  const _LegendItem(
      {required this.color,
      required this.label,
      this.isCircle = false,
      this.isDash = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isDash ? color.withOpacity(0.2) : color,
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              border: isDash ? Border.all(color: color, width: 1.5) : null,
              borderRadius: isDash
                  ? BorderRadius.zero
                  : (isCircle ? null : BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ]),
      );
}

// ── DATA MODELS ──────────────────────────────────────────────────────────
class _Need {
  final double lat, lng, intensity;
  final String type, ward;
  final int volunteers;
  const _Need(
      {required this.lat,
      required this.lng,
      required this.type,
      required this.intensity,
      required this.ward,
      required this.volunteers});
}

class _Volunteer {
  final double lat, lng;
  final String name;
  const _Volunteer({required this.lat, required this.lng, required this.name});
}

IconData _typeIcon(String type) => switch (type) {
      'food' => Icons.restaurant,
      'medical' => Icons.local_hospital,
      'shelter' => Icons.home,
      'education' => Icons.school,
      _ => Icons.help_outline,
    };
