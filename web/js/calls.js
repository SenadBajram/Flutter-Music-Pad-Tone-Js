//Drum FX
const drumReverb = new Tone.Reverb(0.01).toDestination();
const drumDelay = new Tone.FeedbackDelay({wet: 0, delayTime: .25, feedback: 0.5}).toDestination();

const bassReverb = new Tone.Reverb(0.01).toDestination();
const bassDelay = new Tone.FeedbackDelay({wet: 0, delayTime: .25, feedback: 0.5}).toDestination();

const synthReverb = new Tone.Reverb(0.01).toDestination();
const synthDelay = new Tone.FeedbackDelay({wet: 0, delayTime: .25, feedback: 0.5}).toDestination();

const fxReverb = new Tone.Reverb(0.01).toDestination();
const fxDelay = new Tone.FeedbackDelay({wet: 0, delayTime: .25, feedback: 0.5}).toDestination();

const keyboardReverb = new Tone.Reverb(0.3).toDestination();
const keyboardDelay = new Tone.FeedbackDelay({wet: .5, delayTime: .25, feedback: 0.5}).toDestination();

const recorder = new Tone.Recorder();
const toneMeter = new Tone.Meter({
    channels: 2,
});

//const analyser = new Tone.Analyser('waveform', 128);
const autoFilter = new Tone.AutoFilter("8n");
autoFilter.wet.value = 0;
autoFilter.frequency.value = 0;
autoFilter.start();
Tone.Master.chain(autoFilter);

var drumsPlayer;
var bassPlayer;
var synthPlayer;
var fxPlayer;

var samplesInKits = 6;
var defaultDrumVolume = -25;
var defaultBassVolume = -25;
var defaultSynthVolume = -25;
var defaultFxVolume = -15;
var sampler;

async function loadSamples() {
    await Tone.start();
    sampler = new Tone.Sampler({
                urls: {
                    A0: "A0.mp3",
                    C1: "C1.mp3",
                    "D#1": "Ds1.mp3",
                    "F#1": "Fs1.mp3",
                    A1: "A1.mp3",
                    C2: "C2.mp3",
                    "D#2": "Ds2.mp3",
                    "F#2": "Fs2.mp3",
                    A2: "A2.mp3",
                    C3: "C3.mp3",
                    "D#3": "Ds3.mp3",
                    "F#3": "Fs3.mp3",
                    A3: "A3.mp3",
                    C4: "C4.mp3",
                    "D#4": "Ds4.mp3",
                    "F#4": "Fs4.mp3",
                    A4: "A4.mp3",
                    C5: "C5.mp3",
                    "D#5": "Ds5.mp3",
                    "F#5": "Fs5.mp3",
                    A5: "A5.mp3",
                    C6: "C6.mp3",
                    "D#6": "Ds6.mp3",
                    "F#6": "Fs6.mp3",
                    A6: "A6.mp3"
                },
                baseUrl: "assets/samples/xlead/",
                volume: -20,
                onload: () => {
                   
                },

              },
                ).toDestination();

            sampler.connect(keyboardDelay);
            sampler.connect(keyboardReverb);
}

function loadDrums(
    sample0, sample1, sample2, sample3, sample4, sample5
) {
    drumsPlayer = new Tone.Players({
      urls: {
         sample0: sample0+".mp3",
         sample1: sample1+".mp3",
         sample2: sample2+".mp3",
         sample3: sample3+".mp3",
         sample4: sample4+".mp3",
         sample5: sample5+".mp3"
       },
       onload: () => {
           console.log("loadDrums Done");
       }
       }
       );
       console.log("load drums "+sample0);


    drumsPlayer.connect(drumDelay);
    drumsPlayer.connect(drumReverb);
}

function loadBass(sample0, sample1, sample2, sample3, sample4, sample5) {

    console.log("load bass "+sample0);
    bassPlayer = new Tone.Players({
        sample0: sample0+".mp3",
        sample1: sample1+".mp3",
        sample2: sample2+".mp3",
        sample3: sample3+".mp3",
        sample4: sample4+".mp3",
        sample5: sample5+".mp3"
       }).toDestination();



    bassPlayer.connect(bassDelay);
    bassPlayer.connect(bassReverb);
}

