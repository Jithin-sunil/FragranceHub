import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shop/landingpage.dart';
import 'package:shop/main.dart';
import 'package:shop/myaccount.dart';
import 'package:shop/orders.dart';
import 'package:shop/products.dart';
import 'package:shop/view_complaints.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    DashboardHomeTab(),
    ProductManagementPage(),
    BookingManagementPage(),
    ComplaintsPage(),
    ShopProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            minExtendedWidth: 230,
            backgroundColor: Color.fromARGB(255, 255, 204, 204),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sanitizer, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  if (MediaQuery.of(context).size.width > 1200)
                    Text(
                      "FragranceHub",
                      style: GoogleFonts.aclonica(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  // Logout logic
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandingPage(),
                    ),
                  );
                },
              ),
            ),
            labelType: NavigationRailLabelType.none,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard, color: Colors.white70),
                selectedIcon: Icon(Icons.dashboard, color: Colors.white),
                label: Text(
                  'Dashboard',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2, color: Colors.white70),
                selectedIcon: Icon(Icons.inventory_2, color: Colors.white),
                label: Text(
                  'Products',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart, color: Colors.white70),
                selectedIcon: Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  'Orders',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.comment, color: Colors.white70),
                selectedIcon: Icon(Icons.comment, color: Colors.white),
                label: Text(
                  'Complaints',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person, color: Colors.white70),
                selectedIcon: Icon(Icons.person, color: Colors.white),
                label: Text(
                  'Account',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class DashboardHomeTab extends StatefulWidget {
  @override
  State<DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<DashboardHomeTab> {
  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> recentOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
    fetchRecentOrders();
  }

  Future<void> fetchStats() async {
    try {
      // Fetch total products
      final productResponse = await supabase
          .from('tbl_product')
          .select('product_id') // Select only the ID column (or any other column)
          ;
      final totalProducts = productResponse.length;

      // Fetch total bookings and total sales amount
      final bookingResponse = await supabase
          .from('tbl_booking')
          .select('COUNT(*), SUM(booking_amount)')
          .single();
          print(bookingResponse);
      final totalBookings = bookingResponse['count'];
      final totalSales = bookingResponse['sum'];

      // Fetch total complaints
      final complaintResponse = await supabase
          .from('tbl_complaint')
          .select('id') // Select only the ID column (or any other column)
          ;
      final totalComplaints = complaintResponse.length;

      setState(() {
        stats = {
          'totalProducts': totalProducts,
          'totalBookings': totalBookings,
          'totalSales': totalSales,
          'totalComplaints': totalComplaints,
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching stats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRecentOrders() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select('id, booking_status, booking_amount, user_id, tbl_cart(product_id, cart_status)')
          .limit(10); // Limit to 10 recent orders

      setState(() {
        recentOrders = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 250),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard",
                      style: GoogleFonts.sanchez(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Welcome back, Shop Owner!",
                      style: GoogleFonts.sanchez(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_none),
                      onPressed: () {},
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 255, 204, 204),
                      child: Text(
                        "SO",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),

            // Stats Cards
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Total Products",
                      value: stats['totalProducts'].toString(),
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      title: "Total Bookings",
                      value: stats['totalBookings'].toString(),
                      icon: Icons.shopping_cart_outlined,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      title: "Total Complaints",
                      value: stats['totalComplaints'].toString(),
                      icon: Icons.comment,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      title: "Total Sales",
                      value: "\$${stats['totalSales'].toString()}",
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

            SizedBox(height: 30),

            // Charts Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sales Chart
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 350,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sales Overview",
                          style: GoogleFonts.sanchez(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                      if (value.toInt() < 0 || value.toInt() >= titles.length) {
                                        return Text('');
                                      }
                                      return Text(
                                        titles[value.toInt()],
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 3),
                                    FlSpot(1, 1),
                                    FlSpot(2, 4),
                                    FlSpot(3, 2),
                                    FlSpot(4, 5),
                                    FlSpot(5, 3),
                                  ],
                                  isCurved: true,
                                  color: Color.fromARGB(255, 255, 204, 204),
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Color.fromARGB(255, 255, 204, 204).withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
                // Product Categories
                Expanded(
                  child: Container(
                    height: 350,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Product Categories",
                          style: GoogleFonts.sanchez(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.blue,
                                  value: 40,
                                  title: '40%',
                                  radius: 50,
                                  titleStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.pink,
                                  value: 30,
                                  title: '30%',
                                  radius: 50,
                                  titleStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: 15,
                                  title: '15%',
                                  radius: 50,
                                  titleStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.orange,
                                  value: 15,
                                  title: '15%',
                                  radius: 50,
                                  titleStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildCategoryLegend(
                          color: Colors.blue,
                          label: "Perfumes",
                          percentage: "40%",
                        ),
                        SizedBox(height: 5),
                        _buildCategoryLegend(
                          color: Colors.pink,
                          label: "Body Mists",
                          percentage: "30%",
                        ),
                        SizedBox(height: 5),
                        _buildCategoryLegend(
                          color: Colors.green,
                          label: "Candles",
                          percentage: "15%",
                        ),
                        SizedBox(height: 5),
                        _buildCategoryLegend(
                          color: Colors.orange,
                          label: "Diffusers",
                          percentage: "15%",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Recent Orders
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Orders",
                        style: GoogleFonts.sanchez(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "View All",
                          style: GoogleFonts.sanchez(
                            color: Color.fromARGB(255, 255, 204, 204),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            "Order ID",
                            style: GoogleFonts.sanchez(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Status",
                            style: GoogleFonts.sanchez(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Amount",
                            style: GoogleFonts.sanchez(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Cart Items",
                            style: GoogleFonts.sanchez(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: recentOrders.map((order) {
                        return DataRow(
                          cells: [
                            DataCell(Text(order['id'].toString())),
                            DataCell(
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: order['booking_status'].toString() == 'Confirmed'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  order['booking_status'].toString(),
                                  style: TextStyle(
                                    color: order['booking_status'].toString() == 'Confirmed'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text('\$${order['booking_amount'].toString()}')),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (order['tbl_cart'] as List<dynamic>)
                                    .map((cartItem) => Text(
                                          'Product ID: ${cartItem['product_id'].toString()} (${cartItem['cart_status']})',
                                          style: TextStyle(fontSize: 12),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.sanchez(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.sanchez(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend({
    required Color color,
    required String label,
    required String percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.sanchez(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        Spacer(),
        Text(
          percentage,
          style: GoogleFonts.sanchez(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}