import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'residents.dart';
import 'blotter.dart';
import 'login.dart';
import 'document.dart';
import 'adminannouncement.dart';
import 'faq.dart';
import 'approvalscreen.dart';
import 'financialdashboard.dart';

class Admindashboard extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Admindashboard> {
  bool isAdmin =
      true; // Set this based on user role (true for admin, false for others)

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Barangay Management Portal - Admin",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, size: 35),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: _buildDrawer(),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/image/BackgroundMain.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    if (isAdmin) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAdminButton(context, "Manage Residents",
                              Icons.people, ResidentsScreen(), screenWidth),
                          SizedBox(
                              height: screenHeight * 0.02),
                          _buildAdminButton(context, "Blotter Reports",
                              Icons.report, BlotterReportScreen(), screenWidth),
                          SizedBox(height: screenHeight * 0.02),
                          _buildAdminButton(context, "Approval Screen",
                              Icons.approval, ApprovalScreen(), screenWidth),
                          SizedBox(height: screenHeight * 0.02),
                          _buildAdminButton(
                              context,
                              "Barangay Documents",
                              Icons.description,
                              DocumentsScreen(),
                              screenWidth),
                          SizedBox(height: screenHeight * 0.02),
                          _buildAdminButton(
                              context,
                              "Announcements",
                              Icons.announcement,
                              AdminAnnouncementScreen(),
                              screenWidth),
                          SizedBox(height: screenHeight * 0.02),
                          _buildAdminButton(
                              context,
                              "Financial Dashboard",
                              Icons.attach_money,
                              FinancialDashboard(),
                              screenWidth),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildAdminButton(BuildContext context, String label, IconData icon,
      Widget page, double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.7,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(12),
          minimumSize: Size(screenWidth * 0.6, 70),
        ),
        child: Row(
          children: [
            Icon(icon, size: 35),
            SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 20)),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(""),
            accountEmail: Text(""),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/image/BMISLogo.PNG'),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              image: DecorationImage(
                image: AssetImage("assets/image/BH.PNG"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text("FAQ"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Email Us"),
            onTap: () {
              _launchURL('mailto:masinnortebmis@gmail.com');
            },
          ),
          ListTile(
            leading: Icon(Icons.facebook),
            title: Text("Visit Facebook Page"),
            onTap: () {
              _launchURL('https://www.facebook.com/sangguniang.brgymasinnorte');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              _showLogoutConfirmationDialog();
            },
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
