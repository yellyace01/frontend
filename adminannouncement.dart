import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });
}

class AdminAnnouncementScreen extends StatefulWidget {
  @override
  _AdminAnnouncementScreenState createState() =>
      _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _announcementTitle;
  String? _announcementContent;
  List<Announcement> announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    final response =
        await http.get(Uri.parse('https://backend-s4rm.onrender.com/announcements'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        announcements = data
            .map((announcement) => Announcement(
                  id: announcement['id'].toString(),
                  title: announcement['title'],
                  content: announcement['content'],
                  date: DateTime.parse(announcement['date']),
                ))
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load announcements')),
      );
    }
  }

  Future<void> _submitAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final response = await http.post(
        Uri.parse('https://backend-s4rm.onrender.com/announcements'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'title': _announcementTitle!,
          'content': _announcementContent!,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Announcement posted successfully')),
        );

        setState(() {
          announcements.add(Announcement(
            id: data['id'].toString(),
            title: _announcementTitle!,
            content: _announcementContent!,
            date: DateTime.now(),
          ));
        });

        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post announcement')),
        );
      }
    }
  }

  Future<void> _deleteAnnouncement(int index) async {
    final announcementId = announcements[index].id;
    final response = await http.delete(
      Uri.parse('https://backend-s4rm.onrender.com/announcements/$announcementId'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Announcement deleted successfully')),
      );

      setState(() {
        announcements.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete announcement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Announcement'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/PlainBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Announcement Title',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _announcementTitle = value;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Announcement Content',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter content';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _announcementContent = value;
                        },
                        maxLines: 5,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton(
                        onPressed: _submitAnnouncement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Post Announcement'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Posted Announcements:',
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          announcements[index].title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(announcements[index].content),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${announcements[index].date.toLocal()}"
                                  .split(' ')[0],
                              style:
                                  TextStyle(fontSize: 12.0, color: Colors.grey),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete this announcement?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          _deleteAnnouncement(index);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('No'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
