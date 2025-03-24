import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/screens/shopping/cart.dart';
import 'package:user/screens/shopping/product_details.dart';
import 'package:user/screens/shopping/wishlist.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final response = await supabase.from('tbl_product').select();
      List<Map<String, dynamic>> products = [];
      for (var item in response) {
        final reviewResponse = await supabase
            .from('tbl_review')
            .select()
            .eq('product_id', item['product_id']);
        
        final reviewsList = List<Map<String, dynamic>>.from(reviewResponse);
        double totalRating = 0;
        for (var review in reviewsList) {
          totalRating += double.parse(review['review_rating'].toString());
        }
        double avgRating = reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;
        item['rating'] = avgRating;
        products.add(item);
      }
      setState(() {
        items = products;
        filteredItems = products;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching perfumes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterItems() {
    setState(() {
      filteredItems = items.where((item) {
        return searchQuery.isEmpty || 
            item['product_name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2F7),
      appBar: AppBar(
        title: Text('FragranceHub', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Wishlist()));
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search fragrances...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      filterItems();
                    },
                  ),
                ),
                
                // Product grid
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            'No fragrances found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(productId: item['product_id']),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Perfume image
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                          image: DecorationImage(
                                            image: NetworkImage(item['product_image']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Perfume info
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['product_name'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '₹${item['product_price']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF9575CD),
                                            ),
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
              ],
            ),
    );
  }
}