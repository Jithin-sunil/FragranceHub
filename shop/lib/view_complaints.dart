import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/main.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase.from('tbl_complaint').select(
          "*, tbl_product(product_name), tbl_user(user_name, user_email, user_contact)");
      setState(() {
        complaints = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching complaints: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateReply(int id, String reply) async {
    try {
      await supabase.from('tbl_complaint').update({'complaint_reply': reply}).eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reply added")));
      fetchComplaints(); // Refresh data
    } catch (e) {
      print("Error updating reply: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 230, 230),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Complaint Management",
              style: GoogleFonts.sanchez(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Complaints List
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 255, 204, 204),
                        ),
                      )
                    : complaints.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "No complaints found",
                                  style: GoogleFonts.sanchez(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: complaints.length,
                            itemBuilder: (context, index) {
                              final complaint = complaints[index];
                              return _buildComplaintCard(complaint);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    Color statusColor;
    String statusLabel;

    switch (complaint['complaint_status']) {
      case 0:
        statusColor = Colors.orange;
        statusLabel = "Pending";
        break;
      case 1:
        statusColor = Colors.green;
        statusLabel = "Resolved";
        break;
      default:
        statusColor = Colors.red;
        statusLabel = "Unresolved";
    }

    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  complaint['tbl_user']['user_name'],
                  style: GoogleFonts.sanchez(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Product Name
            Row(
              children: [
                Icon(Icons.sanitizer_outlined, size: 16, color: Colors.grey[600]),
                SizedBox(width: 5),
                Text(
                  complaint['tbl_product']['product_name'] ?? 'Unknown Fragrance',
                  style: GoogleFonts.sanchez(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Complaint Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 5),
                Text(
                  DateTime.parse(complaint['complaint_replydate']).toString().split(' ')[0],
                  style: GoogleFonts.sanchez(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Complaint Content
            Text(
              "Issue:",
              style: GoogleFonts.sanchez(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              complaint['complaint_content'],
              style: GoogleFonts.sanchez(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),

            // Reply Section
            if (complaint['complaint_reply'] != null && complaint['complaint_reply'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reply:",
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    complaint['complaint_reply'],
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),

            // Add Reply Button
            if (complaint['complaint_status'] == 0)
              ElevatedButton.icon(
                onPressed: () {
                  _showReplyDialog(context, complaint['id']);
                },
                icon: Icon(Icons.reply),
                label: Text("Add Reply"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 204, 204),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(BuildContext context, int complaintId) {
    final TextEditingController _replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Add Reply",
          style: GoogleFonts.sanchez(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: TextField(
          controller: _replyController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Reply",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Color.fromARGB(255, 255, 204, 204),
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.sanchez(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_replyController.text.isNotEmpty) {
                updateReply(complaintId, _replyController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 255, 204, 204),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Submit",
              style: GoogleFonts.sanchez(),
            ),
          ),
        ],
      ),
    );
  }
}