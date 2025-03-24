import 'package:flutter/material.dart';
import 'package:user/main.dart';
import 'package:user/screens/shopping/my_order.dart';
import 'package:user/screens/payment/payment.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  int? bid;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  // Fetch Cart Items from Supabase
  Future<void> fetchCartItems() async {
    try {
      final booking = await supabase
          .from('tbl_booking')
          .select("id")
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('booking_status', 0)
          .maybeSingle();

      if (booking == null) {
        setState(() {
          cartItems = [];
          isLoading = false;
        });
        return;
      }

      int bookingId = booking['id'];
      setState(() {
        bid = bookingId;
      });

      final cartResponse = await supabase
          .from('tbl_cart')
          .select('*')
          .eq('booking_id', bookingId)
          .eq('cart_status', 0);

      List<Map<String, dynamic>> items = [];
      for (var cartItem in cartResponse) {
        final itemResponse = await supabase
            .from('tbl_product')
            .select('product_name, product_image, product_price')
            .eq('product_id', cartItem['product_id'])
            .maybeSingle();

        final stock = await supabase
            .from('tbl_stock')
            .select('stock_quantity')
            .eq('product_id', cartItem['product_id']);

        int totalStock =
            stock.fold(0, (sum, item) => sum + (item['stock_quantity'] as int));

        final cart = await supabase
            .from('tbl_cart')
            .select('cart_qty')
            .eq('product_id', cartItem['product_id']);

        int totalCartQty =
            cart.fold(0, (sum, item) => sum + (item['cart_qty'] as int));

        num remainingStock = totalStock - totalCartQty + cartItem['cart_qty'];

        if (itemResponse != null) {
          items.add({
            "id": cartItem['id'],
            "product_id": cartItem['product_id'],
            "name": itemResponse['product_name'],
            "image": itemResponse['product_image'],
            "price": itemResponse['product_price'],
            "quantity": cartItem['cart_qty'],
            "stock": remainingStock,
          });
        }
      }

      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cart data: $e");
      setState(() => isLoading = false);
    }
  }

  // Update Cart Quantity
  Future<void> updateCartQuantity(int cartId, int newQty) async {
    try {
      await supabase
          .from('tbl_cart')
          .update({'cart_qty': newQty})
          .eq('id', cartId);
      fetchCartItems();
    } catch (e) {
      print("Error updating cart quantity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity')),
      );
    }
  }

  // Delete Item from Cart
  Future<void> deleteCartItem(int cartId) async {
    try {
      await supabase.from('tbl_cart').delete().eq('id', cartId);
      fetchCartItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from cart'),
          backgroundColor: Color(0xFF9575CD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      print("Error deleting item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item')),
      );
    }
  }

  // Calculate Total Price
  double getTotalPrice() {
    return cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your Cart',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Color(0xFF9575CD)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
            },
            tooltip: 'My Orders',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
          : cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var item = cartItems[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['image'],
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                item['name'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                                              onPressed: () => deleteCartItem(item['id']),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '₹${item['price']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF9575CD),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildQuantityControl(item),
                                            SizedBox(width: 8),
                                            if (item['stock'] <= 5 && item['stock'] > 0)
                                              Text(
                                                'Only ${item['stock']} left',
                                                style: TextStyle(color: Colors.orange[700], fontSize: 12),
                                              ),
                                            if (item['stock'] <= 0)
                                              Text(
                                                'Out of stock',
                                                style: TextStyle(color: Colors.red, fontSize: 12),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildCheckoutSection(),
                  ],
                ),
    );
  }

  Widget _buildQuantityControl(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: 16),
            onPressed: item['quantity'] > 1
                ? () => updateCartQuantity(item['id'], item['quantity'] - 1)
                : null,
          ),
          Text(
            item['quantity'].toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 16),
            onPressed: item['stock'] > 0
                ? () => updateCartQuantity(item['id'], item['quantity'] + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${getTotalPrice().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9575CD),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: cartItems.isEmpty
                ? null
                : () {
                    int total = getTotalPrice().toInt();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentGatewayScreen(id: bid!, amt: total),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9575CD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 16),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Proceed to Checkout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some fragrances to get started!',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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