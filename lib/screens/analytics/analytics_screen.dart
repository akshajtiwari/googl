import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/sidebar.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeRange = 'This Month'; // 'This Week' | 'This Month' | 'All Time'
  int _touchedPieIndex = -1;

  // ── Mock data keyed by time range ─────────────────────────────────────

  final _needsByType = {
    'This Week':  [18.0, 12.0, 8.0,  6.0],
    'This Month': [42.0, 31.0, 19.0, 14.0],
    'All Time':   [180.0,120.0,75.0, 55.0],
  };

  final _taskResolution = {
    'This Week':  [3.0,5.0,4.0,6.0,7.0,5.0,8.0],
    'This Month': [12.0,18.0,14.0,22.0,19.0,25.0,21.0,28.0,24.0,30.0,27.0,35.0],
    'All Time':   [40.0,55.0,48.0,62.0,70.0,65.0,80.0,75.0,90.0,85.0,95.0,110.0],
  };

  final _volunteerActivity = {
    'This Week':  [5.0,8.0,6.0,9.0,7.0,11.0,10.0],
    'This Month': [20.0,28.0,24.0,32.0,27.0,35.0,30.0,38.0,33.0,42.0,38.0,45.0],
    'All Time':   [60.0,80.0,72.0,90.0,85.0,100.0,95.0,110.0,105.0,120.0,115.0,130.0],
  };

  final _zoneData = [
    _ZoneRow('Ward 3',  28, 14, 3, 0.82),
    _ZoneRow('Zone 4B', 19, 11, 1, 0.61),
    _ZoneRow('Block C', 14,  9, 4, 0.78),
    _ZoneRow('Ward 7',  22,  8, 0, 0.44),
    _ZoneRow('Zone 2',  11, 10, 5, 0.91),
  ];

  List<double> get _currentNeeds     => _needsByType[_timeRange]!;
  List<double> get _currentTaskRes   => _taskResolution[_timeRange]!;
  List<double> get _currentVolunteer => _volunteerActivity[_timeRange]!;

  // Summary totals
  int get _totalNeeds      => _currentNeeds.fold(0, (s, v) => s + v.round());
  int get _totalTasksDone  => _currentTaskRes.fold(0, (s, v) => s + v.round());
  int get _activeVols      => _timeRange == 'This Week' ? 31 : _timeRange == 'This Month' ? 87 : 142;
  int get _underserved     => _timeRange == 'This Week' ? 2  : _timeRange == 'This Month' ? 5  : 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentRoute: AppRoutes.analytics),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Analytics',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor)),
                          const SizedBox(height: 4),
                          Text('Performance overview · $_timeRange',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      const Spacer(),
                      // Time range toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6)
                          ],
                        ),
                        child: Row(
                          children: ['This Week', 'This Month', 'All Time']
                              .map((t) => GestureDetector(
                                    onTap: () =>
                                        setState(() => _timeRange = t),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _timeRange == t
                                            ? AppTheme.primaryColor
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(7),
                                      ),
                                      child: Text(t,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _timeRange == t
                                                  ? Colors.white
                                                  : Colors.grey.shade600)),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── KPI Summary Cards ─────────────────────────────
                  Row(children: [
                    _KpiCard(
                        label: 'Total Needs',
                        value: '$_totalNeeds',
                        icon: Icons.report_problem_outlined,
                        color: const Color(0xFFEF4444),
                        sub: '+12% vs last period'),
                    const SizedBox(width: 16),
                    _KpiCard(
                        label: 'Tasks Resolved',
                        value: '$_totalTasksDone',
                        icon: Icons.task_alt,
                        color: const Color(0xFF10B981),
                        sub: '+8% vs last period'),
                    const SizedBox(width: 16),
                    _KpiCard(
                        label: 'Active Volunteers',
                        value: '$_activeVols',
                        icon: Icons.people_outline,
                        color: const Color(0xFF3B82F6),
                        sub: '$_activeVols of 142 engaged'),
                    const SizedBox(width: 16),
                    _KpiCard(
                        label: 'Underserved Zones',
                        value: '$_underserved',
                        icon: Icons.location_off_outlined,
                        color: const Color(0xFFF59E0B),
                        sub: 'Needs attention'),
                  ]),

                  const SizedBox(height: 28),

                  // ── Row 2: Line chart + Pie chart ─────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task resolution trend
                      Expanded(
                        flex: 3,
                        child: _ChartCard(
                          title: 'Task Resolution Trend',
                          subtitle: 'Tasks completed over time',
                          child: SizedBox(
                            height: 220,
                            child: LineChart(_buildLineChart()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Needs by type pie
                      Expanded(
                        flex: 2,
                        child: _ChartCard(
                          title: 'Needs by Category',
                          subtitle: 'Distribution across need types',
                          child: SizedBox(
                            height: 220,
                            child: Row(children: [
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback: (event, response) {
                                        setState(() {
                                          if (!event.isInterestedForInteractions ||
                                              response == null ||
                                              response.touchedSection == null) {
                                            _touchedPieIndex = -1;
                                            return;
                                          }
                                          _touchedPieIndex = response
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                    ),
                                    sections: _buildPieSections(),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Legend
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _PieLegend('Food',
                                      const Color(0xFFEF4444),
                                      _currentNeeds[0].round()),
                                  const SizedBox(height: 8),
                                  _PieLegend('Medical',
                                      const Color(0xFF3B82F6),
                                      _currentNeeds[1].round()),
                                  const SizedBox(height: 8),
                                  _PieLegend('Shelter',
                                      const Color(0xFFF59E0B),
                                      _currentNeeds[2].round()),
                                  const SizedBox(height: 8),
                                  _PieLegend('Education',
                                      const Color(0xFF10B981),
                                      _currentNeeds[3].round()),
                                ],
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Row 3: Bar chart + Volunteer activity ─────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Volunteer activity bar
                      Expanded(
                        flex: 2,
                        child: _ChartCard(
                          title: 'Volunteer Activity',
                          subtitle: 'Active volunteers over time',
                          child: SizedBox(
                            height: 200,
                            child: BarChart(_buildBarChart()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Zone performance table
                      Expanded(
                        flex: 3,
                        child: _ChartCard(
                          title: 'Zone Performance',
                          subtitle:
                              'Needs, tasks, volunteers and coverage per zone',
                          child: _buildZoneTable(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Row 4: Task status breakdown ──────────────────
                  _ChartCard(
                    title: 'Task Status Breakdown',
                    subtitle: 'Current pipeline across all tasks',
                    child: _buildTaskStatusRow(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chart builders ────────────────────────────────────────────────────

  LineChartData _buildLineChart() {
    final labels = _xAxisLabels();
    final maxY = _niceMaxY(_currentTaskRes);
    final yInterval = _niceInterval(maxY);

    final spots = _currentTaskRes
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.shade100, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: yInterval,
            getTitlesWidget: (v, _) => Text('${v.round()}',
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: labels.length > 7 ? 2 : 1,
            getTitlesWidget: (v, _) {
              if (v % 1 != 0) return const SizedBox();
              final i = v.round();
              if (i < 0 || i >= labels.length) {
                return const SizedBox();
              }
              if (!_showXAxisTick(i, labels.length)) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[i],
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey)),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primaryColor.withOpacity(0.08),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots
              .map((s) => LineTooltipItem(
                    '${s.y.round()} tasks',
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ))
              .toList(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
    ];
    final total = _currentNeeds.fold(0.0, (s, v) => s + v);

    return _currentNeeds.asMap().entries.map((e) {
      final isTouched = e.key == _touchedPieIndex;
      final pct = (e.value / total * 100).round();
      return PieChartSectionData(
        value: e.value,
        color: colors[e.key],
        radius: isTouched ? 60 : 50,
        title: isTouched ? '$pct%' : '',
        titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold),
        badgeWidget: isTouched
            ? null
            : null,
      );
    }).toList();
  }

  BarChartData _buildBarChart() {
    final labels = _xAxisLabels();
    final maxY = _niceMaxY(_currentVolunteer);
    final yInterval = _niceInterval(maxY);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: yInterval,
            getTitlesWidget: (v, _) => Text('${v.round()}',
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: labels.length > 7 ? 2 : 1,
            getTitlesWidget: (v, _) {
              if (v % 1 != 0) return const SizedBox();
              final i = v.round();
              if (i < 0 || i >= labels.length) {
                return const SizedBox();
              }
              if (!_showXAxisTick(i, labels.length)) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[i],
                    style: const TextStyle(
                        fontSize: 9, color: Colors.grey)),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: _currentVolunteer
          .asMap()
          .entries
          .map((e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value,
                    color: const Color(0xFF3B82F6),
                    width: _barWidthFor(_currentVolunteer.length),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                  ),
                ],
              ))
          .toList(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, _, rod, __) => BarTooltipItem(
            '${rod.toY.round()} volunteers',
            const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  List<String> _xAxisLabels() {
    if (_timeRange == 'This Week') {
      return const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    }
    if (_timeRange == 'This Month') {
      return const [
        'W1',
        'W2',
        'W3',
        'W4',
        'W5',
        'W6',
        'W7',
        'W8',
        'W9',
        'W10',
        'W11',
        'W12',
      ];
    }
    return const ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
  }

  bool _showXAxisTick(int index, int length) {
    if (length <= 7) return true;
    return index % 2 == 0 || index == length - 1;
  }

  double _niceMaxY(List<double> values) {
    final peak = values.reduce((a, b) => a > b ? a : b);
    if (peak <= 10) return 10;
    final padded = peak * 1.15;
    final step = padded <= 50 ? 5.0 : 10.0;
    return (padded / step).ceil() * step;
  }

  double _niceInterval(double maxY) {
    if (maxY <= 10) return 2;
    if (maxY <= 40) return 5;
    if (maxY <= 100) return 10;
    return 20;
  }

  double _barWidthFor(int points) {
    if (points <= 7) return 14;
    if (points <= 12) return 10;
    return 8;
  }

  Widget _buildZoneTable() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: const [
            Expanded(flex: 2, child: _TH('Zone')),
            Expanded(flex: 1, child: _TH('Needs')),
            Expanded(flex: 1, child: _TH('Tasks')),
            Expanded(flex: 1, child: _TH('Vols')),
            Expanded(flex: 2, child: _TH('Coverage')),
          ]),
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),
        ..._zoneData.map((z) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                // Zone name
                Expanded(
                  flex: 2,
                  child: Text(z.zone,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor)),
                ),
                // Needs
                Expanded(
                  flex: 1,
                  child: Text('${z.needs}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFEF4444))),
                ),
                // Tasks
                Expanded(
                  flex: 1,
                  child: Text('${z.tasks}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF10B981))),
                ),
                // Volunteers
                Expanded(
                  flex: 1,
                  child: Text('${z.volunteers}',
                      style: TextStyle(
                          fontSize: 13,
                          color: z.volunteers < 2
                              ? Colors.red
                              : const Color(0xFF3B82F6))),
                ),
                // Coverage bar
                Expanded(
                  flex: 2,
                  child: Row(children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: z.coverage,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation(
                            z.coverage >= 0.75
                                ? const Color(0xFF10B981)
                                : z.coverage >= 0.5
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(z.coverage * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ]),
                ),
              ]),
            )),
      ],
    );
  }

  Widget _buildTaskStatusRow() {
    final statuses = [
      ('Open',        24, const Color(0xFF6B7280)),
      ('Assigned',    18, const Color(0xFF3B82F6)),
      ('In Progress', 12, const Color(0xFFF59E0B)),
      ('Completed',   31, const Color(0xFF10B981)),
      ('Verified',    15, const Color(0xFF1A3A5C)),
    ];
    final total = statuses.fold(0, (s, e) => s + e.$2);

    return Column(
      children: [
        // Bar
        Row(
          children: statuses.map((s) {
            final flex = (s.$2 / total * 100).round();
            return Expanded(
              flex: flex == 0 ? 1 : flex,
              child: Tooltip(
                message: '${s.$1}: ${s.$2} tasks',
                child: Container(
                  height: 28,
                  color: s.$3,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 24,
          runSpacing: 10,
          children: statuses.map((s) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: s.$3, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('${s.$1}  ',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  Text('${s.$2}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor)),
                ],
              )).toList(),
        ),
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.sub,
  });
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('↑',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 14),
              Text(value,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor)),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      );
}

class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor)),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 20),
            child,
          ],
        ),
      );
}

class _PieLegend extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  const _PieLegend(this.label, this.color, this.count);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label ',
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey)),
          Text('$count',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
        ],
      );
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.4));
}

class _ZoneRow {
  final String zone;
  final int needs, tasks, volunteers;
  final double coverage;
  const _ZoneRow(
      this.zone, this.needs, this.tasks, this.volunteers, this.coverage);
}
