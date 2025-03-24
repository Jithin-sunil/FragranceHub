import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/main.dart';
import 'package:file_picker/file_picker.dart';

class ShopProfilePage extends StatefulWidget {
  const ShopProfilePage({super.key});

  @override
  State<ShopProfilePage> createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<ShopProfilePage> {
  Map<String, dynamic>? shopDetails;
  bool isLoading = true;
  PlatformFile? pickedLogo;

  Future<void> fetchShopDetails() async {
    try {
      final userid=supabase.auth.currentUser!.id;
      final response = await supabase.from('tbl_shop').select().eq('shop_id', userid).single();
      setState(() {
        shopDetails = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching shop details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateShopDetails(String field, dynamic value) async {
    try {
      await supabase.from('tbl_shop').update({field: value});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Shop details updated")));
      fetchShopDetails(); // Refresh data
    } catch (e) {
      print("Error updating shop details: $e");
    }
  }

  Future<String?> uploadLogo() async {
    try {
      final bucketName = 'shop_images'; // Replace with your bucket name
      String formattedDate = DateTime.now().toString().replaceAll(RegExp(r'[^\w\s]'), '');
      final filePath = "$formattedDate-${pickedLogo!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedLogo!.bytes!,
          );
      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error uploading logo: $e");
      return null;
    }
  }

  Future<void> handleLogoPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        pickedLogo = result.files.first;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchShopDetails();
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
          "Shop Profile",
          style: GoogleFonts.sanchez(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              _showEditDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Shop Details",
              style: GoogleFonts.sanchez(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Shop Information
            Expanded(
              child: Container(
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
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 255, 204, 204),
                        ),
                      )
                    : shopDetails == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "No shop details found",
                                  style: GoogleFonts.sanchez(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Shop Logo
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showEditDialog(context);
                                    },
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey.shade300, width: 2),
                                        image: DecorationImage(
                                          image: shopDetails!['shop_logo'] != null
                                              ? NetworkImage(shopDetails!['shop_logo'])
                                              : AssetImage('assets/placeholder_logo.png') as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: shopDetails!['shop_logo'] == null
                                          ? Center(
                                              child: Icon(
                                                Icons.add_a_photo,
                                                size: 40,
                                                color: Colors.grey[400],
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Shop Name
                              Row(
                                children: [
                                  Icon(Icons.storefront, size: 24, color: Colors.grey[600]),
                                  SizedBox(width: 10),
                                  Text(
                                    shopDetails!['shop_name'],
                                    style: GoogleFonts.sanchez(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Shop Description
                              Text(
                                "Description:",
                                style: GoogleFonts.sanchez(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                shopDetails!['shop_description'] ?? "No description available",
                                style: GoogleFonts.sanchez(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Popular Scents
                              Text(
                                "Popular Scents:",
                                style: GoogleFonts.sanchez(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                shopDetails!['popular_scents'] ?? "Not specified",
                                style: GoogleFonts.sanchez(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Contact Information
                              Text(
                                "Contact Information:",
                                style: GoogleFonts.sanchez(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 5),
                                  Text(
                                    shopDetails!['shop_contact'] ?? "Not provided",
                                    style: GoogleFonts.sanchez(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      shopDetails!['shop_email'] ?? "Not provided",
                                      style: GoogleFonts.sanchez(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController(text: shopDetails?['shop_name']);
    final TextEditingController _descController = TextEditingController(text: shopDetails?['shop_description']);
    final TextEditingController _scentsController = TextEditingController(text: shopDetails?['popular_scents']);
    final TextEditingController _contactController = TextEditingController(text: shopDetails?['shop_contact']);
    final TextEditingController _emailController = TextEditingController(text: shopDetails?['shop_email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit Shop Details",
          style: GoogleFonts.sanchez(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Shop Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Shop Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _scentsController,
                decoration: InputDecoration(
                  labelText: "Popular Scents",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: handleLogoPick,
                icon: Icon(Icons.upload),
                label: Text("Upload Logo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 204, 204),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
            onPressed: () async {
              if (pickedLogo != null) {
                String? logoUrl = await uploadLogo();
                if (logoUrl != null) {
                  updateShopDetails('shop_logo', logoUrl);
                }
              }
              updateShopDetails('shop_name', _nameController.text);
              updateShopDetails('shop_description', _descController.text);
              updateShopDetails('popular_scents', _scentsController.text);
              updateShopDetails('shop_contact', _contactController.text);
              updateShopDetails('shop_email', _emailController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 255, 204, 204),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Save",
              style: GoogleFonts.sanchez(),
            ),
          ),
        ],
      ),
    );
  }
}