import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user/main.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:user/screens/shopping/post_complaint.dart';
import 'package:user/screens/shopping/rating.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  final int cartId;

  const OrderDetailsPage({super.key, required this.orderId, required this.cartId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? orderDetails;
  Map<String, dynamic> orderItems = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final orderResponse = await supabase
          .from('tbl_booking')
          .select()
          .eq('id', widget.orderId)
          .single();

      final itemsResponse = await supabase
          .from('tbl_cart')
          .select('*, tbl_product(*)')
          .eq('id', widget.cartId)
          .single();

      Map<String, dynamic> items = {
        "id": itemsResponse['id'],
        "product_id": itemsResponse['product_id'],
        "name": itemsResponse['tbl_product']['product_name'],
        "image": itemsResponse['tbl_product']['product_image'],
        "price": itemsResponse['tbl_product']['product_price'],
        "quantity": itemsResponse['cart_qty'],
        "status": itemsResponse['cart_status'],
      };

      setState(() {
        orderDetails = orderResponse;
        orderItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getOrderStatusText(int status) {
    switch (status) {
      case 1:
        return 'Processing';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color getOrderStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Future<void> _generateAndDownloadBill() async {
  //   final pdf = pw.Document();
  //   final orderDate = DateTime.parse(orderDetails!['created_at']);
  //   final formattedDate = DateFormat('MMMM dd, yyyy').format(orderDate);
  //   final formattedTime = DateFormat('hh:mm a').format(orderDate);

  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) => pw.Column(
  //         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //         children: [
  //           pw.Text("FragranceHub Order Bill",
  //               style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  //           pw.SizedBox(height: 20),
  //           pw.Text("Order #${widget.orderId}", style: pw.TextStyle(fontSize: 18)),
  //           pw.Text("Date: $formattedDate at $formattedTime"),
  //           pw.Text("Status: ${getOrderStatusText(orderItems['status'])}"),
  //           pw.SizedBox(height: 20),
  //           pw.Text("Item Details",
  //               style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
  //           pw.Divider(),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text(orderItems['name']),
  //               pw.Text("Qty: ${orderItems['quantity']}"),
  //               pw.Text("₹${orderItems['price']}"),
  //             ],
  //           ),
  //           pw.Divider(),
  //           pw.SizedBox(height: 20),
  //           pw.Text("Total",
  //               style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text("Amount Paid"),
  //               pw.Text("₹${orderItems['price'] * orderItems['quantity']}"),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  //   final directory = await getExternalStorageDirectory();
  //   final file = File("${directory!.path}/Order_${widget.orderId}_Bill.pdf");
  //   await file.writeAsBytes(await pdf.save());
  //   OpenFile.open(file.path);

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Bill downloaded to ${file.path}")),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Order #${widget.orderId}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF9575CD)))
          : orderDetails == null
              ? Center(child: Text('Order not found', style: TextStyle(fontSize: 18, color: Colors.grey[700])))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderStatusCard(),
                      SizedBox(height: 16),
                      _buildOrderItemCard(),
                      SizedBox(height: 16),
                      _buildOrderSummaryCard(),
                      SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderStatusCard() {
  final orderDate = DateTime.parse(orderDetails!['created_at']);
  final formattedDate = DateFormat('MMMM dd, yyyy').format(orderDate);
  final formattedTime = DateFormat('hh:mm a').format(orderDate);

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getOrderStatusColor(orderItems['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getOrderStatusText(orderItems['status']),
                  style: TextStyle(
                    color: getOrderStatusColor(orderItems['status']),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Placed on: $formattedDate at $formattedTime',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusStep(
                  icon: Icons.shopping_cart,
                  title: 'Placed',
                  isActive: true,
                ),
                _buildConnector(isActive: orderItems['status'] >= 1),
                _buildStatusStep(
                  icon: Icons.build,
                  title: 'Processing',
                  isActive: orderItems['status'] >= 1,
                ),
                _buildConnector(isActive: orderItems['status'] >= 2),
                _buildStatusStep(
                  icon: Icons.local_shipping,
                  title: 'Shipped',
                  isActive: orderItems['status'] >= 2,
                ),
                _buildConnector(isActive: orderItems['status'] >= 3),
                _buildStatusStep(
                  icon: Icons.check_circle,
                  title: 'Delivered',
                  isActive: orderItems['status'] >= 3,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatusStep({
  required IconData icon,
  required String title,
  required bool isActive,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.green : Colors.grey,
        ),
      ),
      SizedBox(height: 8),
      Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.black87 : Colors.grey[600],
        ),
      ),
    ],
  );
}

Widget _buildConnector({required bool isActive}) {
  return Expanded(
    child: Container(
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? Colors.green : Colors.grey[300],
    ),
  );
}

  Widget _buildOrderItemCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                orderItems['image'],
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
                    orderItems['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Qty: ${orderItems['quantity']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${orderItems['price']}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9575CD)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text('₹${orderItems['price']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '₹${orderItems['price'] * orderItems['quantity']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9575CD)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (orderItems['status'] == 3)
              ElevatedButton.icon(
                icon: Icon(Icons.star_border, color: Colors.white),
                label: Text('Rate Product'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbackPage(pid: orderItems['product_id'])),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9575CD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            if (orderItems['status'] == 3) SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.support_agent, color: Color(0xFF9575CD)),
              label: Text('Post a Complaint', style: TextStyle(color: Color(0xFF9575CD))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintPage(id: orderItems['product_id'])),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF9575CD)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 12),
            
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(int status) {
    return Column(
      children: [
        _buildTimelineTile(
          isFirst: true,
          isActive: true,
          title: 'Order Placed',
          subtitle: 'Your order has been placed',
        ),
        _buildTimelineTile(
          isActive: status >= 1,
          title: 'Processing',
          subtitle: 'Your order is being processed',
        ),
        _buildTimelineTile(
          isActive: status >= 2,
          title: 'Shipped',
          subtitle: 'Your order has been shipped',
        ),
        _buildTimelineTile(
          isLast: true,
          isActive: status >= 3,
          title: 'Delivered',
          subtitle: 'Your order has been delivered',
        ),
      ],
    );
  }

  Widget _buildTimelineTile({
    required bool isActive,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 20,
        color: isActive ? Colors.green : Colors.grey[300]!,
        iconStyle: IconStyle(
          color: Colors.white,
          iconData: isActive ? Icons.check : Icons.circle,
          fontSize: 12,
        ),
      ),
      endChild: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black87 : Colors.grey[500],
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}