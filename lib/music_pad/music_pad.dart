import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resize/resize.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import 'dart:html' as html;
import 'dart:js' as js;

import '../keys/clef.dart';
import '../keys/interactive_piano.dart';
import '../keys/note_position.dart';
import '../keys/note_range.dart';
import '../model/kits/kits_collection.dart';

class  MusicPad extends StatefulWidget  {
  const MusicPad({Key? key}) : super(key: key);

  @override
  State<MusicPad> createState() => _MusicPadState();
}

class _MusicPadState extends State<MusicPad>  with SingleTickerProviderStateMixin  {

  List<String> samples0Playing = [];
  List<String> samples1Playing = [];
  List<String> samples2Playing = [];
  List<String> samples3Playing = [];
  List<String> samples4Playing = [];
  List<String> samples5Playing = [];

  List<String> samples0Queue = [];
  List<String> samples1Queue = [];
  List<String> samples2Queue = [];
  List<String> samples3Queue = [];
  List<String> samples4Queue = [];
  List<String> samples5Queue = [];

  double displayWidth = 0.0;
  double displayHeight = 0.0;

  Timer? beatTimer;
  bool beatTriggered = false;

  double x = 0.0;
  double y = 0.0;
  double rotationX = 0.0;
  double rotationY = 0.0;

  bool isMouseClicked = false;
  bool isDragging = false;
  bool kitSelected = true;
  int kitSelectedId = 0;

  FirebaseDatabase? database;
  DatabaseReference? ref;

  int previousBPMPosition = 3;
  int currentBPMPosition = 0;
  int beatBar = 0;
  bool isPlaying = false;
  var state;

  var lastPianoNoteTriggered = "";
  bool keyTriggered = false;
  KitCollection? kitsCollection;

  GlobalKey bottomKickKey = GlobalKey();
  GlobalKey mainWrapperKey = GlobalKey();

