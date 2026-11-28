import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_session.dart';

class _AppRouteObserver extends NavigatorObserver {
  void _sync(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) {
      RealtimeNotifService.setActiveRoute(name);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sync(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _sync(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _sync(previousRoute);
  }
}

class RealtimeNotifService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static final NavigatorObserver routeObserver = _AppRouteObserver();

  static Timer? _pollTimer;
  static OverlayEntry? _activeEntry;
  static Timer? _hideTimer;

  // Disimpan di memori RAM tab masing-masing (tidak akan tertimpa antar-tab browser)
  static String _tabRole = '';
  static String? _lastCustomerNotifId;
  static final Map<String, String> _adminOrderStates = <String, String>{};
  static bool _adminInitialized = false;
  static bool _isPolling = false;

  static const List<String> _adminRoutes = <String>[
    '/admin-home',
    '/admin-notification',
    '/admin-profile',
    '/admin-chat',
    '/admin-chat-room',
    '/manage-orders',
    '/manage-services',
    '/customer-data',
    '/rekapitulasi-transaksi',
  ];

  static void setActiveRoute(String routeName) {
    if (_adminRoutes.contains(routeName)) {
      if (_tabRole != 'admin') {
        _tabRole = 'admin';
        _adminInitialized = false;
        _adminOrderStates.clear();
      }
    } else if (routeName == '/login' || routeName == '/signup') {
      _tabRole = '';
      _adminInitialized = false;
      _adminOrderStates.clear();
      _lastCustomerNotifId = null;
    } else {
      if (_tabRole != 'customer') {
        _tabRole = 'customer';
        _lastCustomerNotifId = null;
      }
    }
  }

  static bool get _isAdminTab {
    if (_tabRole == 'admin') return true;
    if (_tabRole == 'customer') return false;

    try {
      final url = Uri.base.toString().toLowerCase();
      for (final r in _adminRoutes) {
        if (url.contains(r)) {
          _tabRole = 'admin';
          return true;
        }
      }
    } catch (_) {}

    return (UserSession.role ?? '').trim().toLowerCase() == 'admin';
  }

  static void startListening() {
    stopListening();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _poll();
    });
  }

  static Future<void> _poll() async {
    if (_isPolling) return;
    _isPolling = true;

    try {
      final client = Supabase.instance.client;

      if (_isAdminTab) {
        final List<dynamic> rows = await client.from('orders').select();

        if (!_adminInitialized) {
          _adminOrderStates.clear();
          for (final dynamic item in rows) {
            final Map<String, dynamic> row =
            Map<String, dynamic>.from(item as Map);
            final String id = (row['id'] ?? '').toString();
            if (id.isNotEmpty) {
              final String pay =
              (row['payment_status'] ?? 'Belum Lunas').toString();
              final String st = (row['status'] ?? 'Waiting').toString();
              _adminOrderStates[id] = '$pay|$st';
            }
          }
          _adminInitialized = true;
          return;
        }

        for (final dynamic item in rows) {
          final Map<String, dynamic> row =
          Map<String, dynamic>.from(item as Map);
          final String id = (row['id'] ?? '').toString();
          if (id.isEmpty) continue;

          final String paymentStatus =
          (row['payment_status'] ?? 'Belum Lunas').toString();
          final String orderStatus = (row['status'] ?? 'Waiting').toString();
          final String snapshot = '$paymentStatus|$orderStatus';

          final String code = (row['order_code'] ?? '').toString();
          final String cust = (row['customer_name'] ?? 'Pelanggan').toString();
          final String service = (row['service_name'] ?? 'Laundry').toString();
          final String paymentMethod =
          (row['payment_method'] ?? '').toString();

          if (!_adminOrderStates.containsKey(id)) {
            _adminOrderStates[id] = snapshot;
            showBanner(
              badge: 'Pesanan Baru',
              badgeBg: const Color(0xFFDDD6FE),
              badgeTextColor: const Color(0xFF5B21B6),
              icon: Icons.shopping_bag_outlined,
              title: 'Pesanan baru masuk dari $cust ($code)',
              subtitle:
              'Layanan $service ($paymentStatus) membutuhkan tindak lanjut.',
              routeOnTap: '/manage-orders',
            );
            break;
          } else {
            final String prev = _adminOrderStates[id]!;
            if (prev != snapshot) {
              final List<String> parts = prev.split('|');
              final String prevPay = parts.isNotEmpty ? parts[0] : '';
              final String prevStatus = parts.length > 1 ? parts[1] : '';
              _adminOrderStates[id] = snapshot;

              if (prevPay.toLowerCase() != 'lunas' &&
                  paymentStatus.toLowerCase() == 'lunas') {
                showBanner(
                  badge: 'Pembayaran Diterima',
                  badgeBg: const Color(0xFFDCFCE7),
                  badgeTextColor: const Color(0xFF15803D),
                  icon: Icons.payments_outlined,
                  title: 'Pembayaran Lunas dari $cust ($code)',
                  subtitle:
                  'Layanan $service telah dibayar${paymentMethod.isNotEmpty ? ' via $paymentMethod' : ''}.',
                  routeOnTap: '/manage-orders',
                );
                break;
              } else if (prevStatus.toLowerCase() != 'dibatalkan' &&
                  orderStatus.toLowerCase() == 'dibatalkan') {
                showBanner(
                  badge: 'Pesanan Dibatalkan',
                  badgeBg: const Color(0xFFFEE2E2),
                  badgeTextColor: const Color(0xFFB91C1C),
                  icon: Icons.cancel_outlined,
                  title: 'Pesanan $code ($cust) dibatalkan',
                  subtitle: 'Pelanggan membatalkan layanan $service.',
                  routeOnTap: '/manage-orders',
                );
                break;
              }
            }
          }
        }
      } else {
        final String? uid = UserSession.userId;
        if (uid != null && uid.isNotEmpty) {
          final List<dynamic> rows = await client
              .from('notifications')
              .select()
              .eq('user_id', uid)
              .order('created_at', ascending: false)
              .limit(1);

          if (rows.isNotEmpty) {
            final Map<String, dynamic> latest =
            Map<String, dynamic>.from(rows.first as Map);
            final String latestId = (latest['id'] ?? '').toString();

            if (_lastCustomerNotifId == null) {
              _lastCustomerNotifId = latestId;
            } else if (latestId.isNotEmpty &&
                latestId != _lastCustomerNotifId) {
              _lastCustomerNotifId = latestId;
              final String title =
              (latest['title'] ?? 'Update Pesanan').toString();
              final String orderCode =
              (latest['order_code'] ?? '').toString().trim();
              final String message = (latest['message'] ??
                  'Status pesanan Anda telah diperbarui.')
                  .toString();

              final bool hasOrderCode = orderCode.isNotEmpty;

              showBanner(
                badge: title,
                badgeBg: const Color(0xFFD6EFFB),
                badgeTextColor: const Color(0xFF1B4E6C),
                icon: Icons.local_laundry_service_rounded,
                title: hasOrderCode
                    ? 'Update Pesanan $orderCode'
                    : 'Pembaruan Status Pesanan',
                subtitle: message,
                routeOnTap:
                hasOrderCode ? '/status-pesanan' : '/order-notification',
                routeArguments: hasOrderCode
                    ? <String, dynamic>{'orderId': orderCode}
                    : null,
              );
            }
          }
        }
      }
    } catch (_) {
    } finally {
      _isPolling = false;
    }
  }

  static void stopListening() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _tabRole = '';
    _lastCustomerNotifId = null;
    _adminOrderStates.clear();
    _adminInitialized = false;
  }

  static void showBanner({
    required String badge,
    required String title,
    required String subtitle,
    required String routeOnTap,
    Object? routeArguments,
    Color badgeBg = const Color(0xFFDDD6FE),
    Color badgeTextColor = const Color(0xFF5B21B6),
    IconData icon = Icons.notifications_active_rounded,
  }) {
    final NavigatorState? navState = navigatorKey.currentState;
    if (navState == null) return;

    OverlayState? overlay = navState.overlay;
    if (overlay == null) {
      try {
        overlay = Overlay.of(navState.context, rootOverlay: true);
      } catch (_) {}
    }
    if (overlay == null) return;

    _hideTimer?.cancel();
    _activeEntry?.remove();
    _activeEntry = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) => _TopPopupWidget(
        badge: badge,
        badgeBg: badgeBg,
        badgeTextColor: badgeTextColor,
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: () {
          _hideTimer?.cancel();
          entry.remove();
          if (_activeEntry == entry) _activeEntry = null;
          navState.pushNamed(routeOnTap, arguments: routeArguments);
        },
        onDismiss: () {
          _hideTimer?.cancel();
          entry.remove();
          if (_activeEntry == entry) _activeEntry = null;
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);

    _hideTimer = Timer(const Duration(seconds: 7), () {
      if (_activeEntry == entry) {
        entry.remove();
        _activeEntry = null;
      }
    });
  }
}

class _TopPopupWidget extends StatefulWidget {
  final String badge;
  final Color badgeBg;
  final Color badgeTextColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _TopPopupWidget({
    required this.badge,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_TopPopupWidget> createState() => _TopPopupWidgetState();
}

class _TopPopupWidgetState extends State<_TopPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onDismiss(),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF38BDF8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B4E6C).withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6EFFB),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: const Color(0xFF1B4E6C),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.badgeBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.badge,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: widget.badgeTextColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Baru saja',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4E6C),
                            ),
                          ),
                          Text(
                            widget.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}