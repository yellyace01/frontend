import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq.dart';
import 'feedback.dart';
import 'login.dart';
import 'userannouncement.dart';
import 'requestdocument.dart';
import 'requestscreenstatus.dart';

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Barangay Management Portal",
          style: TextStyle(fontWeight: FontWeight.bold),
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
      endDrawer: _buildDrawer(context),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/PlainBG.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                // This allows vertical scrolling
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Center the content vertically
                  children: [
                    Text(
                      "Welcome to the Barangay User Dashboard",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center, // Center align the text
                    ),
                    SizedBox(height: 25),
                    _buildActionButton(context, "Announcements",
                        Icons.announcement, UserAnnouncementScreen()),
                    SizedBox(height: 25),
                    _buildActionButton(context, "Request Document",
                        Icons.document_scanner, RequestDocumentScreen()),
                    SizedBox(height: 25),
                    _buildActionButton(context, "Document Status",
                        Icons.document_scanner_outlined, AnnouncementScreen()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, Widget targetScreen) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(12),
          minimumSize: Size(260, 70),
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
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
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
            leading: Icon(Icons.feedback),
            title: Text("Feedback"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
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
            title: Text("Log Out"),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
