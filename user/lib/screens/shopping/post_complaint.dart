import 'package:flutter/material.dart';
import 'package:user/main.dart';

class ComplaintPage extends StatefulWidget {
  final int id;

  const ComplaintPage({super.key, required this.id});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitComplaint() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to submit a complaint')),
      );
      return;
    }

    if (_titleController.text.isEmpty || _complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both title and complaint')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await supabase.from('tbl_complaint').insert({
        'complaint_title': _titleController.text,
        'complaint_content': _complaintController.text,
        'user_id': userId,
        'product_id': widget.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint submitted successfully'),
          backgroundColor: Color(0xFF9575CD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      _titleController.clear();
      _complaintController.clear();
      Navigator.pop(context); // Return to previous screen after submission
    } catch (e) {
      print("Error submitting complaint: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit complaint: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Submit a Complaint',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaint Title',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Enter a brief title...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF9575CD)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Describe Your Complaint',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _complaintController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Tell us what went wrong...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF9575CD)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSubmitting ? null : submitComplaint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9575CD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
              ),
              child: isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Submit Complaint',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _complaintController.dispose();
    super.dispose();
  }
}