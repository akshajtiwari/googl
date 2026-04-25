import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/volunteer_entry.dart';
import '../../widgets/heatmap_preview.dart';

// ─────────────────────────────────────────────────────────────
//  Table Header & Action Buttons
// ─────────────────────────────────────────────────────────────
class VolunteerTableHeader extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onAssign;

  const VolunteerTableHeader({super.key, required this.onExport, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Active Roster",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF202124))),
        const Spacer(),
        
        // M3 Outlined Button
        OutlinedButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text('Export CSV'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5F6368),
            side: const BorderSide(color: Color(0xFFDADCE0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        
        // M3 Elevated Button
        ElevatedButton.icon(
          onPressed: onAssign,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Assign Task'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8), // Google Blue
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ).copyWith(
            elevation: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered) ? 4.0 : 0.0),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Column Headers
// ─────────────────────────────────────────────────────────────
class VolunteerColumnHeaders extends StatelessWidget {
  const VolunteerColumnHeaders({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5F6368));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Checkbox(value: false, onChanged: (_) {}, side: const BorderSide(color: Color(0xFFDADCE0))),
          ),
          const Expanded(flex: 3, child: Text('Volunteer', style: style)),
          const Expanded(flex: 2, child: Text('Check-in', style: style)),
          const Expanded(flex: 2, child: Text('Check-out', style: style)),
          const Expanded(flex: 2, child: Text('Hours', style: style)),
          const Expanded(flex: 3, child: Text('Notes', style: style)),
          const Expanded(flex: 3, child: Text('Status', style: style)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Volunteer Row
// ─────────────────────────────────────────────────────────────
class VolunteerRow extends StatefulWidget {
  final VolunteerEntry entry;
  final bool isLast;
  final VoidCallback onToggleExpand;
  final void Function(bool?) onToggleCheck;

  const VolunteerRow({
    super.key,
    required this.entry,
    required this.isLast,
    required this.onToggleExpand,
    required this.onToggleCheck,
  });

  @override
  State<VolunteerRow> createState() => _VolunteerRowState();
}

class _VolunteerRowState extends State<VolunteerRow> with SingleTickerProviderStateMixin {
  late final AnimationController _expandCtrl;
  late final Animation<double> _expandAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOut);
    if (widget.entry.isExpanded) _expandCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(VolunteerRow old) {
    super.didUpdateWidget(old);
    if (widget.entry.isExpanded != old.entry.isExpanded) {
      widget.entry.isExpanded ? _expandCtrl.forward() : _expandCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onToggleExpand,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              color: _hovered ? const Color(0xFFF8F9FA) : Colors.transparent, // Soft Google hover grey
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Checkbox(
                      value: e.isChecked,
                      onChanged: widget.onToggleCheck,
                      activeColor: const Color(0xFF1A73E8),
                      side: const BorderSide(color: Color(0xFFDADCE0)),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: e.avatarColor.withOpacity(0.1),
                        child: Text(e.avatarInitials, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: e.avatarColor)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF202124)), overflow: TextOverflow.ellipsis),
                            Text('${e.role} • ${e.zone}', style: const TextStyle(fontSize: 11, color: Color(0xFF5F6368)), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  Expanded(flex: 2, child: Text(e.checkin, style: const TextStyle(fontSize: 13, color: Color(0xFF202124)))),
                  Expanded(
                    flex: 2,
                    child: Text(e.checkout, style: TextStyle(fontSize: 13, color: e.checkout == '-:-' ? const Color(0xFFDADCE0) : const Color(0xFF202124))),
                  ),
                  Expanded(flex: 2, child: Text(e.hours, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF202124)))),
                  Expanded(
                    flex: 3,
                    child: Text(e.notes, style: TextStyle(fontSize: 12, color: e.notes == 'None' ? const Color(0xFFDADCE0) : const Color(0xFF5F6368)), overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(children: [
                      _StatusBadge(status: e.status),
                      const Spacer(),
                      _IconBtn(icon: Icons.edit_outlined, onTap: () => _showEditDialog(context, e)),
                      const SizedBox(width: 4),
                      _IconBtn(icon: Icons.chat_bubble_outline_rounded, onTap: () {}),
                      if (e.taskLog.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: e.isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF5F6368)),
                        ),
                      ] else
                        const SizedBox(width: 28), // Placeholder alignment
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnim,
          child: e.taskLog.isNotEmpty ? _ExpandedTaskLog(entry: e) : const SizedBox.shrink(),
        ),
        if (!widget.isLast) const Divider(height: 1, color: Color(0xFFDADCE0)),
      ],
    );
  }

  void _showEditDialog(BuildContext context, VolunteerEntry e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Edit ${e.name}', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 18, color: const Color(0xFF202124))),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(label: 'Check-in time', initial: e.checkin),
              const SizedBox(height: 16),
              _DialogField(label: 'Check-out time', initial: e.checkout),
              const SizedBox(height: 16),
              _DialogField(label: 'Notes', initial: e.notes),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white, elevation: 0),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Expanded Task Log
