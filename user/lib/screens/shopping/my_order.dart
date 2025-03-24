import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/screens/shopping/order_details.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> cartProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartProducts();
  }

  // Fetch Orders from Supabase
  Future<void> fetchCartProducts() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final bookings = await supabase
          .from('tbl_booking')
          .select('id')
          .eq('user_id', user.id)
          .eq('booking_status', 1);

      if (bookings.isEmpty) {
        setState(() {
          cartProducts = [];
          isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> products = [];
      for (var booking in bookings) {
        final cartResponse = await supabase
            .from('tbl_cart')
            .select('*')
            .eq('booking_id', booking['id']);

        for (var cartItem in cartResponse) {
          final productResponse = await supabase
              .from('tbl_product')
              .select('product_name, product_image, product_price')
              .eq('product_id', cartItem['product_id'])
              .maybeSingle();

          if (productResponse != null) {
            products.add({
              "id": cartItem['id'],
              "order_id": cartItem['booking_id'],
              "product_id": cartItem['product_id'],
              "name": productResponse['product_name'],
              "image": productResponse['product_image'],
              "price": productResponse['product_price'],
              "quantity": cartItem['cart_qty'],
            });
          }
        }
      }

      setState(() {
        cartProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() => isLoading = false);
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
          'My Orders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
          : cartProducts.isEmpty
              ? _buildEmptyOrders()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartProducts.length,
                  itemBuilder: (context, index) {
                    var product = cartProducts[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 12), // Fixed typo: 'bottom' intended
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(
                                orderId: product['order_id'],
                                cartId: product['id'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product['image'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₹${product['price']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF9575CD),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Qty: ${product['quantity']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF9575CD),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9575CD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Shop Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}