import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class DocumentsScreen extends StatefulWidget {
  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Document> documents = [
    Document(title: "Barangay Clearance", type: "Certificate", size: "1MB"),
    Document(
        title: "Certificate of Indigency", type: "Certificate", size: "1MB"),
    Document(
        title: "Certificate of Residency", type: "Certificate", size: "1MB"),
    Document(title: "Business Permit", type: "Certificate", size: "2MB"),
    Document(title: "Cedula", type: "ID", size: "500KB"),
  ];

  String selectedType = "All";
  String selectedPurok = "Purok 1";
  List<String> purokList = [
    "Purok 1",
    "Purok 2",
    "Purok 3",
    "Purok 4",
    "Purok 5",
    "Purok 6"
  ];

  @override
  Widget build(BuildContext context) {
    List<Document> filteredDocuments = documents.where((doc) {
      if (selectedType == "All") return true;
      return doc.type == selectedType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Barangay Documents"),
        actions: [
          DropdownButton<String>(
            value: selectedType,
            items: <String>["All", "Certificate", "ID"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedType = newValue!;
              });
            },
          ),
        ],
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
        child: ListView.builder(
          itemCount: filteredDocuments.length,
          itemBuilder: (context, index) {
            return DocumentTile(
              document: filteredDocuments[index],
              purokList: purokList,
            );
          },
        ),
      ),
    );
  }
}

class Document {
  final String title;
  final String type;
  final String size;

  Document({required this.title, required this.type, required this.size});
}

class DocumentTile extends StatelessWidget {
  final Document document;
  final List<String> purokList;

  DocumentTile({required this.document, required this.purokList});

  @override
  Widget build(BuildContext context) {
    String selectedPurok = purokList.first;
    String userName = "";

    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5,
      child: ListTile(
        title: Text(
          document.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Type: ${document.type}, Size: ${document.size}"),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Request ${document.title}"),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Select your purok:"),
                        DropdownButton<String>(
                          value: selectedPurok,
                          items: purokList.map((String purok) {
                            return DropdownMenuItem<String>(
                              value: purok,
                              child: Text(purok),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedPurok = newValue;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        Text("Enter your name:"),
                        TextField(
                          onChanged: (value) {
                            userName = value;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(getDocumentDescription(document.title)),
                      ],
                    );
                  },
                ),
                actions: [
                  ElevatedButton(
                    child: Text("Print"),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async {
                        return await createPdf(
                            document.title, selectedPurok, userName);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Printing ${document.title}")),
                      );
                    },
                  ),
                  TextButton(
                    child: Text("Back to Menu"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String getDocumentDescription(String title) {
    switch (title) {
      case "Barangay Clearance":
        return "This document certifies that the individual has no pending cases or issues in the barangay.";
      case "Certificate of Indigency":
        return "The certificate of indigency is issued to citizens in need of government assistance.";
      case "Certificate of Residency":
        return "This certifies that the holder is a resident of Barangay Masin Norte.";
      case "Business Permit":
        return "This document serves as a permit issued by the barangay for businesses.";
      case "Cedula":
        return "This is an identification card issued by the barangay.";
      default:
        return "No information available.";
    }
  }

  Future<Uint8List> createPdf(
      String title, String purok, String userName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                    "This is to certify that the holder of this document, $userName, is eligible for $title."),
                pw.SizedBox(height: 20),
                pw.Text("Purok: $purok"),
                pw.SizedBox(height: 20),
                pw.Text("Signed by Kapitan Nelson \"Pekok\" Punzalan"),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