  @override
  initState() {
    beatTimer =
        Timer.periodic(const Duration(milliseconds: 1), (timer) {
          setState(() {
            beatTriggered = true;
            previousBPMPosition = currentBPMPosition;
            try {
              currentBPMPosition = int.parse(state['beat']);
              beatBar = int.parse(state['beatBar']);
            } catch (e) {
              currentBPMPosition = 0;
            }
            //print("pBMP $previousBPMPosition currentBPM $currentBPMPosition beatBar $beatBar");
            if(previousBPMPosition==3 && currentBPMPosition==0) {
              checkQueue(samples0Queue, samples0Playing, "playDrumSample");
              checkQueue(samples1Queue, samples1Playing, "playBassSample");
              checkQueue(samples2Queue, samples2Playing, "playSynthSample");
            }
          });
        });

    html.window.onKeyPress.listen((html.KeyboardEvent e) {
      if(!keyTriggered) {
        keyTriggered = true;
        playSampleWithKeyboard(e.key ?? "");
      }
    });

    html.window.onKeyUp.listen((html.KeyboardEvent e) {
      keyTriggered = false;
      runJSCommand("triggerSamplersNoteStop", [lastPianoNoteTriggered]);
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        kitSelected = false;
      });
    });

    super.initState();
  }

  runJSCommand(String command, List<Object?> args) {
    js.context.callMethod(command, args);
  }

  playSample(String sampleType, String playerId) {
    js.context.callMethod(sampleType, [playerId]);
  }

  stopSample(String sampleType, String playerId) {
    js.context.callMethod(sampleType, [playerId]);
  }

  Future<void> loadKits(int kitSelectedId) async {
    List<String> samples0 = [];
    List<String> samples1 = [];
    List<String> samples2 = [];
    List<String> samples3 = [];
    List<String> samples4 = [];
    List<String> samples5 = [];
    final String response = await rootBundle.loadString('assets/kits/kits.json');
    final data = await json.decode(response);
    String? sampleDuration;
    kitsCollection = KitCollection.fromJson(data);
    kitsCollection?.kits?.forEach((element) {
      sampleDuration = element.sampleDuration;
      if(element.kitId==kitSelectedId) {
        kitsCollection?.sounds?.forEach((sound) {
          switch (sound.type) {
            case 0:
              samples0.add("${element.folder}${sound.file}");
              break;
            case 1:
              samples1.add("${element.folder}${sound.file}");
              break;
            case 2:
              samples2.add("${element.folder}${sound.file}");
              break;
            case 3:
              samples3.add("${element.folder}${sound.file}");
              break;
            case 4:
              samples4.add("${element.folder}${sound.file}");
              break;
            case 5:
              samples5.add("${element.folder}${sound.file}");
              break;
          }
        });
      }
    });
    samples0.add(sampleDuration ?? "6.0.0");
    samples1.add(sampleDuration ?? "6.0.0");
    samples2.add(sampleDuration ?? "6.0.0");

    runJSCommand("loadDrums", samples0);
    runJSCommand("loadBass", samples1);
    runJSCommand("loadSynth", samples2);
    runJSCommand("loadFX", samples3);
  }

  checkQueue(List<String> toPlayQueue, List<String> playingQueue, String sampleToPlay) {
    if(toPlayQueue.isNotEmpty) {
      for (var element in toPlayQueue) {
        playSample(sampleToPlay, element);
        playingQueue.add(element);
        isPlaying = true;
      }
    }
    toPlayQueue.clear();
  }

  playSampleWithKeyboard(String charCode) {
    switch(charCode) {
      case "a": lastPianoNoteTriggered = "C3"; break;
      case "s": lastPianoNoteTriggered = "D3"; break;
      case "d": lastPianoNoteTriggered = "E3"; break;
      case "f": lastPianoNoteTriggered = "F3"; break;
      case "g": lastPianoNoteTriggered = "G3"; break;
      case "h": lastPianoNoteTriggered = "A3"; break;
      case "j": lastPianoNoteTriggered = "B3"; break;
      case "k": lastPianoNoteTriggered = "C4"; break;
      case "l": lastPianoNoteTriggered = "D4"; break;
      case ";": lastPianoNoteTriggered = "E4"; break;
      case "w": lastPianoNoteTriggered = "C#3"; break;
      case "e": lastPianoNoteTriggered = "D#3"; break;
      case "t": lastPianoNoteTriggered = "F#3"; break;
      case "y": lastPianoNoteTriggered = "G#3"; break;
      case "u": lastPianoNoteTriggered = "A#3"; break;
      case "o": lastPianoNoteTriggered = "C#4"; break;
      case "p": lastPianoNoteTriggered = "D#4"; break;
      default: lastPianoNoteTriggered = "";
    }
    runJSCommand("triggerSamplersNote", [lastPianoNoteTriggered]);
  }

  Widget getButton(List<String> sampleQueue, List<String> playingQueue, String stopSampleId, String buttonId, Color playingColor, oneShot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GlowButton(
        width: 100,
        height: 100,
        onPressed: () {
          if(oneShot) {
            playSample("playFXSample", buttonId);
          } else {
            if (playingQueue.contains(buttonId)) {
              playingQueue.remove(buttonId);
              stopSample(stopSampleId, buttonId);
            } else if (!sampleQueue.contains(buttonId)) {
              sampleQueue.add(buttonId);
            }
          }
        },
        color: sampleQueue.contains(buttonId) ? Colors.amber.withOpacity(.2) : playingQueue.contains(buttonId) ? playingColor : playingColor.withOpacity(.2),
        child: Center(child: Icon(playingQueue.contains(buttonId) ? Icons.pause : Icons.play_arrow, size: 30, color: Colors.white54)),
      ),
    );
  }

  Offset getPositionOfLastDrum() {
    try {
      RenderBox box = bottomKickKey.currentContext
          ?.findRenderObject() as RenderBox;
      Offset position = box.localToGlobal(
          Offset.zero); //this is global position
      //double y = position.dy;
      return position;
    } catch (e) {
      return const Offset(0,0);
    }
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  double roundDouble(double value, int places){
    double mod = pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  Widget getAudioMeter(js.JsArray<dynamic> array) {
    double leftChannel = array[0];
    double rightChannel = array[1];
    if(leftChannel<=-500) {
      leftChannel = 500;
      rightChannel = 500;
    } else {
      leftChannel = leftChannel * -1;
      rightChannel = rightChannel * -1;
    }
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, bottom: 15),
        child: Container(
          width: 50,
          height: 565,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
                color: Colors.deepPurple.shade900.withOpacity(.5),
                width: 1
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    height: 550-leftChannel,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                            color: Colors.white30
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Colors.red,
                            Colors.yellow,
                            Colors.green,
                          ],
                        )
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 550-rightChannel,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                            color: Colors.white30
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Colors.red,
                            Colors.yellow,
                            Colors.green,
                          ],
                        )
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getTopBar() {
    return Center(
      child: SizedBox(
        width: 250,
        child: Row(
          children: [
            SizedBox(
              width: 200,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 25,
                    child: Container(
                      width: currentBPMPosition==0 ? 25 : 15,
                      height: currentBPMPosition==0 ? 25 : 15,
                      decoration: BoxDecoration(
                          color: currentBPMPosition==0 ? Colors.orange : Colors.orange.withOpacity(.4),
                          shape: BoxShape.circle
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 25,
                    child: Container(
                      width: currentBPMPosition==1 ? 25 : 15,
                      height: currentBPMPosition==1 ? 25 : 15,
                      decoration: BoxDecoration(
                          color: currentBPMPosition==1 ? Colors.orange : Colors.orange.withOpacity(.4),
                          shape: BoxShape.circle
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 25,
                    child: Container(
                      width: currentBPMPosition==2 ? 25 : 15,
                      height: currentBPMPosition==2 ? 25 : 15,
                      decoration: BoxDecoration(
                          color: currentBPMPosition==2 ? Colors.orange : Colors.orange.withOpacity(.4),
                          shape: BoxShape.circle
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 25,
                    child: Container(
                      width: currentBPMPosition==3 ? 25 : 15,
                      height: currentBPMPosition==3 ? 25 : 15,
                      decoration: BoxDecoration(
                          color: currentBPMPosition==3 ? Colors.orange : Colors.orange.withOpacity(.4),
                          shape: BoxShape.circle
                      ),
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(
              width: 50,
              child: Text("${beatBar+1} / 4",  style: GoogleFonts.darkerGrotesque(textStyle: const TextStyle(fontSize: 20), color: Colors.amber)),
            )
          ],
        ),
      ),
    );
  }

  Widget getPads(String padTitle, List<String> samplesQueue, List<String> playingQueue, String stopFunctionId, Color padColor, fxPath, double initVolumeValue, {bool oneShot = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
                color: Colors.white30
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [
                0.2,
                0.8,
              ],
              colors: [
                Colors.black,
                Color(0xFF0a0a0a),
              ],
            )
        ),
        width: 300,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(padTitle,
                  style: GoogleFonts.darkerGrotesque(textStyle: TextStyle(fontSize: 40, color: padColor))),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: GridView.builder(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  itemCount: 6,
                  itemBuilder: (BuildContext context, int index) {
                    return getButton(samplesQueue, playingQueue, stopFunctionId, "sample$index", padColor, oneShot);
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  )
                  
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 125,
                height: 125,
                child: SleekCircularSlider(
                    min: 0,
                    max: 100,
                    initialValue: initVolumeValue,
                    appearance: CircularSliderAppearance(
                        size: 100,
                        infoProperties: InfoProperties(
                          bottomLabelText: "Volume",
                          bottomLabelStyle: const TextStyle(fontSize: 10, color: Colors.white),
                          mainLabelStyle: const TextStyle(fontSize: 14, color: Colors.white),
                        )
                    ),
                    onChange: (double value) {
                      var volume = 100-(value-10);
                      var newVolume = 0-volume;
                      js.context.callMethod(fxPath, ["volume", roundDouble(newVolume,2)]);
                    }),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: SleekCircularSlider(
                        min: 0,
                        max: 100,
                        initialValue: 0,
                        appearance: CircularSliderAppearance(
                            size: 100,
                            infoProperties: InfoProperties(
                              bottomLabelText: "Delay",
                              bottomLabelStyle: const TextStyle(fontSize: 10, color: Colors.white),
                              mainLabelStyle: const TextStyle(fontSize: 14, color: Colors.white),
                            )
                        ),
                        onChange: (double value) {
                          js.context.callMethod(fxPath, ["delay", roundDouble(value/100,2)]);
                        }),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: SleekCircularSlider(
                        min: 0,
                        max: 20,
                        initialValue: 0,
                        appearance: CircularSliderAppearance(
                            size: 100,
                            infoProperties: InfoProperties(
                              bottomLabelText: "Reverb",
                              bottomLabelStyle: const TextStyle(fontSize: 10, color: Colors.white),
                              mainLabelStyle: const TextStyle(fontSize: 14, color: Colors.white),
                            )
                        ),
                        onChange: (double value) {
                          js.context.callMethod(fxPath, ["reverb", roundDouble(value,2)]);
                        }),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getIntro() {
    return IgnorePointer(
      ignoring: kitSelected,
      child: AnimatedOpacity(
        duration: const Duration(seconds: 1),
        opacity: kitSelected ? 0.0 : 1.0,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(.8),
            child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                          color: Colors.white
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20))
                  ),
                  width: 500,
                  height: 550,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40,),
                        const Text("SELECT A KIT", style: TextStyle(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 20,),
                        Card(
                          color: Colors.green,
                          child: Material(
                            child: ListTile(
                              title: const Text('SYNTH WAVE'),
                              onTap: () {
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  loadKits(3);
                                  Future.delayed(const Duration(milliseconds: 1000), ()
                                  {
                                    runJSCommand("setTransport", [100]);
                                  });
                                });

                                setState(() {
                                  kitSelected = true;
                                });
                              },
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.green,
                          child: Material(
                            child: ListTile(
                              title: const Text('TRANCE'),
                              onTap: () {
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    loadKits(1);
                                    Future.delayed(const Duration(milliseconds: 1000), ()
                                    {
                                      runJSCommand("setTransport", [134]);
                                    });
                                  });

                                  setState(() {
                                    kitSelected = true;
                                  });
                              },
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.green,
                          child: Material(
                            child: ListTile(
                              title: const Text('DUB STEP'),
                              onTap: () {
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  loadKits(2);
                                  Future.delayed(const Duration(milliseconds: 1000), ()
                                  {
                                    runJSCommand("setTransport", [145]);
                                  });
                                });

                                setState(() {
                                  kitSelected = true;
                                });
                              },
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.green,
                          child: Material(
                            child: ListTile(
                              title: const Text('HIP HOP'),
                              onTap: () {
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  loadKits(4);
                                  Future.delayed(const Duration(milliseconds: 1000), ()
                                  {
                                    runJSCommand("setTransport", [130]);
                                  });
                                });

                                setState(() {
                                  kitSelected = true;
                                });
                              },
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.green,
                          child: Material(
                            child: ListTile(
                              title: const Text('ROCK'),
                              onTap: () {
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  loadKits(5);
                                  Future.delayed(const Duration(milliseconds: 1000), ()
                                  {
                                    runJSCommand("setTransport", [95]);
                                  });
                                });

                                setState(() {
                                  kitSelected = true;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        const SizedBox(height: 40,),
                        const Text("WARNING:\nAdjust your volume before continuing, sounds will be generated.\n\nCommand +/- to adjust zoom",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }

  Widget getFXPad() {
    return  MouseRegion(
      onEnter: (PointerEvent details) {

      },
      onHover: (PointerEvent details) {
        runJSCommand("audioFilterFX", [details.position.dx, details.position.dy, 400, 400]);
      },
      onExit: (PointerEvent details) {
        runJSCommand("audioFilterFX", [1, 1, 1, 1]);

      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 140,
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
                color: Colors.white30
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [
                0.2,
                0.8,
              ],
              colors: [
                Colors.black,
                Color(0xFF0a0a0a),
              ],
            )
        ),
        child: Center(child: Text("FX\nPAD",
            textAlign: TextAlign.center,
            style: GoogleFonts.darkerGrotesque(textStyle: TextStyle(fontSize: 40, color: Colors.deepPurple.withOpacity(.5))))),
      ),
    );
  }

  double getBlurAmountFromMeter(js.JsArray<dynamic> array) {
    double leftChannel = array[0];
    //double rightChannel = array[1];
    if(leftChannel>-10) {
      return 15;
    } else if(leftChannel>-12) {
      return 9;
    }else if(leftChannel>-14) {
      return 8;
    } else if(leftChannel>-16) {
      return 7;
    } else if(leftChannel>-18) {
      return 6;
    }  else if(leftChannel>-20) {
      return 5;
    }  else if(leftChannel>-26) {
      return 4;
    } else if(leftChannel>-40) {
      return 3;
    } else {
      return 2.0;
    }
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      //x = details.position.dx;
      //y = details.position.dy;
      double middle = MediaQuery.of(context).size.width/2;
      double middleY = MediaQuery.of(context).size.height/2;
      double dx = details.position.dx;
      double dy = details.position.dy;
      if(dx>middle) {
        rotationX = (dx-middle)/middle/20;
        rotationY = (middleY-dy)/middleY/20;
      } else if(dx<middle) {
        rotationX = (dx-middle)/middle/20;
        rotationY = (middleY-dy)/middleY/20;
      } else {
        rotationX = 0;
        rotationY = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(displayWidth==0) {
      displayWidth = MediaQuery.of(context).size.width;
    }
    return Resize(
        builder: () {
          return MouseRegion(
            onHover: _updateLocation,
            child: Scaffold(
                backgroundColor: Colors.black,
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    state = js.JsObject.fromBrowserObject(js.context['state']);
                    var meterValue = state['meterValue'];
                    var backDropFilterAmt = getBlurAmountFromMeter(meterValue);
                    getPositionOfLastDrum();
                    return Stack(
                      children: [
                        Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..rotateX(rotationY) // changed
                            ..rotateY(rotationX), // changed
                          alignment: FractionalOffset.center,
                          child: Container(
                              color: Colors.black,
                              width: double.infinity,
                              height: double.infinity,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 70),
                                      width: 1500,
                                      height: 600,
                                      color: Colors.red,
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: backDropFilterAmt, sigmaY: backDropFilterAmt),
                                        child: Container(
                                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        getTopBar(),
                                        const SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              border: Border.all(
                                                  color: Colors.white30
                                              ),
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              gradient: const LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                stops: [
                                                  0.2,
                                                  0.8,
                                                ],
                                                colors: [
                                                  Colors.black,
                                                  Color(0xFF0a0a0a),
                                                ],
                                              )
                                          ),
                                          width: 1500,
                                          height: 600,
                                          child: Stack(
                                            children: [
                                              getAudioMeter(meterValue),
                                              Row(
                                                children: [
                                                  getPads("BEAT", samples0Queue, samples0Playing, "stopDrumSample", Colors.greenAccent, "drumsFX", 90),
                                                  getPads("BASS", samples1Queue, samples1Playing, "stopBassSample", Colors.lime, "bassFX", 90),
                                                  getPads("SYNTH", samples2Queue, samples2Playing, "stopSynthSample", Colors.pinkAccent, "synthFX", 80),
                                                  getPads("GUITARS/FX", samples3Queue, samples3Playing, "playFXSample", Colors.purple, "oneShotsFX", 85, oneShot: true),
                                                  getFXPad()
                                                ],
                                              ),
                                              //getSounds(),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 20),
                                          height: 300,
                                          width: 1500,
                                          child: InteractivePiano(
                                            highlightedNotes: [
                                              NotePosition(note: Note.C, octave: 3)
                                            ],
                                            naturalColor: Colors.white,
                                            accidentalColor: Colors.black,
                                            keyWidth: 60,
                                            noteRange: NoteRange.forClefs([
                                              Clef.Bass,
                                            ], extended: true),
                                            onNotePositionTapped: (position) {
                                               lastPianoNoteTriggered = position.note.name+position.octave.toString();
                                               runJSCommand("triggerSamplersNote", [position.note.name+position.octave.toString()]);
                                            },
                                            onNotePositionTappedUp: (position) {
                                              runJSCommand("triggerSamplersNoteStop", [position.note.name+position.octave.toString()]);
                                            },
                                          ),
                                        ),
                                        const Text("Keyboard keys will trigger notes.\nRefresh to load a new kit.", style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ),
                        ),
                        getIntro(),
                      ],
                    );
                   }
                )
            ),
          );
        }
    );
  }
}
