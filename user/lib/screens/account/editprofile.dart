import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:user/main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? user;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _fetchUser() async {
    try {
      final uid = supabase.auth.currentUser!.id;
      final response = await supabase.from('tbl_user').select().eq('id', uid).single();
      setState(() {
        user = response;
        _nameController.text = user!['user_name'] ?? '';
        _emailController.text = user!['user_email'] ?? '';
        _contactController.text = user!['user_contact'] ?? '';
        _dobController.text = user!['user_dob'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = supabase.auth.currentUser!.id;
      await supabase.from('tbl_user').update({
        'user_name': _nameController.text,
        'user_contact': _contactController.text,
        'user_dob': _dobController.text,
      }).eq('id', uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF9575CD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error updating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF9575CD).withOpacity(0.1),
                        child: Text(
                          _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            color: const Color(0xFF9575CD),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Personal Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Update your information below.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.email,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Phone Number',
                      controller: _contactController,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _updateUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9575CD),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Save Changes',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF9575CD)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: GoogleFonts.poppins(),
      validator: validator,
    );
  }

  
  
}