import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/screens/shopping/cart.dart';
import 'package:user/service/cart_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductPage extends StatefulWidget {
  final int productId;

  const ProductPage({super.key, required this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? product;
  int? remainingStock;
  bool isLoading = true;
  List<Map<String, dynamic>> reviews = [];
  double averageRating = 0.0;
  int reviewCount = 0;
  bool _isWishlisted = false;

  final cartService = CartService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    fetchReviews();
    _checkWishlistStatus();
  }

  Future<void> fetchProductDetails() async {
    try {
      final stock = await supabase
          .from('tbl_stock')
          .select('stock_quantity')
          .eq('product_id', widget.productId);
      int totalStock = stock.fold(0, (sum, item) => sum + (item['stock_quantity'] as int));

      final cart = await supabase
          .from('tbl_cart')
          .select('cart_qty')
          .eq('product_id', widget.productId);
      int totalCartQty = cart.fold(0, (sum, item) => sum + (item['cart_qty'] as int));

      final response = await supabase
          .from('tbl_product')
          .select()
          .eq('product_id', widget.productId)
          .single();

      setState(() {
        remainingStock = totalStock - totalCartQty;
        product = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching product details: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchReviews() async {
    try {
      final response = await supabase
          .from('tbl_review')
          .select()
          .eq('product_id', widget.productId);
      final reviewsList = List<Map<String, dynamic>>.from(response);

      double totalRating = reviewsList.fold(0, (sum, review) => sum + (review['review_rating'] as num));
      double avgRating = reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;

      setState(() {
        reviews = reviewsList;
        averageRating = avgRating;
        reviewCount = reviewsList.length;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      final response = await supabase
          .from('tbl_wishlist')
          .select()
          .eq('product_id', widget.productId)
          .eq('user_id', userId)
          .maybeSingle();

      setState(() => _isWishlisted = response != null);
    } catch (e) {
      print('Error checking wishlist: $e');
    }
  }

  Future<void> _toggleWishlist() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (_isWishlisted) {
        await supabase
            .from('tbl_wishlist')
            .delete()
            .eq('product_id', widget.productId)
            .eq('user_id', userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from wishlist')),
        );
      } else {
        await supabase.from('tbl_wishlist').insert({
          'product_id': widget.productId,
          'user_id': userId,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to wishlist')),
        );
      }
      setState(() => _isWishlisted = !_isWishlisted);
    } catch (e) {
      print('Error toggling wishlist: $e');
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
          product?['product_name'] ?? 'Loading...',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
          : product == null
              ? const Center(child: Text('Product not found', style: TextStyle(fontSize: 18)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Image.network(
                        product!['product_image'],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name and Price
                            Text(
                              product!['product_name'],
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${product!['product_price']}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF9575CD)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              remainingStock! <= 0 ? 'Out of Stock' : '$remainingStock in stock',
                              style: TextStyle(
                                fontSize: 14,
                                color: remainingStock! <= 0 ? Colors.red : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Description
                            const Text(
                              'Description',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product!['product_description'] ?? 'No description available',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),

                            // Rating
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: averageRating,
                                  itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  direction: Axis.horizontal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${averageRating.toStringAsFixed(1)} ($reviewCount reviews)',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: remainingStock! <= 0
                                        ? null
                                        : () => cartService.addToCart(context, product!['product_id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9575CD),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      remainingStock! <= 0 ? 'Out of Stock' : 'Add to Cart',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: _toggleWishlist,
                                  icon: Icon(
                                    _isWishlisted ? Icons.favorite : Icons.favorite_border,
                                    color: _isWishlisted ? Colors.red : Colors.grey,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Reviews
                            const Text(
                              'Reviews',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            reviews.isEmpty
                                ? const Text(
                                    'No reviews yet.',
                                    style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: reviews.length > 3 ? 3 : reviews.length, // Limit to 3 reviews
                                    itemBuilder: (context, index) {
                                      final review = reviews[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                RatingBarIndicator(
                                                  rating: (review['review_rating'] as num).toDouble(),
                                                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                                  itemCount: 5,
                                                  itemSize: 16.0,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  DateTime.parse(review['created_at']).toLocal().toString().split(' ')[0],
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              review['review_content'] ?? 'No comment',
                                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}