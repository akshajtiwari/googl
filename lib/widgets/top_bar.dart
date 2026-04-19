import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/ui_models.dart';
import '../../../services/search_service.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final LayerLink _layerLink = LayerLink();
  
  final OverlayPortalController _notifPortalController = OverlayPortalController();
  final OverlayPortalController _searchPortalController = OverlayPortalController();

  String _searchQuery = '';
  List<SearchResult> _filteredResults = [];

  final List<Notif> _notifs = [
    Notif("New Task Assigned", "Assigned to Zone 4", "2m", Icons.task_alt_rounded, Colors.blue),
    Notif("Urgent Need", "Medical help needed", "10m", Icons.warning_amber_rounded, Colors.red),
    Notif("Volunteer Joined", "New volunteer registered", "1h", Icons.people_alt_rounded, Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      // Trigger a rebuild to animate the search bar's shape/shadow on focus
      setState(() {}); 
      
      if (!_searchFocus.hasFocus && _searchPortalController.isShowing) {
        _searchPortalController.hide();
      } else if (_searchFocus.hasFocus && _searchQuery.isNotEmpty) {
        _searchPortalController.show();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() {
      _searchQuery = v;
      _filteredResults = SearchService.search(v);
    });
    
    if (v.isNotEmpty && !_searchPortalController.isShowing) {
      _searchPortalController.show();
    } else if (v.isEmpty && _searchPortalController.isShowing) {
      _searchPortalController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearchFocused = _searchFocus.hasFocus;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.slash): () => _searchFocus.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_searchFocus.hasFocus) _searchFocus.unfocus();
          if (_notifPortalController.isShowing) _notifPortalController.hide();
        }
      },
      child: Focus(
        autofocus: true,
        child: Container(
          height: 64,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Google-style Product Header
              Text(
                'NGO Admin',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF202124), // Google standard dark grey
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),

              /// 🔍 SEARCH (Google M3 Pill Style)
              CompositedTransformTarget(
                link: _layerLink,
                child: OverlayPortal(
                  controller: _searchPortalController,
                  overlayChildBuilder: (context) {
                    return Positioned(
                      width: isSearchFocused ? 320 : 260,
                      child: CompositedTransformFollower(
                        link: _layerLink,
                        showWhenUnlinked: false,
                        offset: const Offset(0, 56),
                        child: SearchDropdown(
                          results: _filteredResults,
                          onSelect: (r) {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                            _searchFocus.unfocus();
                            Navigator.pushNamed(context, r.route);
                          },
                        ),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: isSearchFocused ? 320 : 260, // Expands slightly on focus
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSearchFocused ? Colors.white : const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(100), // Pill shape
                      boxShadow: isSearchFocused
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF202124)),
                      decoration: InputDecoration(
                        hintText: 'Search... (Press /)',
                        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.search_rounded, size: 20, color: Color(0xFF5F6368)),
                        ),
                        // Only show clear button if typing
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF5F6368)),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              /// 🔔 NOTIFICATIONS (Circular Google Icon)
              Tooltip(
                message: "Notifications",
                child: OverlayPortal(
                  controller: _notifPortalController,
                  overlayChildBuilder: (context) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => _notifPortalController.hide(),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        Positioned(
                          top: 64,
                          right: 80,
                          child: NotifPanel(
                            notifs: _notifs,
                            onMarkAllRead: () {
                              setState(() { for (var n in _notifs) n.read = true; });
                            },
                            onMarkRead: (n) => setState(() => n.read = true),
                            onClose: () => _notifPortalController.hide(),
                          ),
                        ),
                      ],
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: IconButton(
                          onPressed: () => _notifPortalController.toggle(),
                          icon: const Icon(Icons.notifications_none_rounded),
                          color: const Color(0xFF5F6368),
                          iconSize: 22,
                          hoverColor: const Color(0xFFF1F3F4), // Google faint hover
                          splashRadius: 24,
                        ),
                      ),
                      
                      // Notification Badge
                      if (_notifs.any((n) => !n.read))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD93025), // Google Red
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// 👤 USER MENU (Google Circular Avatar)
              Tooltip(
                message: "Google Account\nAdmin User",
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "profile", child: Text("Profile")),
                    const PopupMenuItem(value: "password", child: Text("Change Password")),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: "logout", child: Text("Logout")),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF1A73E8), // Google Blue
                      child: Text(
                        'A',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Search Dropdown (Rounded to match M3 style)
// ─────────────────────────────────────────────────────────────
class SearchDropdown extends StatelessWidget {
  final List<SearchResult> results;
  final void Function(SearchResult) onSelect;
  const SearchDropdown({super.key, required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Softer M3 corners
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (_, i) {
          final r = results[i];
          return InkWell(
            onTap: () => onSelect(r),
            hoverColor: const Color(0xFFF1F3F4), // M3 hover state
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(r.icon, size: 20, color: const Color(0xFF5F6368)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF202124))),
                        const SizedBox(height: 2),
                        Text(r.subtitle,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF5F6368))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Notification Panel
// ─────────────────────────────────────────────────────────────
class NotifPanel extends StatelessWidget {
  final List<Notif> notifs;
  final VoidCallback onMarkAllRead;
  final void Function(Notif) onMarkRead;
  final VoidCallback onClose;

  const NotifPanel(
      {super.key, 
      required this.notifs,
      required this.onMarkAllRead,
      required this.onMarkRead,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                const Text('Notifications',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF202124))),
                const Spacer(),
                TextButton(
                  onPressed: onMarkAllRead,
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1A73E8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32)),
                  child: const Text('Mark all as read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          if (notifs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text("You're all caught up", style: TextStyle(fontSize: 13, color: Color(0xFF5F6368))),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: notifs.length,
                itemBuilder: (_, i) {
                  final n = notifs[i];
                  return Material(
                    color: n.read ? Colors.transparent : const Color(0xFFE8F0FE).withOpacity(0.5),
                    child: InkWell(
                      onTap: () {
                        onMarkRead(n);
                        onClose();
                      },
                      hoverColor: const Color(0xFFF1F3F4),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: n.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(n.icon, size: 18, color: n.color),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: n.read ? FontWeight.w400 : FontWeight.w600,
                                          color: const Color(0xFF202124))),
                                  const SizedBox(height: 2),
                                  Text(n.body, style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368))),
                                  const SizedBox(height: 4),
                                  Text(n.time, style: const TextStyle(fontSize: 11, color: Color(0xFF5F6368))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}