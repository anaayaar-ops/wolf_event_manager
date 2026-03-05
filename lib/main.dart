import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:intl/intl.dart';

// استقبال البيانات السرية من GitHub Secrets أثناء البناء
const String uMail = String.fromEnvironment('EMAIL');
const String uPass = String.fromEnvironment('PASSWORD');

void main() => runApp(WolfDirectApp());

class WolfDirectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D3D33),
      ),
      home: WolfWSNavigator(),
    );
  }
}

class EventItem {
  final String id;
  final String name;
  TimeOfDay time;
  final int duration;
  bool isSelected;

  EventItem({
    required this.id, 
    required this.name, 
    required this.time, 
    required this.duration, 
    this.isSelected = true
  });
}

class WolfWSNavigator extends StatefulWidget {
  @override
  _WolfWSNavigatorState createState() => _WolfWSNavigatorState();
}

class _WolfWSNavigatorState extends State<WolfWSNavigator> {
  final TextEditingController roomController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  List<EventItem> events = [];
  bool isLoading = false;
  IOWebSocketChannel? channel;

  // القائمة من بوت الـ JS الخاص بك
  final List<String> eventNames = [
    "سوالف وافكار", "تحديات", "ساعة تسلية", "شغّل عقلك", "سوالف ونقاشات", "لعب وطرب", 
    "خمن الرقم", "سوالف صباحيه", "تحديات خليجنا ذوق", "تحديات ذهنية", "تحدي التخمين", 
    "صباحيات خليجنا ذوق", "تصادمات رقمية", "جيبها بالثانيه", "سوالف والعاب", "تحدي سهم",
    "فـ الصحيح", "رتب الحروف", "جلسات حوارية", "منوعات", "تحدي كرة", "سوالف خليجنا ذوق",
    "تحديات منوعة", "تحديات رقمية", "ساعه نقاش", "فقرات منوعة", "أرقام الحظ", "تحدي الزمن",
    "سوالف ليل", "تحدي الأرقام", "تحديات بوتات", "صناديق الحظ"
  ];

  void connectAndFetch() {
    if (roomController.text.isEmpty || dateController.text.isEmpty) return;

    setState(() => isLoading = true);
    
    try {
      channel = IOWebSocketChannel.connect('wss://v3.palringo.com:443');

      // تسجيل الدخول بالبيانات السرية
      var loginPayload = {
        "headers": {"version": 3},
        "body": {
          "onlineState": 1,
          "username": uMail,
          "password": uPass
        },
        "type": "security login"
      };
      channel!.sink.add(jsonEncode(loginPayload));

      channel!.stream.listen((message) {
        var response = jsonDecode(message);
        
        if (response['type'] == 'security login success' || response['type'] == 'welcome') {
          _requestEvents();
        }

        if (response['type'] == 'group event list') {
          _processEvents(response['body']);
        }
      }, onError: (err) {
        setState(() => isLoading = false);
        _showError("خطأ في الاتصال");
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _requestEvents() {
    var eventRequest = {
      "body": {
        "id": int.parse(roomController.text),
        "languageId": 1,
        "subscribe": true
      },
      "type": "group event list"
    };
    channel!.sink.add(jsonEncode(eventRequest));
  }

  void _processEvents(List data) {
    List<EventItem> fetchedEvents = [];
    String targetDate = dateController.text;

    for (var i = 0; i < data.length; i++) {
      var ev = data[i];
      var startTimeStr = ev['startsAt'];
      var endTimeStr = ev['endsAt'];
      
      // توقيت السعودية UTC+3
      DateTime startTime = DateTime.parse(startTimeStr).toUtc().add(Duration(hours: 3));
      DateTime endTime = DateTime.parse(endTimeStr).toUtc().add(Duration(hours: 3));

      String dateStr = DateFormat('yyyy-MM-dd').format(startTime);

      if (dateStr == targetDate) {
        int duration = endTime.difference(startTime).inMinutes;
        
        fetchedEvents.add(EventItem(
          id: ev['id'].toString(),
          name: i < eventNames.length ? eventNames[i] : "فعالية إضافية",
          time: TimeOfDay(hour: startTime.hour, minute: startTime.minute),
          duration: duration,
        ));
      }
    }

    setState(() {
      events = fetchedEvents;
      isLoading = false;
      channel?.sink.close();
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildEventList()),
            if (events.isNotEmpty) _buildFooterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: roomController, decoration: InputDecoration(labelText: "رقم الروم", border: OutlineInputBorder()))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: dateController, decoration: InputDecoration(labelText: "YYYY-MM-DD", border: OutlineInputBorder()))),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: isLoading ? null : connectAndFetch,
            child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text("اتصال وجلب الفعاليات"),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
          )
        ],
      ),
    );
  }

  Widget _buildEventList() {
    if (events.isEmpty && !isLoading) return Center(child: Text("أدخل البيانات واضغط جلب"));
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(events[index].name),
          subtitle: Text("ID: ${events[index].id} | وقت: ${events[index].time.format(context)}"),
          value: events[index].isSelected,
          onChanged: (v) => setState(() => events[index].isSelected = v!),
        );
      },
    );
  }

  Widget _buildFooterButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: _showSummary,
        child: Text("تأكيد ونسخ المستند"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: Size(double.infinity, 50)),
      ),
    );
  }

  void _showSummary() {
    String summary = "تقرير فعاليات الروم: ${roomController.text}\nالتاريخ: ${dateController.text}\n";
    summary += "-------------------\n";
    for (var e in events.where((element) => element.isSelected)) {
      summary += "ID: ${e.id} | ${e.name} | الوقت: ${e.time.format(context)}\n";
    }
    showDialog(context: context, builder: (context) => AlertDialog(title: Text("المستند"), content: SelectableText(summary), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("إغلاق"))]));
  }
}