function loadSynth(sample0, sample1, sample2, sample3, sample4, sample5) {

    synthPlayer = new Tone.Players({
        sample0: sample0+".mp3",
        sample1: sample1+".mp3",
        sample2: sample2+".mp3",
        sample3: sample3+".mp3",
        sample4: sample4+".mp3",
        sample5: sample5+".mp3"
       }).toDestination();

    synthPlayer.connect(synthDelay);
    synthPlayer.connect(synthReverb);

}

function loadFX(sample0, sample1, sample2, sample3, sample4, sample5) {
    console.log("loadFX "+sample0);
    fxPlayer = new Tone.Players({
        sample0: sample0+".mp3",
        sample1: sample1+".mp3",
        sample2: sample2+".mp3",
        sample3: sample3+".mp3",
        sample4: sample4+".mp3",
        sample5: sample5+".mp3"
       }).toDestination();

    // for(var i=0; i<samplesInKits; i++) {
    //     fxPlayer.player("sample"+i).loop = false;
    //     fxPlayer.player("sample"+i).autostart = false;
    //     fxPlayer.player("sample"+i).loopStart = "0:0:0";
    //     fxPlayer.player("sample"+i).loopEnd = "14:0:0";
    //     fxPlayer.player("sample"+i).volume.value = defaultFxVolume;
    //     fxPlayer.player("sample"+i).toDestination();
    //     fxPlayer.player("sample"+i).load("sample"+i+".ogg");
    // }

    synthPlayer.connect(fxDelay);
    synthPlayer.connect(fxReverb);
}

function playDrumSample(playerId) {
    console.log("START DRUM "+playerId);
    drumsPlayer.player(playerId).toDestination().sync().start(0);
}

function stopDrumSample(playerId) {
    console.log("STOP DRUM "+playerId);
    drumsPlayer.player(playerId).toDestination().sync().stop(0);
}

function playBassSample(playerId) {
    bassPlayer.player(playerId).toDestination().sync().start(0);
}

function stopBassSample(playerId) {
    bassPlayer.player(playerId).toDestination().sync().stop(0);
}

function playSynthSample(playerId) {
    synthPlayer.player(playerId).toDestination().sync().start(0);
}

function stopSynthSample(playerId) {
    synthPlayer.player(playerId).toDestination().sync().stop(0);
}

function playFXSample(playerId) {
    fxPlayer.player(playerId).start();
}

function stopFXStample(playerId) {
    fxPlayer.player(playerId).volume.value = -500;
}

function triggerSamplersNote(noteName) {
    sampler.triggerAttack(noteName);
}

function triggerSamplersNoteStop(noteName) {
    sampler.triggerRelease(noteName);
}

function drumsFX(effectType, amount) {
    switch(effectType) {
        case "volume":
            defaultDrumVolume = amount;
            for(var i=0; i<samplesInKits; i++) {
                if(drumsPlayer.player("sample"+i).volume.value>-500) {
                    drumsPlayer.player("sample"+i).volume.value = amount;
                }
            }
            console.log("VOLUME "+amount);
            break;
        case "reverb":
            drumReverb.decay = amount;
            break;
        case "delay":
            drumDelay.wet.value = amount;
            break;
    }
}

function bassFX(effectType, amount) {
    switch(effectType) {
        case "volume":
            defaultBasVolume = amount;
            for(var i=0; i<samplesInKits; i++) {
                if(bassPlayer.player("sample"+i).volume.value>-500) {
                    bassPlayer.player("sample"+i).volume.value = amount;
                }
            }
            break;
        case "reverb":
            bassReverb.decay = amount;
            break;
        case "delay":
            bassDelay.wet.value = amount;
            break;
    }
}

