//CmdPeriod at end of code is to be used to prevent filling all buffers
//use shift-drag to change fadeTime by seconds
//obviously replace ur own file pathNames into the variable y and re-execute code

(
Routine.run{

y = (Platform.resourceDir +/+ "sounds/a11wlk01.wav");
	s.sync;
b = Buffer.read(s, y);
	s.sync;
a = b.numFrames;
	s.sync;

(
SynthDef(\bufGab, { |out, amp=0.1, rate=1.0, bend=1.0, pos=1, sustain=0.01, pan|
	var snd = HPF.ar((LPF.ar((PlayBuf.ar(1, b, Line.ar((rate*BufRateScale.kr(b)), (rate*BufRateScale.kr(b)*bend), sustain),
		                                 1, pos, 0, 2)), 20000)),20);
	var env = EnvGen.ar(Env.sine(sustain, amp * 0.5), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 5).add;

SynthDef(\bufWide, { |out, amp=0.1, rate=1.0, bend=1.0, pos=1, sustain=0.01, pan, width=0.5|
	var holdT = sustain * width;
	var fadeT = 1 - width * sustain * 0.5;
	var snd = HPF.ar((LPF.ar((PlayBuf.ar(1, b, Line.ar((rate*BufRateScale.kr(b)), (rate*BufRateScale.kr(b)*bend), (fadeT*2+holdT)),
		                                 1, pos, 0, 2)), 20000)),20);
	var env = EnvGen.ar(Env([0, 1, 1, 0], [fadeT, holdT, fadeT], \sin),
		levelScale: amp * 0.5,
		doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 5).add;

SynthDef(\bufPerc, { |out, amp=0.1, rate=1.0, bend=1.0, pos=1, sustain=0.01, pan|
	var snd = HPF.ar((LPF.ar((PlayBuf.ar(1, b, Line.ar((rate*BufRateScale.kr(b)), (rate*BufRateScale.kr(b)*bend), sustain),
		                                 1, pos, 0, 2)), 20000)),20);
	var env = EnvGen.ar(
		Env.perc(0.1, 0.9, amp * 0.5),
			timeScale: sustain, doneAction: 2
		);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 5).add;

SynthDef(\bufPercRev, { |out, amp=0.1, rate=1.0, bend=1.0, pos=1, sustain=0.01, pan|
	var snd = HPF.ar((LPF.ar((PlayBuf.ar(1, b, Line.ar((rate*BufRateScale.kr(b)), (rate*BufRateScale.kr(b)*bend), sustain),
		                                 1, pos, 0, 2)), 20000)),20);
	var env = EnvGen.ar(
		Env.perc(0.9, 0.1, amp * 0.5, 4),
			timeScale: sustain, doneAction: 2
		);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 5).add;

);

s.sync;

(
(
q = q ? ();

q.paramRNames = [\posRange, \rateRange, \bendRange, \durRange, \densRange, \ampRange, \panRange];
q.paramNames = [\pos, \rate, \bend, \grDur, \dens, \amp, \pan];
q.syndefNames = [\bufGab, \bufWide, \bufPerc, \bufPercRev];

Spec.add(\xfadeTime, [0.001, 1000, \exp]);
Spec.add(\ring, [0.03, 30, \exp]);
Spec.add(\grDur, [0.0001, (a/s.sampleRate), \exp]);
Spec.add(\dens, [1, 1000, \exp]);
Spec.add(\rate, [0.125, 8, \exp]);
Spec.add(\bend, [0.5, 2, \exp]);
Spec.add(\pos, [0, a-1, \lin]);

Tdef(\cloud0)
	.set(
	\synName, \bufGab,
	\vol, 0.7,
	\current, (
		rateRange: [0.5, 2.0],
		bendRange: [1.0, 1.0],
		posRange: [0, 4000],
		ampRange: [0.5, 1],
		durRange: [0.001, 0.01],
		densRange: [10, 1000],
		panRange: [-1.0, 1.0]
	)
);

Tdef(\cloud0, { |e|

	loop {
		s.sendBundle(s.latency, [
			"/s_new", e.synName ? \bufGab,
			-1, 0, 0,
			\rate, 	~dirSwitch*(exprand(e.current.rateRange[0], e.current.rateRange[1])),
			\bend, 	exprand(e.current.bendRange[0], e.current.bendRange[1]),
			\pos, 	rrand(e.current.posRange[0], e.current.posRange[1]),
			\amp,	exprand(e.current.ampRange[0], e.current.ampRange[1]) * e.vol,
			\sustain,	exprand(e.current.durRange[0], e.current.durRange[1]),
			\pan, 	rrand(e.current.panRange[0], e.current.panRange[1])
		]);
		exprand(e.current.densRange[0].reciprocal, e.current.densRange[1].reciprocal).wait;
	}
}).quant_(0);
);


(
d = Tdef(\cloud0).envir;

d.randSet = { |d|
	var randSet = ();
	q.paramRNames.do { |pName, i|
		randSet.put(pName,
			q.paramNames[i].asSpec.map([1.0.rand, 1.0.rand].sort)
		);
	};
	randSet;
};

d.setNames = (1..8).collect { |i| ("set" ++ i).asSymbol };
d.setNames.do { |key| d[key] = d.randSet; }

)
);

s.sync;

(
d.stopAfterFade = false;
d.xfadeTime = 3;

d.morphtask = TaskProxy({
	var startSet = d[\current], endSet = d[\target];
	var stepsPerSec = 20;
	var numSteps = d.xfadeTime * stepsPerSec;
	var blendVal, morphSettings;

	if (d.target.notNil) {
		(numSteps).do { |i|
		//	["numSteps", i].postln;
			blendVal = (i + 1) / numSteps;
			morphSettings = endSet.collect({ |val, key|
				(startSet[key] ? val).blend(val, blendVal)
			});
			d.current_(morphSettings);
			(1/stepsPerSec).wait;
		};
		d.current_(d.target.copy);
		"morph done.".postln;
		if (d.stopAfterFade) { Tdef(\cloud0).stop; };
	};
}).quant_(0);

d.fadeTo = { |d, start, end, time, autoStop|
	d.current = d[start] ? d.current;
	d.target = d[end];
	d.xfadeTime = time ? d.xfadeTime;
	if (autoStop.notNil) { d.stopAfterFade = autoStop };
	d.morphtask.stop.play;
};

);

defer{
q.makeCloudGui = { |q, tdef, posPoint|
	var w, ezRangers, fdBox;
	var setMinis, skipjack;

	posPoint = posPoint ? 400@400;	// where to put the gui window

	w = Window.new("CloudGenMiniBuf",
		Rect.fromPoints(posPoint, (posPoint + (400@410)))).front;
	w.view.decorator_(FlowLayout(w.bounds.copy.moveTo(0, 0)));

	w.view.decorator.nextLine;

		// a just in time - gui for the Tdef
	z = TdefGui(tdef, parent: w);

	fdBox = EZNumber.new(w, 78@18, \Fade, ControlSpec(0.01, 100.0, \exp, 0.01, 3, nil),
		{ |nbx| tdef.envir.xfadeTime = nbx.value },
		 tdef.envir.xfadeTime, false, 35);

~recordButton = Button(w, 51@19);
~recordButton.states_([["rec", Color.black, Color.white],["rec", Color.white, Color.red]]);
~recordButton.action = {|view|
	                    if (view.value==1) {s.record} {s.stopRecording}};
~recordButton.value=0;

	w.view.decorator.nextLine;

~text = StaticText(w, 125@45);
~text.string = "myGrains";
~text.align = \center;
~text.font = Font("Abadi MT Condensed Extra Bold", 22);
~text.stringColor = Color.white;

~view = SoundFileView.new(w, Rect(0,0,202,45)).gridOn_(false);
~viewFile = SoundFile.new;
~viewFile.openRead(y);

~view.soundfile = ~viewFile;
~view.read(0, ~viewFile.numFrames);
~view.backColor = Color.new255(190, 190, 190);
~view.refresh;

~dirControl = Button(w, 52@45);
~dirControl.states_([[">"],["<"]])
           .action_( {~dirSwitch = ~dir.at(~dirControl.value)} );
~dirControl.value = 0;
~dir = [1, -1];
~dirSwitch = ~dir.at(~dirControl.value);

	w.view.decorator.nextLine;

	ezRangers = ();

	q.paramRNames.do { |name, i|
		ezRangers.put(name,
		EZRanger(w, 400@20, name, q.paramNames[i],
			{ |sl| tdef.envir.current[name] = sl.value; },
			tdef.envir.current[name], labelWidth: 70, numberWidth: 50, unitWidth: 10)
			.round_([1, 0.001, 0.001, 0.00001, 0.0001, 0.0001, 0.01][i])
		);
	};




	Button.new(w, 126@20).states_([[\randomize]])
		.action_({
			tdef.envir.target_(d.randSet);
			tdef.envir.morphtask.stop.play;
		});



	Button.new(w, 126@20).states_([[\continuous], [\fadeStops]])
		.value_(tdef.envir.stopAfterFade.binaryValue)
		.action_({ |btn|
			tdef.set(\stopAfterFade, btn.value == 1)
		});

	Button.new(w, 126@20).states_([[\skipWatching], [\skipWaiting]])
		.action_({ |btn|
			[ { skipjack.play }, { skipjack.stop }][btn.value].value
		});

	w.view.decorator.nextLine;

	skipjack = SkipJack({
		q.paramRNames.do { |name| ezRangers[name].value_(tdef.envir.current[name]) };
		fdBox.value_(tdef.envir.xfadeTime);

	}, 0.5, { w.isClosed }, name: tdef.key);

	w.view.decorator.nextLine;

	tdef.envir.setNames.do { |setname, i|
		var minisliders, setMinis;
		var zone = CompositeView.new(w, Rect(0,0,45, 96));
		zone.decorator = FlowLayout(zone.bounds, 0@0, 5@0);
		zone.background_(Color.white);

		Button.new(zone, Rect(0,0,45,20)).states_([[setname]])
			.action_({
				tdef.envir.target = tdef.envir[setname];
				tdef.envir.morphtask.stop.play;
			});

		Button.new(zone, Rect(0,0,45,20))
			.states_([["save" ++ (i + 1)]])
			.action_({
				d[setname] = tdef.envir.current.copy;
				setMinis.value;
			});

		minisliders = q.paramRNames.collect { |paramRname|
			RangeSlider.new(zone, 45@8).enabled_(false);
		};
		setMinis = {
			q.paramRNames.do { |paramRname, i|
				var paramName = q.paramNames[i];
				var myrange = d[setname][paramRname];
				var unmapped = paramName.asSpec.unmap(myrange);
				minisliders[i].lo_(unmapped[0]).hi_(unmapped[1]);
			}
		};
		setMinis.value;
	};

	EZSlider(w, 225@20, "vol", \amp, { |sl|tdef.set(\vol, sl.value) },
		0.7, false, 20, 36);

	StaticText.new(w, 60@20).string_("synthdef:").align_(\right);
	PopUpMenu.new(w, Rect(0,0,95,20))
		.items_([\bufGab, \bufWide, \bufPerc, \bufPercRev])
		.action_({ |pop| tdef.envir.synName = pop.items[pop.value] });


};
q.makeCloudGui(Tdef(\cloud0))
	};



	CmdPeriod.doOnce({b.free;});
}
)