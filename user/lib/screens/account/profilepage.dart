import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';
import 'package:user/screens/account/auth_page.dart';
import 'package:user/screens/account/change_password.dart';
import 'package:user/screens/account/editprofile.dart';
import 'package:user/screens/shopping/my_order.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final uid = supabase.auth.currentUser?.id ?? '';
      if (uid.isEmpty) throw Exception('No user logged in');
      final response = await supabase.from('tbl_user').select().eq('id', uid).single();
      setState(() {
        user = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user: $e');
      setState(() => _isLoading = false);
    }
  }

  int _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return 0;
    final birthDate = DateTime.parse(dob);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthPage()));
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFF9575CD))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
          : user == null
              ? const Center(child: Text('User not found', style: TextStyle(fontSize: 18)))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 160,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.white,
                      title: Text(
                        'My Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF9575CD)),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()))
                                .then((_) => _fetchUser());
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFF9575CD).withOpacity(0.1),
                              child: Text(
                                user!['user_name']?.isNotEmpty == true ? user!['user_name'][0].toUpperCase() : '?',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  color: const Color(0xFF9575CD),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                user!['user_name'] ?? 'Unknown',
                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Account Details',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoTile('Name', user!['user_name'] ?? 'Not set', Icons.person),
                            _buildInfoTile('Email', user!['user_email'] ?? 'Not set', Icons.email),
                            _buildInfoTile('Phone', user!['user_contact'] ?? 'Not set', Icons.phone),
                            const SizedBox(height: 24),
                            const Text(
                              'Options',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            _buildActionTile('My Orders', Icons.shopping_bag, () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage()));
                            }),
                            _buildActionTile('Change Password', Icons.lock, () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                            }),
                            _buildActionTile('Logout', Icons.exit_to_app, _showLogoutDialog, isLogout: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9575CD), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap, {bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: isLogout ? Colors.red : const Color(0xFF9575CD), size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}