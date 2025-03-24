import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/screens/payment/success.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final int id;
  final int amt;
  const PaymentGatewayScreen({super.key, required this.id, required this.amt});

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  bool _isProcessing = false;

  Future<void> checkout() async {
    setState(() => _isProcessing = true);
    try {
      await supabase.from('tbl_cart').update({'cart_status': 1}).eq('booking_id', widget.id);
      await supabase
          .from('tbl_booking')
          .update({'booking_status': 1, 'booking_amount': widget.amt}).eq('id', widget.id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  PaymentSuccessPage()),
      );
    } catch (e) {
      print('Error during checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
      setState(() => _isProcessing = false);
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
          'Payment',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Complete Your Purchase',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: ₹${widget.amt}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF9575CD)),
            ),
            const SizedBox(height: 24),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isProcessing ? null : checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9575CD),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Pay Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Secure payment powered by FragranceHub',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}