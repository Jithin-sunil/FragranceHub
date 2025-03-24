import 'package:admin/screen/category.dart';
import 'package:admin/screen/dashboard.dart';
import 'package:admin/screen/district.dart';
import 'package:admin/screen/new_shops.dart';
import 'package:admin/screen/place.dart';
import 'package:admin/screen/rejected_shops.dart';
import 'package:admin/screen/subcategory.dart';
import 'package:admin/screen/verified_shops.dart';
import 'package:admin/screen/viewcomplaint.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  List<String> pageName = [
    'Dashboard', 'District', 'Category', 'Place', 'Sub Category',
    'New Shops', 'Verified Shops', 'Rejected Shops',
    'Compalints'
  ];

  List<IconData> pageIcon = [
    Icons.dashboard_outlined, Icons.location_city_outlined, Icons.category_outlined,
    Icons.location_city, Icons.category_outlined, Icons.store_outlined, Icons.store_mall_directory_outlined,
    Icons.store_outlined,Icons.report_rounded, 
  ];

  List<Widget> pages = [
    Dashboard(), ManageDistrict(), ManageCategory(), ManagePlace(), 
    ManageSubCategory(), 
    ManageNewShop(), ManageVerifiedShop(), ManageRejectedShop(),ComplaintScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 108, 46, 255), Color.fromARGB(255, 28, 20, 44)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
      ),
      body: Row(
        children: [
          // Sidebar with modern styling
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 52, 51, 53), Color.fromARGB(255, 85, 76, 105)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Sidebar Menu
                  Expanded(
                    child: ListView.builder(
                      itemCount: pageName.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              leading: Icon(
                                pageIcon[index],
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                              title: Text(
                                pageName[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                              tileColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content Area with a soft card-like look
          Expanded(
            flex: 4,
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(31, 221, 208, 208),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
