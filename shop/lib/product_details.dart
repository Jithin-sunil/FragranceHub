import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/main.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<Map<String, dynamic>> stock = [];
  List<Map<String, dynamic>> reviews = [];
  Map<String, dynamic> userNames = {};
  bool isLoadingReviews = true;
  double averageRating = 0.0;
  int reviewCount = 0;
  int selectedImageIndex = 0;
  List<String> productImages = [];

  int remaining = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    fetchStock();
    fetchReviews();
    fetchRemStock();
    // Simulate multiple product images (in a real app, you'd fetch these from your database)
    productImages = [
      widget.product['product_image'],
    ];
  }

  Future<void> fetchRemStock() async {
    try {
      final stockResponse = await supabase
          .from('tbl_stock')
          .select('stock_quantity')
          .eq('product_id', widget.product['product_id']);
      int totalStock = stockResponse.fold(0, (sum, item) => sum + (item['stock_quantity'] as int));

      final cartResponse = await supabase
          .from('tbl_cart')
          .select('cart_qty')
          .eq('product_id', widget.product['product_id']);
      int totalCartQty = cartResponse.fold(0, (sum, item) => sum + (item['cart_qty'] as int));

      int remainingStock = totalStock - totalCartQty;
      setState(() {
        remaining = remainingStock;
        total = totalStock;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchStock() async {
    try {
      final response = await supabase
          .from('tbl_stock')
          .select()
          .eq('product_id', widget.product['product_id']);
      setState(() {
        stock = response;
      });
    } catch (e) {
      print('Error in stock fetch: $e');
    }
  }

  Future<void> fetchReviews() async {
    try {
      final response = await supabase
          .from('tbl_review')
          .select()
          .eq('product_id', widget.product['product_id']);
      final reviewsList = List<Map<String, dynamic>>.from(response);

      // Calculate average rating
      double totalRating = 0;
      for (var review in reviewsList) {
        totalRating += double.parse(review['review_rating'].toString());
      }
      double avgRating = reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;

      setState(() {
        reviews = reviewsList;
        averageRating = avgRating;
        reviewCount = reviewsList.length;
        isLoadingReviews = false;
      });

      // Fetch user names for each review
      for (var review in reviews) {
        final userId = review['user_id'];
        if (userId != null) {
          final userResponse = await supabase
              .from('tbl_user')
              .select('user_name')
              .eq('id', userId)
              .single();
          setState(() {
            userNames[userId] = userResponse['user_name'] ?? 'Anonymous';
          });
        }
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        isLoadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 230, 230),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 204, 204),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Fragrance Details",
          style: GoogleFonts.sanchez(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header Section
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Images Section
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Image
                            Container(
                              height: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(productImages[selectedImageIndex]),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            // Thumbnail Images
                            Row(
                              children: List.generate(
                                productImages.length,
                                (index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImageIndex = index;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: selectedImageIndex == index
                                          ? Border.all(color: Color.fromARGB(255, 255, 204, 204), width: 2)
                                          : null,
                                      image: DecorationImage(
                                        image: NetworkImage(productImages[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 32),
                      // Product Details
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product['product_name'],
                              style: GoogleFonts.sanchez(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            // Average Rating
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: averageRating,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Color.fromARGB(255, 255, 204, 204),
                                  ),
                                  itemCount: 5,
                                  itemSize: 24.0,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  '${averageRating.toStringAsFixed(1)} ($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})',
                                  style: GoogleFonts.sanchez(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            // Product Description
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 230, 230),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description",
                                    style: GoogleFonts.sanchez(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    widget.product['product_description'],
                                    style: GoogleFonts.sanchez(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                            // Fragrance Attributes
                            // Row(
                            //   children: [
                            //     _buildInfoCard(
                            //       "Scent Notes",
                            //       widget.product['scent_notes'],
                            //       Colors.blue,
                            //     ),
                            //     SizedBox(width: 16),
                            //     _buildInfoCard(
                            //       "Volume",
                            //       "${widget.product['volume']} ml",
                            //       Colors.green,
                            //     ),
                            //   ],
                            // ),
                            SizedBox(height: 24),
                            // Stock Information
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: remaining > 0
                                        ? Color.fromARGB(255, 204, 255, 204)
                                        : Color.fromARGB(255, 255, 204, 204),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        remaining > 0 ? Icons.check_circle : Icons.error,
                                        size: 18,
                                        color: remaining > 0 ? Colors.green : Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        remaining > 0
                                            ? "In Stock ($remaining available)"
                                            : "Out of Stock",
                                        style: GoogleFonts.sanchez(
                                          fontWeight: FontWeight.bold,
                                          color: remaining > 0 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showRestockDialog(context);
                                  },
                                  icon: Icon(Icons.add_shopping_cart),
                                  label: Text("Add Stock"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 255, 204, 204),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Stock History Section
            Container(
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stock History",
                    style: GoogleFonts.sanchez(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  stock.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Color.fromARGB(255, 255, 230, 230)),
                              columns: [
                                DataColumn(
                                  label: Text(
                                    "ID",
                                    style: GoogleFonts.sanchez(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Quantity",
                                    style: GoogleFonts.sanchez(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Date Added",
                                    style: GoogleFonts.sanchez(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              rows: stock.asMap().entries.map((entry) {
                                int index = entry.key + 1;
                                var stockItem = entry.value;
                                return DataRow(
                                  cells: [
                                    DataCell(Text(
                                      index.toString(),
                                      style: GoogleFonts.sanchez(),
                                    )),
                                    DataCell(Text(
                                      stockItem['stock_quantity'].toString(),
                                      style: GoogleFonts.sanchez(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    )),
                                    DataCell(Text(
                                      stockItem['stock_date'].toString().split('T')[0],
                                      style: GoogleFonts.sanchez(),
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 230, 230),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'No stock history available',
                              style: GoogleFonts.sanchez(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Total Stock: $total",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Reviews Section
            Container(
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Customer Reviews",
                        style: GoogleFonts.sanchez(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (reviewCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 204, 204).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 18,
                                color: Color.fromARGB(255, 255, 204, 204),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${averageRating.toStringAsFixed(1)} (${reviewCount})',
                                style: GoogleFonts.sanchez(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  isLoadingReviews
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 255, 204, 204)))
                      : reviews.isEmpty
                          ? Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 230, 230),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'No reviews yet for this fragrance',
                                  style: GoogleFonts.sanchez(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: reviews.map((review) {
                                final userId = review['user_id'];
                                final userName = userNames[userId] ?? 'Anonymous';
                                final rating = double.parse(review['review_rating'].toString());
                                return Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 230, 230),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Color.fromARGB(255, 255, 204, 204).withOpacity(0.2),
                                            radius: 24,
                                            child: Text(
                                              userName.substring(0, 1).toUpperCase(),
                                              style: GoogleFonts.sanchez(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 255, 204, 204),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userName,
                                                style: GoogleFonts.sanchez(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '${DateTime.parse(review['created_at']).toLocal().toString().split(' ')[0]}',
                                                style: GoogleFonts.sanchez(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(255, 255, 204, 204).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 18,
                                                  color: Color.fromARGB(255, 255, 204, 204),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  rating.toString(),
                                                  style: GoogleFonts.sanchez(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Text(
                                          review['review_content'] ?? 'No comment',
                                          style: GoogleFonts.sanchez(
                                            color: Colors.grey[600],
                                            height: 1.5,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.sanchez(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.sanchez(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

void _showRestockDialog(BuildContext context) {
  final TextEditingController _quantityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> updateStock() async {
    try {
      await supabase.from('tbl_stock').insert({
        'product_id': widget.product['product_id'],
        'stock_quantity': _quantityController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fragrance restocked successfully")),
      );
      Navigator.pop(context); // Close dialog
      fetchStock(); // Refresh stock data
      fetchRemStock();
    } catch (e) {
      print(e);
    }
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Restock Fragrance",
        style: GoogleFonts.sanchez(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter the quantity to restock '${widget.product['product_name']}'",
              style: GoogleFonts.sanchez(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity",
                prefixIcon: Icon(Icons.add_shopping_cart, color: Color.fromARGB(255, 255, 204, 204)),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a quantity for the fragrance";
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return "Please enter a valid positive number";
                }
                return null;
              },
            ),
          ],
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
            if (_formKey.currentState!.validate()) {
              updateStock();
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
            "Restock",
            style: GoogleFonts.sanchez(),
          ),
        ),
      ],
    ),
  );
}
}