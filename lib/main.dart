import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_chat_list_page.dart';
import 'admin_chat_room_page.dart';
import 'admin_notification_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'booking_page.dart';
import 'customer_data_page.dart';
import 'manage_services_page.dart';
import 'order_notification_page.dart';
import 'order_history_page.dart';
import 'order_confirmation_page.dart';
import 'order_detail_page.dart';
import 'status_pesanan.dart';
import 'chat_room_page.dart';
import 'chat_list_page.dart';
import 'profile_page.dart';
import 'admin_home_page.dart';
import 'rekapitulasi_transaksi.dart';
import 'admin_profile_page.dart';
import 'manage_orders_page.dart';
import 'payment_page.dart';
import 'realtime_notif_banner.dart';
import 'user_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hhtmqpoitzeyigjszaqb.supabase.co',
    anonKey: 'sb_publishable_xsSzM1ePCrevVp-QcAH2NA_Ukysdyun',
  );

  final bool isLoggedIn = await UserSession.loadFromPrefs();
  final String startRoute = !isLoggedIn
      ? '/login'
      : (UserSession.role == 'admin' ? '/admin-home' : '/home');

  RealtimeNotifService.startListening();

  runApp(MyApp(initialRoute: startRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RealtimeNotifService.navigatorKey,
      navigatorObservers: [RealtimeNotifService.routeObserver],
      title: 'Wish You Wash Here',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFD6EFFB),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF338CA8),
          primary: const Color(0xFF338CA8),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/booking': (context) => const BookingPage(),
        '/customer-data': (context) => const CustomerDataPage(),
        '/manage-services': (context) => const ManageServicesPage(),
        '/order-notification': (context) => const OrderNotificationPage(),
        '/order-history': (context) => const OrderHistoryPage(),
        '/order-detail': (context) => const OrderDetailPage(),
        '/order-confirmation': (context) => const OrderConfirmationPage(),
        '/status-pesanan': (context) => const StatusPesananPage(),
        '/chat-room': (context) => const ChatRoomPage(),
        '/chat': (context) => const ChatListPage(),
        '/profile': (context) => const ProfilePage(),
        '/admin-home': (context) => const AdminHomePage(),
        '/rekapitulasi-transaksi': (context) => const RekapitulasiTransaksiPage(),
        '/admin-profile': (context) => const AdminProfilePage(),
        '/admin-notification': (context) => const AdminNotificationPage(),
        '/admin-chat-room': (context) => const AdminChatRoomPage(),
        '/admin-chat': (context) => const AdminChatListPage(),
        '/manage-orders': (context) => const ManageOrdersPage(),
        '/payment': (context) => const PaymentPage(),
      },
    );
  }
}