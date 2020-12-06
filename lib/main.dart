import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid19_activities/id_collection.dart';
import 'package:covid19_activities/update_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:device_id/device_id.dart';

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

class _HomeState extends State<Home> {
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
      selectedItemColor: const Color(0xFF3D2B9B),
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
  void initState() {
    super.initState();
  }

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
            FutureBuilder(
              future: DeviceId.getID,
              builder: (_, ass) => ass.hasData
                  ? StreamBuilder<bool>(
                      stream: IdCollection(ass.data).hasId,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data)
                            return Container(
                              width: double.maxFinite,
                              padding: edge16Insets,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'You have already agreed to the agreements',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => SelfCheckAgreements(),
                              ));
                            },
                            child: Container(
                              width: double.maxFinite,
                              padding: edge16Insets,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Self Declaration by students',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          );
                        } else
                          return CircularProgressIndicator();
                      })
                  : Container(
                      width: double.maxFinite,
                      padding: edge16Insets,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
            ),
            size16box,
            StreamBuilder(
              stream:
                  Firestore.instance.document('count/count').snapshots().map(
                        (e) => (e.data['count'] as int),
                      ),
              builder: (_, ass) => ass.data != null
                  ? Text(
                      '${ass.data.toString()} people have agreed to this',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}

class SelfCheckAgreements extends StatefulWidget {
  @override
  _SelfCheckAgreementsState createState() => _SelfCheckAgreementsState();
}

class _SelfCheckAgreementsState extends State<SelfCheckAgreements> {
  PageController _controller = PageController();

  bool uploading = false;

  iWill() async {
    if (_controller.page.floor() == 4) {
      setState(() {
        uploading = true;
      });
      String id = await DeviceId.getID;
      await IdCollection(id).addId();
      Navigator.of(context).pop();
    } else
      _controller.nextPage(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
  }

//   Self Declaration by students

// 1. I agree to maintain social distancing during my travel and after reaching the campus
// 2. When I left home I did not have any symptoms of Covid 19 including (but are not limited to) fever, cough, sore throat, fatigue and shortness of breath.
// 3. I agree to wash the hands for 20 seconds periodically
// 4. I have with me a pair of reusable face masks, which I will be using during my stay at University campus without fail
// 5. I have enough stock of Handwash/Sanitizer for one month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _controller,
            children: <Widget>[
              Agreement(
                iWill: iWill,
                title:
                    'I agree to maintain social distancing during my travel and after reaching the campus',
                img: 'sd',
              ),
              Agreement(
                iWill: iWill,
                title:
                    'When I left home I did not have any symptoms of Covid 19 including (but are not limited to) fever, cough, sore throat, fatigue and shortness of breath.',
                img: 'covid',
              ),
              Agreement(
                iWill: iWill,
                title: 'I agree to wash the hands for 20 seconds periodically',
                img: 'hw',
              ),
              Agreement(
                iWill: iWill,
                title:
                    'I have with me a pair of reusable face masks, which I will be using during my stay at University campus without fail',
                img: 'mask',
              ),
              Agreement(
                iWill: iWill,
                title:
                    'I have enough stock of Handwash/Sanitizer for one month',
                img: 'sani',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Agreement extends StatelessWidget {
  final String title, img;
  final Function iWill;
  Agreement({
    this.title,
    this.img,
    this.iWill,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title, style: titleTextStyle),
        size32box,
        Image.asset('assets/$img.png',height: 256),
        size32box,
        FlatButton(
          highlightColor: Colors.amber.withOpacity(0.5),
          splashColor: Colors.white70,
          color: Colors.amber.withOpacity(0.2),
          shape: StadiumBorder(),
          onPressed: iWill,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Yes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.amber.shade800,
            ),
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              size32box,
              banner,
              size16box,
              Text(
                'Academic Updates',
                style: titleTextStyle,
              ),
              size32box,
              ...((ass.data == null || ass.data.isEmpty)
                  ? buildCircularProgressIndicator()
                  : ass.data.map((e) => AcademicUpdateCard(e)).toList()),
              size32box,
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildCircularProgressIndicator() {
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
  AcademicUpdateCard(
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
                    onTap: () async {
                      String link =
                          (await Firestore.instance.document('link/link').get())
                              .data['link'];
                      Share.share(
                          '*${map['title'] ?? ''}*\n${map['desc'] ?? ''}\n\n${(map['links'] as List).map((e) => '$e\n').toList().toString().replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('[', '').replaceAll(']', '')}\nDownlaod the app for more updates:\n$link');
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
              if (t.hour != 0)
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
