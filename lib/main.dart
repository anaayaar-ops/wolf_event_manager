import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(WolfApp());

class WolfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D3D33), // لون الخلفية من صورتك
      ),
      home: EventScreen(),
    );
  }
}

class EventItem {
  String id;
  String time;
  bool isSelected;
  EventItem({required this.id, required this.time, this.isSelected = true});
}

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final String roomID = "9969";
  final String date = "12/3/2026";

  // قائمة الفعاليات بناءً على الصورة التي أرفقتها
  List<EventItem> events = [
    EventItem(id: "753729", time: "12:00 ص"),
    EventItem(id: "753730", time: "12:45 ص"),
    EventItem(id: "753731", time: "1:30 ص"),
    EventItem(id: "753732", time: "2:15 ص"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر: عضوية الروم والتاريخ
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _headerColumn("عضوية الروم", roomID),
                  _headerColumn("التاريخ", date),
                ],
              ),
            ),
            // قائمة الفعاليات
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.teal,
                      value: events[index].isSelected,
                      onChanged: (val) => setState(() => events[index].isSelected = val!),
                    ),
                    title: Row(
                      children: [
                        Text("${events[index].id} تبدأ ", style: TextStyle(fontSize: 18)),
                        InkWell(
                          onTap: () async {
                            // هنا يمكنك مستقبلاً إضافة Picker للوقت
                          },
                          child: Text(events[index].time, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // زر الإنهاء
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal),
                onPressed: () => _launchURL(),
                child: Text("إنهاء وتعبئة البيانات", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.white70)),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _launchURL() async {
    var selected = events.where((e) => e.isSelected).map((e) => "${e.id}@${e.time}").join(",");
    final Uri url = Uri.parse("https://google.com/search?q=room=$roomID&data=$selected"); // استبدل بالرابط الفعلي لاحقاً
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }
}
