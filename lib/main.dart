import 'package:flutter/material.dart';

void main() => runApp(WolfParserApp());

class WolfParserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: EventParserScreen(),
    );
  }
}

class EventParserScreen extends StatefulWidget {
  @override
  _EventParserScreenState createState() => _EventParserScreenState();
}

class _EventParserScreenState extends State<EventParserScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _parsedEvents = [];

  // دالة تحليل النص المستخرج من JS
  void _parseData() {
    final text = _controller.text;
    final List<Map<String, String>> events = [];
    
    // تقسيم النص بناءً على الـ ID لأنه الفاصل بين الفعاليات
    final RegExp regExp = RegExp(
      r"【\s*(.*?)\s*】.*?وقت البداية:\s*(.*?)\s*\n.*?مدة الفعالية:\s*(.*?)\s*\n.*?ID:\s*(\d+)",
      dotAll: true,
    );

    final matches = regExp.allMatches(text);

    for (var match in matches) {
      events.add({
        'name': match.group(1) ?? 'بدون اسم',
        'time': match.group(2) ?? '',
        'duration': match.group(3) ?? '',
        'id': match.group(4) ?? '',
      });
    }

    setState(() {
      _parsedEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('محلل فعاليات WOLF')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'أصق مخرجات الـ JS هنا...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _parseData,
              child: Text('تقسيم وعرض البيانات'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _parsedEvents.length,
                itemBuilder: (context, index) {
                  final ev = _parsedEvents[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(ev['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('⏰ ${ev['time']} | ⏳ ${ev['duration']}'),
                      trailing: Text('ID: ${ev['id']}', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
