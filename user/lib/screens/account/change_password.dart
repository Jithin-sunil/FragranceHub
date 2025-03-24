import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/main.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Verify old password
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: _oldPasswordController.text,
      );

      // Update password in Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      // Update password in tbl_user (if needed by your app logic)
      await supabase.from('tbl_user').update({
        'user_password': _newPasswordController.text,
      }).eq('id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Color(0xFF9575CD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('incorrect') ? 'Current password is incorrect' : 'Failed to change password'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
          'Change Password',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Your Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Keep your account secure.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'Current Password',
                controller: _oldPasswordController,
                obscureText: _obscureOldPassword,
                onToggle: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your current password';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'New Password',
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a new password';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your new password';
                  if (value != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9575CD),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Update Password',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF9575CD)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF9575CD),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
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