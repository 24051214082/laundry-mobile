import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerDataPage extends StatefulWidget {
  const CustomerDataPage({super.key});

  @override
  State<CustomerDataPage> createState() => _CustomerDataPageState();
}

class _CustomerDataPageState extends State<CustomerDataPage> {
  final TextEditingController _searchController = TextEditingController();

  List _allCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOption = 'Terbaru'; // Pilihan: 'Terbaru', 'A-Z', 'Z-A'

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('id, name, phone, email, address, created_at')
          .eq('role', 'customer')
          .order('created_at', ascending: false);

      if (!mounted) return;

      final List mapped = List.from(response).map((row) {
        final rawPhone = (row['phone'] ?? '').toString().trim();
        final rawAddress = (row['address'] ?? '').toString().trim();

        return {
          'id': (row['id'] ?? '').toString(),
          'name': (row['name'] ?? 'Tanpa Nama').toString(),
          'phone': rawPhone.isEmpty ? '-' : rawPhone,
          'email': (row['email'] ?? '-').toString(),
          'address': rawAddress.isEmpty ? 'Alamat belum diisi' : rawAddress,
          'created_at': (row['created_at'] ?? '').toString(),
          'avatarUrl': null,
        };
      }).toList();

      setState(() {
        _allCustomers = mapped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data customer: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Filter pencarian & pengurutan otomatis
  List get _filteredAndSortedCustomers {
    final query = _searchQuery.toLowerCase().trim();
    final filtered = _allCustomers.where((customer) {
      if (query.isEmpty) return true;
      final name = customer['name'].toString().toLowerCase();
      final phone = customer['phone'].toString().toLowerCase();
      final email = customer['email'].toString().toLowerCase();
      return name.contains(query) ||
          phone.contains(query) ||
          email.contains(query);
    }).toList();

    if (_sortOption == 'A-Z') {
      filtered.sort((a, b) => a['name']
          .toString()
          .toLowerCase()
          .compareTo(b['name'].toString().toLowerCase()));
    } else if (_sortOption == 'Z-A') {
      filtered.sort((a, b) => b['name']
          .toString()
          .toLowerCase()
          .compareTo(a['name'].toString().toLowerCase()));
    } else {
      filtered.sort((a, b) => b['created_at']
          .toString()
          .compareTo(a['created_at'].toString()));
    }

    return filtered;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Urutkan Daftar Customer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F3A6E),
                ),
              ),
              const SizedBox(height: 12),
              _buildSortOptionTile('Terbaru', Icons.access_time_rounded),
              _buildSortOptionTile('A-Z', Icons.sort_by_alpha_rounded),
              _buildSortOptionTile('Z-A', Icons.sort_by_alpha_rounded),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOptionTile(String option, IconData icon) {
    final bool isSelected = _sortOption == option;
    final String labelText = option == 'Terbaru'
        ? 'Terbaru (Pendaftar Terakhir)'
        : option == 'A-Z'
        ? 'Nama (A - Z)'
        : 'Nama (Z - A)';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF338CA8) : const Color(0xFF64748B),
      ),
      title: Text(
        labelText,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? const Color(0xFF1F3A6E) : const Color(0xFF475569),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF338CA8))
          : null,
      onTap: () {
        setState(() {
          _sortOption = option;
        });
        Navigator.pop(context);
      },
    );
  }

  // Pop-up Detail Customer yang strukturnya disamakan persis dengan ProfilePage
  void _showCustomerDetail(Map customer) {
    final String? avatarUrl = customer['avatarUrl'];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Pop-up + Avatar
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4285F4),
                      border: Border.all(
                        color: const Color(0xFFD6EFFB),
                        width: 2.5,
                      ),
                      image: avatarUrl != null && avatarUrl.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                customer['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F3A6E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Color(0xFF0284C7),
                            ),
                          ],
                        ),
                        Text(
                          'Pelanggan Terdaftar',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Seksi 1: Informasi Pribadi
              Text(
                'Informasi Pribadi',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F3A6E),
                ),
              ),
              const SizedBox(height: 10),
              _buildProfileFieldCard(
                label: 'Nama Lengkap',
                value: customer['name'],
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 10),
              _buildProfileFieldCard(
                label: 'Nomor HP',
                value: customer['phone'],
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 10),
              _buildProfileFieldCard(
                label: 'Email',
                value: customer['email'],
                icon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 16),

              // Seksi 2: Alamat Utama
              Text(
                'Alamat Utama',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F3A6E),
                ),
              ),
              const SizedBox(height: 10),
              _buildProfileFieldCard(
                label: 'Alamat Utama',
                value: customer['address'],
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),

              // Tombol Tutup & Chat Pelanggan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F3A6E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/admin-chat-room',
                          arguments: {
                            'customerId': customer['id'],
                            'customerName': customer['name'],
                            'orderId': '-',
                            'serviceName': 'Layanan Laundry',
                            'status': 'Aktif',
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Chat',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF338CA8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileFieldCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF338CA8)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F3A6E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedCustomers = _filteredAndSortedCustomers;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFD6EFFB),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF1B4E6C),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/admin-notification',
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Color(0xFF1B4E6C),
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFF4285F4),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Halo,',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF1B4E6C),
                    ),
                  ),
                  Text(
                    'Data Customer',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B4E6C),
                    ),
                  ),
                  Text(
                    'Lihat dan kelola informasi pelanggan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF2E637E),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Input Box
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Cari nama customer, nomor HP, atau Email..',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 10),
                          child: Icon(
                            Icons.search,
                            color: Color(0xFF1B4E6C),
                            size: 26,
                          ),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content List Section
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchCustomers,
                color: const Color(0xFF338CA8),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daftar Customer',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4E6C),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6EFFB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Total : ${displayedCustomers.length} customer',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1B4E6C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sort by',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1B4E6C),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showSortOptions,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _sortOption,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1B4E6C),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_circle_down,
                                    size: 16,
                                    color: Color(0xFF1B4E6C),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: CircularProgressIndicator(
                            color: Color(0xFF338CA8),
                          ),
                        )
                      else if (displayedCustomers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Customer tidak ditemukan',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedCustomers.length,
                          separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = displayedCustomers[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                Border.all(color: const Color(0xFFF1F5F9)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Color(0xFF4285F4),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1B4E6C),
                                          ),
                                        ),
                                        Text(
                                          'HP : ${item['phone']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: const Color(0xFF475569),
                                          ),
                                        ),
                                        Text(
                                          'Email : ${item['email']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _showCustomerDetail(item),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD6EFFB),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Detail',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1B4E6C),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          Icons
                                              .keyboard_double_arrow_right_rounded,
                                          size: 16,
                                          color: Color(0xFF1B4E6C),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}