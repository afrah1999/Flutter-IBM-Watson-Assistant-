import 'package:flutter/material.dart';
import 'package:watson_assistant_v2/watson_assistant_v2.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Watson Assistant Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  SpeechToText stt=SpeechToText();
  bool isListining=false;
  String text="";
  double accuracy=1.0;
//
  bool isSpeaking = false;
  final _flutterTts = FlutterTts();
//
  void initializeTts() {
    _flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });
    _flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
    _flutterTts.setErrorHandler((message) {
      setState(() {
        isSpeaking = false;
      });
    });
  }
  ///
  inisilizeAudio() async{
    stt.initialize();

  }

  String _text;
  WatsonAssistantV2Credential credential = WatsonAssistantV2Credential(
    // TODO: change the credentiel to yours
    version: '2019-02-28',
    username: 'apikey',
    apikey: '-urJOKD8ZPMNGQ1SUpogUcVQ_AYMzbnmz45W-kzIDTy1',
    assistantID: '0923574b-b0d0-45a1-9412-27a2cf1a4af9',
    url: 'https://api.eu-gb.assistant.watson.cloud.ibm.com/instances/482441b1-ec11-4c97-a02f-7c27f4707a17/v2',
  );

  WatsonAssistantApiV2 watsonAssistant;
  WatsonAssistantResponse watsonAssistantResponse;
  WatsonAssistantContext watsonAssistantContext =
  WatsonAssistantContext(context: {});

  final myController = TextEditingController();

  void _callWatsonAssistant() async {
    watsonAssistantResponse = await watsonAssistant.sendMessage(
        text, watsonAssistantContext);
    setState(() {
      _text = watsonAssistantResponse.resultText;

      isSpeaking ? stop() : speak();

    });
    watsonAssistantContext = watsonAssistantResponse.context;
    myController.clear();
  }

  @override
  void initState() {
    super.initState();
    inisilizeAudio();
    watsonAssistant =
        WatsonAssistantApiV2(watsonAssistantCredential: credential);
    _callWatsonAssistant();
    initializeTts();
  }
  //
  void speak() async {
    await _flutterTts.speak(_text);

  }

  void stop() async {
    await _flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }
//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jawab'),
        centerTitle: true,
        actions: <Widget>[
          
        ],
      ),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              SizedBox(
                height: 8.0,
              ),
              Text(
                text,
                style: Theme.of(context).textTheme.display1,
              ),
              Text(

                _text != null ? '$_text' : 'Watson Response Here',
                style: Theme.of(context).textTheme.display1,
              ),
              SizedBox(
                height: 24.0,
              ),

            ],

          ),

        ),

      ),
      floatingActionButton: FloatingActionButton(

        onPressed:() {
          _listen();
          _callWatsonAssistant();

        },
        child: Icon(Icons.mic),
      ),

    );
  }

  @override
  void dispose() {
    myController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  _listen() async{
    if(stt.isAvailable){
      if(!isListining){
        stt.listen(onResult: (result){
          setState(() {
            accuracy=result.confidence;
            text=result.recognizedWords;
            print('accurcy is: $accuracy');
            isListining=true;
          });
        });
      }
      else{
        setState(() {
          isListining=false;
          stt.stop();
        });
      }
    }
    else{
      print("the premestion was denied");
    }
  }
}
