import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();

  Future<void> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/chatbot/gen_response/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': message}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        setState(() {
          _responseController.text = responseData['response'];
        });
      } else {
        print('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미아에게 마음을 터 놓으세요.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 10,

              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Enter your message',
                border: OutlineInputBorder(),
                
              ),
              textInputAction: TextInputAction.go,
              
              onSubmitted: (text) {
                _inputController.text = '$text\n';
                sendMessage(text);
              },
            ),
            const SizedBox(height: 60),
            TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                labelText: 'Chatbot Response',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
