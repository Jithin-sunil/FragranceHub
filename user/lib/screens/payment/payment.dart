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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  Future<void> checkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    try {
      await supabase.from('tbl_cart').update({'cart_status': 1}).eq('booking_id', widget.id);
      await supabase.from('tbl_booking').update({'booking_status': 1, 'booking_amount': widget.amt}).eq('id', widget.id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Enter Payment Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Card Number', border: OutlineInputBorder()),
                validator: (value) => value!.length == 16 ? null : 'Enter a valid card number',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardHolderController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(labelText: 'Cardholder Name', border: OutlineInputBorder()),
                validator: (value) => value!.isNotEmpty ? null : 'Enter cardholder name',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expDateController,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)', border: OutlineInputBorder()),
                      validator: (value) => value!.length == 5 ? null : 'Enter a valid date',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                      validator: (value) => value!.length == 3 ? null : 'Enter a valid CVV',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
      ),
    );
  }
}
