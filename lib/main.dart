import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'chat_room_page.dart';
import 'chat_list_page.dart';
import 'profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: '/login',
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
        '/chat': (context) => const ChatListPage(),
        '/chat-room': (context) => const ChatRoomPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}