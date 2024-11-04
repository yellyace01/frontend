import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserAnnouncementScreen extends StatefulWidget {
  @override
  _UserAnnouncementScreenState createState() => _UserAnnouncementScreenState();
}

class _UserAnnouncementScreenState extends State<UserAnnouncementScreen> {
  List<Announcement> announcements = [];

  Future<void> _fetchAnnouncements() async {
    final response =
        await http.get(Uri.parse('https://backend-s4rm.onrender.com/announcements'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        announcements = data
            .map((item) => Announcement(
                  id: item['id'].toString(),
                  title: item['title'],
                  content: item['content'],
                  date: DateTime.parse(item['date']),
                ))
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch announcements')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Announcements'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/PlainBG.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ListTile(
                  title: Text(
                    announcements[index].title,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(announcements[index].content),
                  trailing: Text(
                    "${announcements[index].date.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  Announcement(
      {required this.id,
      required this.title,
      required this.content,
      required this.date});
}
