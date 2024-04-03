import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController _textController = TextEditingController();
  List<ChatMessage> _messages = [];

  Future<void> simsimiApiRequest(String text) async {
    // URL API
    final String apiUrl = 'https://api.simsimi.vn/v1/simtalk';

    // Header dan data yang akan dikirim
    final Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final Map<String, String> data = {'text': text, 'lc': 'id', 'key': ''}; // Ganti dengan kunci yang sesuai

    try {
      // Melakukan permintaan POST ke API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: data,
      );

      // Memeriksa status kode respons
      if (response.statusCode == 200) {
        // Sukses, Anda dapat menangani data respons di sini
        final message = _extractMessageFromApiResponse(response.body);
        _addMessage(message, false);
      } else {
        // Gagal, tampilkan pesan atau lakukan tindakan yang sesuai
        _addMessage('Error: ${response.statusCode}, ${response.reasonPhrase}', false);
      }
    } catch (error) {
      // Menangani kesalahan jaringan atau kesalahan lainnya
      _addMessage('Error: $error', false);
    }

  }

  void _handleSubmitted(String text) {
    _textController.clear();

    // Tambahkan pesan pengguna ke daftar pesan
    _addMessage(text, true);

    // Kirim permintaan API dan tambahkan responnya ke daftar pesan
    simsimiApiRequest(text);
  }

  void _addMessage(String text, bool isUser) {
    // Tambahkan pesan ke daftar pesan
    ChatMessage message = ChatMessage(
      text: text,
      isUser: isUser,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        centerTitle: true,
        title: Text('Simi Peller'),
      ),
      body: Column(
        children: <Widget>[
          // Kotak pesan
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) => _messages[index],
              ),
            ),
          ),
          // TextBox untuk mengisi pesan pengguna
          Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _handleSubmitted,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _extractMessageFromApiResponse(String responseBody) {
  final json = Map<String, dynamic>.from(jsonDecode(responseBody));
  return json['message'] ?? 'No message found';
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          // Kotak pesan
          Container(
            padding: EdgeInsets.all(10.0),
            constraints: BoxConstraints(maxWidth: 200.0), // Atur lebar maksimal
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.yellow.shade900,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Wrap(
              children: [
                Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