function synthFX(effectType, amount) {
    switch(effectType) {
        case "volume":
            defaultSynthVolume = amount;
            for(var i=0; i<samplesInKits; i++) {
                if(synthPlayer.player("sample"+i).volume.value>-500) {
                    synthPlayer.player("sample"+i).volume.value = amount;
                }
            }
            break;
        case "reverb":
            synthReverb.decay = amount;
            break;
        case "delay":
            synthDelay.wet.value = amount;
            break;
    }
}

function oneShotsFX(effectType, amount) {
    switch(effectType) {
        case "volume":
            defaultFxVolume = amount;
            for(var i=0; i<samplesInKits; i++) {
                if(fxPlayer.player("sample"+i).volume.value>-500) {
                    fxPlayer.player("sample"+i).volume.value = amount;
                }
            }
            break;
        case "reverb":
            fxReverb.decay = amount;
            break;
        case "delay":
            fxDelay.wet.value = amount;
            break;
    }
}

function audioFilterFX(mouseX, mouseY, width, height) {
    var wet = 0;
    var frequency = 0;
    if(mouseY==1) {
        wet = 0;
    } else if(mouseY>600) {
        wet = .9;
    } else if(mouseY>500) {
       wet = .8;
    } else if(mouseY>400) {
        wet = .7;
    } else if(mouseY>300) {
        wet = .6;
    }  else if(mouseY>250) {
       wet = .5;
    } else if(mouseY>200) {
        wet = .6;
    } else if(mouseY>150) {
        wet = .3;
    } else if(mouseY>100) {
        wet = .2;
    } else if(mouseY>80) {
        wet = .2;
    } else if(mouseY>10) {
       wet = .1;
   }
  autoFilter.wet.value = wet;
  autoFilter.frequency.value = mouseY;
}


async function setTransport(bpm) {
    console.log("Set Temp "+bpm);
    loadSamples();
    for(var i=0; i<samplesInKits; i++) {
        drumsPlayer.player("sample"+i).loop = true;
        drumsPlayer.player("sample"+i).autostart = true;
        //drumsPlayer.player("sample"+i).volume.value = -500;

        bassPlayer.player("sample"+i).loop = true;
        bassPlayer.player("sample"+i).autostart = true;
        //bassPlayer.player("sample"+i).volume.value = -500;

        synthPlayer.player("sample"+i).loop = true;
        synthPlayer.player("sample"+i).autostart = true;
        //synthPlayer.player("sample"+i).volume.value = -500;
    }


    Tone.Transport.bpm.value = bpm;
    Tone.Transport.loop = true;
    Tone.Transport.loopStart = "0:0:0";
    Tone.Transport.loopEnd = "4:0:0";
    Tone.Master.chain(toneMeter, autoFilter);
    //Tone.Master.chain(analyser);
    //autoFilter.connect(Tone.Master);
    await Tone.loaded().then(() => {
            Tone.Transport.start();
             for(var i=0; i<samplesInKits; i++) {
//                drumsPlayer.player("sample0").toDestination().sync().start(0);
//                bassPlayer.player("sample"+i).toDestination().sync().start(0);
//                synthPlayer.player("sample"+i).toDestination().sync().start(0);
            }

            drumsFX("volume", -20);
            bassFX("volume", -20);
            synthFX("volume", -30);
            oneShotsFX("volume", -20);
        });

}

setInterval(function () {

  const [bar, beat, sixteenth] = Tone.Transport.position.split(":");
//  console.log("Bar: "+bar);
//  console.log("beat: "+beat);
  window.state = {
      meterValue: toneMeter.getValue(),
      beat: beat,
      beatBar: bar
  }
}, 1);

//function record() {
//    recorder.start();
//
//    setTimeout(async () => {
//        // the recorded audio is returned as a blob
//        const recording = await recorder.stop();
//        // download the recording by creating an anchor element and blob url
//        const url = URL.createObjectURL(recording);
//        const anchor = document.createElement("a");
//        anchor.download = "recording.webm";
//        anchor.href = url;
//        anchor.click();
//    }, 4000);
//}