import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> faqs = [
    {
      "question": "How to request documents?",
      "answer":
          "You can request documents by visiting the barangay office or submitting a request online."
    },
    {
      "question": "How to provide feedback?",
      "answer":
          "You can provide feedback through the feedback section in the app."
    },
    {
      "question": "What are the requirements for a barangay clearance?",
      "answer":
          "You need to provide valid ID and fill out the application form."
    },
    {
      "question": "How to contact the barangay office?",
      "answer":
          "You can contact the barangay office via phone or email, listed on our official website."
    },
    {
      "question": "What services are available in the barangay?",
      "answer":
          "Services include health services, permits, and community programs."
    },
  ];

  final List<String> messages = [];
  final TextEditingController controller = TextEditingController();

  void _sendMessage() {
    final userMessage = controller.text;
    if (userMessage.isNotEmpty) {
      setState(() {
        messages.add("You: $userMessage");
        controller.clear();
        String response = _getResponse(userMessage);
        messages.add("Bot: $response");
      });
    }
  }

  String _getResponse(String userMessage) {
    for (var faq in faqs) {
      if (userMessage.toLowerCase().contains(faq['question']!.toLowerCase())) {
        return faq['answer']!;
      }
    }
    return "I'm sorry, I don't understand your question.";
  }

  void _clearChat() {
    setState(() {
      messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ChatBot FAQ")),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/PlainBG.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Add this
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  shrinkWrap: true, // Use shrinkWrap to avoid size issues
                  physics:
                      NeverScrollableScrollPhysics(), // Disable scrolling for this list
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(faqs[index]['question']!),
                        onTap: () {
                          setState(() {
                            messages.add("Bot: ${faqs[index]['answer']!}");
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: "Type your question...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
              Divider(),
              ElevatedButton(
                onPressed: _clearChat,
                child: Text("Clear Chat"),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
