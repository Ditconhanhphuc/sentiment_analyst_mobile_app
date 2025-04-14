import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SentimentApp());
}

class SentimentApp extends StatefulWidget {
  @override
  _SentimentAppState createState() => _SentimentAppState();
}

class _SentimentAppState extends State<SentimentApp> {
  TextEditingController _controller = TextEditingController();
  String _sentiment = 'Enter text and submit!';
  bool _isLoading = false;

  Future<void> analyzeSentiment() async {
    const String apiUrl = 'http://192.168.1.163:5001/analyze';  

    if (_controller.text.isEmpty) {
      setState(() {
        _sentiment = 'Please enter some text!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "text": _controller.text,
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String sentimentResult = "Neutral"; 

        // Assuming the API returns the sentiment directly
        if (data['sentiment'] != null) {
          sentimentResult = data['sentiment'];
        }

        setState(() {
          _sentiment = sentimentResult;
        });
      } else {
        setState(() {
          _sentiment = 'API Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _sentiment = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get sentiment icon based on result
  IconData getSentimentIcon() {
    if (_sentiment == 'Positive') return Icons.sentiment_satisfied_alt;
    if (_sentiment == 'Negative') return Icons.sentiment_very_dissatisfied;
    return Icons.sentiment_neutral;
  }

  // Get sentiment color
  Color getSentimentColor() {
    if (_sentiment == 'Positive') return Colors.green;
    if (_sentiment == 'Negative') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Sentiment Analysis')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your text',
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: analyzeSentiment,
                        child: Text('Submit'),
                      ),
                SizedBox(height: 20),
                Icon(
                  getSentimentIcon(),
                  size: 80,
                  color: getSentimentColor(),
                ),
                SizedBox(height: 10),
                Text(
                  _sentiment,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