// ─────────────────────────────────────────────────────────────
class _ExpandedTaskLog extends StatelessWidget {
  final VolunteerEntry entry;
  const _ExpandedTaskLog({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 48, bottom: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Google Cloud inset grey
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDADCE0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      SizedBox(width: 24),
                      Expanded(flex: 2, child: Text('Action', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)))),
                      Expanded(flex: 2, child: Text('Time', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)))),
                      Expanded(flex: 3, child: Text('Location', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)))),
                      Expanded(flex: 2, child: Text('Duration', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...entry.taskLog.map((t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          SizedBox(width: 24, child: Text('${t.index}', style: const TextStyle(fontSize: 11, color: Color(0xFFDADCE0)))),
                          Expanded(
                            flex: 2,
                            child: Row(children: [
                              Icon(t.action.contains('in') ? Icons.login_rounded : Icons.logout_rounded,
                                  size: 14, color: t.action.contains('in') ? const Color(0xFF1E8E3E) : const Color(0xFFD93025)),
                              const SizedBox(width: 6),
                              Text(t.action, style: const TextStyle(fontSize: 12, color: Color(0xFF202124), fontWeight: FontWeight.w500)),
                            ]),
                          ),
                          Expanded(flex: 2, child: Text(t.time, style: const TextStyle(fontSize: 12, color: Color(0xFF202124)))),
                          Expanded(
                            flex: 3,
                            child: Row(children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF5F6368)),
                              const SizedBox(width: 4),
                              Expanded(child: Text(t.location, style: const TextStyle(fontSize: 12, color: Color(0xFF202124)), overflow: TextOverflow.ellipsis)),
                            ]),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(t.duration ?? '—', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: t.duration != null ? const Color(0xFF202124) : const Color(0xFFDADCE0))),
                          ),
                        ]),
                      )),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
            child: SizedBox(width: 220, child: const HeatmapPreview()),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Google Semantic Status Badge
// ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final VolunteerStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, textCol) = switch (status) {
      VolunteerStatus.active    => ('Active', const Color(0xFFE6F4EA), const Color(0xFF137333)), // Google Green
      VolunteerStatus.onLeave   => ('On leave', const Color(0xFFFEF7E0), const Color(0xFFB06000)), // Google Yellow
      VolunteerStatus.completed => ('Completed', const Color(0xFFF1F3F4), const Color(0xFF5F6368)), // Google Grey
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == VolunteerStatus.active) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: textCol, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(fontSize: 11, color: textCol, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Small Helpers
// ─────────────────────────────────────────────────────────────
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (v) => setState(() => _hovered = v),
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: _hovered ? const Color(0xFFF1F3F4) : Colors.transparent, shape: BoxShape.circle),
        child: Icon(widget.icon, size: 16, color: const Color(0xFF5F6368)),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final String initial;
  const _DialogField({required this.label, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF5F6368))),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initial,
          style: const TextStyle(fontSize: 14, color: Color(0xFF202124)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDADCE0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFDADCE0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2)),
          ),
        ),
      ],
    );
  }
}