import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/main.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:shop/product_details.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final volumeController = TextEditingController();
  final scentNotesController = TextEditingController();
  final imageController = TextEditingController();
  PlatformFile? pickedImage;

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        imageController.text = result.files.first.name;
      });
    }
  }

  Future<String?> photoUpload() async {
    try {
      final bucketName = 'fragrance'; // Replace with your bucket name
      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!,
          );
      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  List<Map<String, dynamic>> _products = [];
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchesSearch = product['product_name']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;
  String? selectedSubcategory;

  Future<void> fetchProducts() async {
    try {
      final response = await supabase.from('tbl_product').select("*, tbl_subcategory(*,tbl_category(*))");
      setState(() {
        _products = response;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> insert() async {
    try {
      String? url = await photoUpload();
      await supabase.from("tbl_product").insert({
        'product_name': nameController.text,
        'subcategory_id': selectedSubcategory,
        'product_description': descController.text,
        'product_price': priceController.text,
        'volume': volumeController.text,
        'scent_notes': scentNotesController.text,
        'product_image': url,
      });
      nameController.clear();
      descController.clear();
      priceController.clear();
      volumeController.clear();
      scentNotesController.clear();
      imageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product Added")));
      Navigator.pop(context);
    } catch (e) {
      print("Error Inserting Product: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from("tbl_category").select();
      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching Categories: $e");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await supabase.from("tbl_product").delete().eq('product_id', id);
      fetchProducts();
    } catch (e) {
      print("Error deleting product: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 230, 230),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fragrance Management",
                  style: GoogleFonts.sanchez(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddProductDialog(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text("Add Fragrance"),
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
            SizedBox(height: 20),
            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search fragrances...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Products Grid
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        "No fragrances found",
                        style: GoogleFonts.sanchez(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
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
            Expanded(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  image: DecorationImage(
                    image: NetworkImage(product['product_image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['product_name'],
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${product['volume']} ml',
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '\$${product['product_price'].toStringAsFixed(2)}',
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 204, 204),
                    ),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      deleteProduct(product['product_id'].toString());
                    },
                    icon: Icon(Icons.delete, size: 16),
                    label: Text("Delete"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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

  void _showAddProductDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    List<Map<String, dynamic>> subcategories = [];

    Future<void> fetchSubcategories(String categoryId, Function setState) async {
      try {
        final response = await supabase
            .from("tbl_subcategory")
            .select()
            .eq('category_id', categoryId);
        setState(() {
          subcategories = response;
        });
      } catch (e) {
        print("Error fetching Subcategories: $e");
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Fragrance"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Fragrance Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter fragrance name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Product Description Field
                    TextFormField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Price Field
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: "Price (\$)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Volume Field
                    TextFormField(
                      controller: volumeController,
                      decoration: InputDecoration(
                        labelText: "Volume (ml)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter volume';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Scent Notes Field
                    TextFormField(
                      controller: scentNotesController,
                      decoration: InputDecoration(
                        labelText: "Scent Notes",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter scent notes';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      hint: Text("Select Category"),
                      items: categories.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['id'].toString(),
                          child: Text(data['category_name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                          selectedSubcategory = null;
                          subcategories.clear();
                        });
                        fetchSubcategories(newValue!, setState);
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Subcategory Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedSubcategory,
                      hint: Text("Select Subcategory"),
                      items: subcategories.map((data) {
                        return DropdownMenuItem<String>(
                          value: data['id'].toString(),
                          child: Text(data['subcategory_name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubcategory = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Subcategory',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Image Picker Field
                    TextFormField(
                      onTap: handleImagePick,
                      controller: imageController,
                      decoration: InputDecoration(
                        labelText: "Image",
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an image';
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          // Add Product Button
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                insert(); // Insert logic
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 255, 204, 204),
              foregroundColor: Colors.white,
            ),
            child: Text("Add Fragrance"),
          ),
        ],
      ),
    );
  }
}