import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:user/main.dart';

class FeedbackPage extends StatefulWidget {
  final int pid;
  const FeedbackPage({super.key, required this.pid});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await supabase.from('tbl_review').insert({
        'review_content': _feedbackController.text,
        'review_rating': _rating,
        'product_id': widget.pid,
        'user_id': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your feedback has been submitted!'),
          backgroundColor: Color(0xFF9575CD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );

      setState(() => _submitted = true);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Leave a Review',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _submitted ? _buildThankYouScreen() : _buildFeedbackForm(),
    );
  }

  Widget _buildFeedbackForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate Your Experience',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us what you think!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Center(
            child: RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => setState(() => _rating = rating),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _getRatingText(),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Feedback',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9575CD),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Submit Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Color(0xFF9575CD),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank You!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'We appreciate your feedback.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9575CD),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Back to Product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    if (_rating == 0) return 'Tap to rate';
    if (_rating <= 1) return 'Poor';
    if (_rating <= 2) return 'Fair';
    if (_rating <= 3) return 'Good';
    if (_rating <= 4) return 'Very Good';
    return 'Excellent';
  }
}