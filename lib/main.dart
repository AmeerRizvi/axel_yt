import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'package:axel_yt/retro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(430, 932),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
        return MaterialApp(
          title: 'AXEL YT',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: primaryBlack),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'AXEL YT'),
          routes: {
            '/retro': (context) => const RetroMusic(),
          },
        );
      }
    );
  }
}

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final yt = YoutubeExplode();
  int _progress = 0;
  Future<void> download(String id, String dir) async {
    var video = await yt.videos.get(id);
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var streams = manifest.video;
    var audio = streams.first;
    var audioStream = yt.videos.streamsClient.get(audio);
    var fileName = '${video.title}.${audio.container.name}'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');

    var file = File('$dir/$fileName');

    if (file.existsSync()) {
      file.deleteSync();
    }
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);
    var len = audio.size.totalBytes;
    var count = 0;
    var msg = 'Downloading ${video.title}.${audio.container.name}';
    print(msg);
    await for (final data in audioStream) {
      count += data.length;
      var progress = ((count / len) * 100).ceil();
      setState(() {
        _progress = progress;
      });
      print('progress: ' + progress.toString());
      output.add(data);
    }
    print('HERE' + file.path.toString());
    await output.close();
  }

  StreamSubscription? _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles;
  String? _sharedText;
  @override
  void initState() {
    super.initState();
    // For sharing images coming from outside the app while the app is in the memory

    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
          setState(() {
            print("Shared:" + (_sharedFiles?.map((f)=> f.path)?.join(",") ?? ""));
            _sharedFiles = value;
          });
        }, onError: (err) {
          print("getIntentDataStream error: $err");
        });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
          setState(() {
            _sharedText = value;
          });
        }, onError: (err) {
          print("getLinkStream error: $err");
        });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        _sharedText = value ?? '';
      });
    });

    _getClipboardText();
    _listofFiles();
  }
  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  bool isLoading = false;
  TextEditingController tec = TextEditingController();

  _getClipboardText() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    String? clipboardText = clipboardData?.text;
    setState(() {
      tec.text = clipboardText ?? '';
    });
  }

  List file = [];
  _listofFiles() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String dir = appDocDirectory.path+'/'+'axelYt';
    setState(() {
      // file = io.Directory(dir).listSync().reversed.toList();
      file = io.Directory(dir).listSync()
          .toList()
        ..sort((l, r) => l.statSync().modified.compareTo(r.statSync().modified));
      file = file.reversed.toList();
    });
  }

  _showSnack(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white12,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Material(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(50,50,50,10),
                  child: TextField(
                    controller: tec,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                (_progress!=0 && _progress!=100) ? Padding(
                  padding: EdgeInsets.fromLTRB(15,0,15,0),
                  child: LinearPercentIndicator(
                    lineHeight: 3.0,
                    animationDuration: 3000,
                    percent: _progress/100,
                    barRadius: Radius.circular(7),
                    animateFromLastPercent: true,
                    linearGradient: LinearGradient(
                      colors: <Color>[Color(0xff000000), Color(0xff7703fc)],
                    ),
                    backgroundColor: Colors.white12,
                  ),
                ) : SizedBox(height: 3,),
                SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/retro');
                          },
                          child: Icon(Icons.next_plan)),
                    ElevatedButton(
                        onPressed: () {
                          tec.clear();
                        },
                        child: Icon(Icons.clear)),
                      ElevatedButton(
                          onPressed: () {
                            _getClipboardText();
                          },
                          child: Icon(Icons.arrow_forward_outlined)),
                    ElevatedButton(
                        onPressed: isLoading ? () {} : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try{
                            String videoId = YoutubePlayer.convertUrlToId(tec.text) ?? '';
                            Directory appDocDirectory = await getApplicationDocumentsDirectory();
                            String dir = appDocDirectory.path+'/'+'axelYt';
                            Directory(dir).createSync();
                            await download(videoId, dir);
                            _showSnack('Downloaded');
                            _listofFiles();
                          }catch(e){
                            _showSnack(e.toString());
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: isLoading ? CircularProgressIndicator.adaptive() : Icon(Icons.arrow_downward_rounded))
                  ],),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: file.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: index == 0 ? EdgeInsets.only(top: 20) : EdgeInsets.all(0.0),
                          child: GestureDetector(
                              onTap: () async {
                                String filePath = file[index].path;
                                await OpenFilex.open(filePath);
                              },
                              child: ListTile(title: Text(file[index].path.split('/').last.toString(), style: TextStyle(color: Colors.white),),)),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
