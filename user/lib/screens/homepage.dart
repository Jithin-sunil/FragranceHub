import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart'; // Assuming supabase is defined here
import 'package:user/screens/account/profilepage.dart';
import 'package:user/screens/shopping/my_order.dart'; // Orders page
import 'package:user/screens/shopping/shopping.dart'; // Shopping page
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> featuredPerfumes = [];
  String dailyDeal = "Get 20% off on Floral Scents today!";
  String? userName;

  Future<void> _fetchProducts() async {
    try {
      final response = await supabase.from('tbl_product').select().limit(5);
      setState(() {
        featuredPerfumes = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;
      final response = await supabase.from('tbl_user').select('user_name').eq('id', uid).single();
      setState(() {
        userName = response['user_name'] ?? 'Scent Explorer';
        dailyDeal = "Get 20% off on Floral Scents today!";
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => userName = 'Scent Explorer');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'FragranceHub',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9575CD),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF9575CD).withOpacity(0.1),
                child: const Icon(Icons.person, color: Color(0xFF9575CD), size: 24),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            _buildQuickActions(context),
            _buildFeaturedCarousel(),
            _buildDailyDealBanner(),
            _buildCategoryList(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${userName ?? 'Scent Explorer'}!',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          const Text(
            'Discover your perfect fragrance today.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            context,
            'Shop Now',
            Icons.store,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingPage())),
          ),
          _buildActionButton(
            context,
            'My Orders',
            Icons.shopping_bag,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9575CD), size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: featuredPerfumes.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
          : CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
              ),
              items: featuredPerfumes.map((perfume) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            perfume['product_image'] ?? 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              perfume['product_name'] ?? 'Unknown Perfume',
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingPage())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9575CD),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: Text(
                                'Explore',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDailyDealBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF9575CD).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Color(0xFF9575CD), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dailyDeal,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final categories = [
      {'name': 'Floral', 'icon': Icons.local_florist, 'color': const Color(0xFFF06292)},
      {'name': 'Woody', 'icon': Icons.park, 'color': const Color(0xFF8D6E63)},
      {'name': 'Citrus', 'icon': Icons.local_drink, 'color': const Color(0xFFFFCA28)},
      {'name': 'Oriental', 'icon': Icons.star_border, 'color': const Color(0xFFD81B60)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingPage())),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(category['icon'] as IconData, color: category['color'] as Color, size: 30),
                        const SizedBox(height: 8),
                        Text(
                          category['name'] as String,
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
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