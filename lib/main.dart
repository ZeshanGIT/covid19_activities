import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid19_activities/update_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

const size32box = SizedBox(height: 32);
var size16box = SizedBox(height: 16);
Widget banner = Image.asset(
  'assets/banner.jpg',
  height: 96,
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (_) => Home(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.ubuntuTextTheme(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin {
  int current = 0;

  PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: buildBottomNavigationBar(),
      body: SafeArea(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _controller,
          children: [
            Updates(),
            AacademicUpdates(),
            Guidlines(),
            SelfCheck(),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (i) {
        _controller.animateToPage(i,
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        setState(() => current = i);
      },
      selectedItemColor: Colors.deepPurple,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      currentIndex: current,
      items: [
        BottomNavigationBarItem(
          icon: Text(
            '📰',
            style: TextStyle(fontSize: 32),
          ),
          title: Text('Updates'),
        ),
        BottomNavigationBarItem(
          icon: Text(
            '🎓',
            style: TextStyle(fontSize: 32),
          ),
          title: Text('Academic Updates'),
        ),
        BottomNavigationBarItem(
          icon: Text(
            '👨🏻‍⚕️',
            style: TextStyle(fontSize: 32),
          ),
          title: Text('Guidlines'),
        ),
        BottomNavigationBarItem(
          icon: Text(
            '😷',
            style: TextStyle(fontSize: 32),
          ),
          title: Text('Self Check'),
        ),
      ],
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {}
}

class SelfCheck extends StatefulWidget {
  const SelfCheck({
    Key key,
  }) : super(key: key);

  @override
  _SelfCheckState createState() => _SelfCheckState();
}

class _SelfCheckState extends State<SelfCheck> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: edge32Insets,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            banner,
            size16box,
            Text('Selft Assessment', style: titleTextStyle),
            size32box,
            UpdateCard(
              cardColor: Colors.teal,
              textColor: Colors.teal.shade800,
              webPage: WebPage(
                'https://www.cuchd.in/covid19-self-assessment/#q0',
                js: "\$('.cu-covid19-main-header').remove();\$('.cu-covid19-breadcrumbs').remove();",
              ),
              title: 'Start Self Assessment',
              source: 'Chandigarh University',
            ),
            size16box,
            Container(
              width: double.maxFinite,
              padding: edge16Insets,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                'Wash your hands every 2 hours',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Guidlines extends StatelessWidget {
  const Guidlines({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: edge32Insets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          banner,
          size16box,
          Text('Guidlines', style: titleTextStyle),
          size32box,
          GuidlinesCard(
            cardColor: Colors.deepPurple,
            textColor: Colors.deepPurple.shade800,
            title: 'Lockdown Guidlines',
            source: 'Ministry of Home Affairs',
            pdf: 'lockdownGuidlines',
          ),
          size16box,
          GuidlinesCard(
            cardColor: Colors.amber,
            textColor: Colors.amber.shade800,
            title: 'COVID 19 - Guidlines',
            source: 'World Health Organization',
            pdf: 'covidGuidlines',
          ),
          size16box,
        ],
      ),
    );
  }
}

class AacademicUpdates extends StatelessWidget {
  const AacademicUpdates({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UpdateCollection().getUpdates(),
      initialData: [],
      builder: (_, ass) => Container(
        padding: edge32Insets,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              banner,
              size16box,
              Text(
                'Academic Updates',
                style: titleTextStyle,
              ),
              size32box,
              ...((ass.data == null || ass.data.isEmpty)
                  ? buildCircularProgressIndicator(ass.data)
                  : ass.data.map((e) => AcademicUpdateCard(e)).toList()),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildCircularProgressIndicator(k) {
    print(k);
    return [CircularProgressIndicator()];
  }
}

class GuidlinesCard extends StatelessWidget {
  const GuidlinesCard({
    @required this.title,
    @required this.pdf,
    @required this.source,
    @required this.cardColor,
    @required this.textColor,
    Key key,
  }) : super(key: key);

  final String pdf, title, source;
  final Color cardColor, textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuidlinesPdf(pdf),
          ),
        );
      },
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            size32box,
            Text(
              'Source : $source',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicUpdateCard extends StatelessWidget {
  const AcademicUpdateCard(
    this.map, {
    Key key,
  }) : super(key: key);

  final Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) {
    DateTime t = (map['date'] as Timestamp).toDate();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: edge16Insets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Text(
                    map['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Share.share(
                          '*${map['title']}*\n${map['desc']}\n\n${(map['links'] as List).map((e) => '$e\n').toList().toString().replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('[', '').replaceAll(']', '')}\nDowload the app for more updates\nhttps://play.google.com/store/apps/details?id=edu.sastra.covid19_activities');
                    },
                    child: Icon(Icons.share),
                  ),
                ],
              ),
              size16box,
              if (map['desc'] != null)
                Text(
                  map['desc'],
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              size16box,
              if (map['links'] != null)
                ...(map['links'] as List)
                    .map(
                      (e) => GestureDetector(
                        onTap: () {
                          _launchURL(e);
                        },
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue.shade800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              size16box,
              Text(
                '${t.day}/${t.month}/${t.year}\t${t.hour} : ${t.minute}',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class Updates extends StatelessWidget {
  const Updates({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: edge32Insets,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            banner,
            size16box,
            Text(
              'COVID19 - Updates',
              style: titleTextStyle,
            ),
            size32box,
            UpdateCard(
              cardColor: Colors.blue,
              textColor: Colors.blue.shade800,
              title: 'National Update 🇮🇳',
              webPage: WebPage(
                'https://www.mohfw.gov.in/dashboard/index.php',
                js: "\$('.header-top').remove()",
              ),
              source:
                  'Ministry of Health and Family Welfare,\nGovernment of India',
            ),
            size32box,
            UpdateCard(
              cardColor: Colors.green,
              textColor: Colors.green.shade800,
              title: 'Global Update 🌍',
              webPage: WebPage(
                'https://www.bing.com/covid',
              ),
              source: 'Microsoft',
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateCard extends StatelessWidget {
  const UpdateCard({
    @required this.webPage,
    @required this.title,
    @required this.source,
    @required this.cardColor,
    @required this.textColor,
    Key key,
  }) : super(key: key);
  final WebPage webPage;
  final String title, source;
  final Color cardColor, textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MyWebView(webPage),
          ),
        );
      },
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            size32box,
            Text(
              'Source : $source',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class WebPage {
  String url, js;
  WebPage(this.url, {this.js});
}

class MyWebView extends StatelessWidget {
  final WebPage webPage;

  MyWebView(
    this.webPage, {
    Key key,
  }) : super(key: key);

  WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          onWebViewCreated: (controller) => webViewController = controller,
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: webPage.url,
          onPageFinished: (k) {
            webViewController.evaluateJavascript(webPage.js ?? '');
          },
        ),
      ),
    );
  }
}

class GuidlinesPdf extends StatefulWidget {
  final String pdf;
  GuidlinesPdf(this.pdf);

  @override
  _GuidlinesPdfState createState() => _GuidlinesPdfState();
}

class _GuidlinesPdfState extends State<GuidlinesPdf> with AfterLayoutMixin {
  String path;

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    Directory directory = await getApplicationDocumentsDirectory();
    var dbPath = directory.path + "/${widget.pdf}.pdf";
    ByteData data = await rootBundle.load("assets/${widget.pdf}.pdf");
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    path = (await File(dbPath).writeAsBytes(bytes)).path;
    setState(() {
      path = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return path == null ? Container() : PDFViewerScaffold(path: path);
  }
}

const titleTextStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Color(0xFF3D2B9B),
);

const edge32Insets = const EdgeInsets.all(32);
const edge16Insets = const EdgeInsets.all(16);
