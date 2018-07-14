Server.default.options.outDevice_("JackRouter");
Server.default.options.inDevice_("JackRouter");

(
s.options.memSize_(2.pow(15)); // memSize larger than default required for stereo convolution

s.waitForBoot({
~fftsize = 2048; // also 4096 works; 1024 too often and amortisation too pushed, 8192 more high load FFT
~target= Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
~hymn = Buffer.read(s, Platform.resourceDir +/+ "sounds/SinedPink.aiff");
~monoBus = Bus.audio(s, 1);
~stereoBus = Bus.audio(s, 2);

SynthDef(\playBufMono, {
	|buf, amp=1, out=0|
	var sig;

	sig = PlayBuf.ar(1, buf, doneAction:2) * amp;

	Out.ar(out, sig);
}).add;

SynthDef(\playBufStereo, {
	|buf, amp=1, out=0|
	var sig;

	sig = PlayBuf.ar(2, buf, doneAction:2) * amp;

	Out.ar(out, sig);
}).add;

SynthDef(\dryMono, {
	|in, out=0, amp=1|
	var sig;

	sig = In.ar(in, 1) * amp;

	Out.ar(out, sig);
}).add;

SynthDef(\dryStereo, {
	|in, out=0, amp=1|
	var sig;

	sig = In.ar(in, 2) * amp;

	Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
	|fftsize=2048, in, amp=1, out=0, spec, hiFreq=10000, loFreq=50|
	var sig, kernel;

	sig = In.ar(in, 1);
	sig = PartConv.ar(sig, fftsize, spec, amp);
	sig = HPF.ar(LPF.ar(sig, hiFreq), loFreq);

	Out.ar(out, sig);
}).add;

SynthDef(\liveInput, {
	|in=0, out=0, amp=1|
	var sig;

	sig = SoundIn.ar([in, 1], amp);

	Out.ar(out, sig);
}).add;

/*********************************************
**********************************************
*******************THE GUI********************
**********************************************
*********************************************/

Window.closeAll;

w = Window("Reverb Unit", Rect(720,
	900,
	720,
	450
)).front
//.alwaysOnTop_(true) // not everyone would like this feature
.onClose_({
	Buffer.freeAll;
	~monoBus.free;
	~stereoBus.free;
	s.freeAll;
});

/****************TOP LABEL********************/

~labelView = CompositeView(w, Rect(10, 10, 205, 40))
.background_(Color.new255(240, 234, 214));
~chooseLabel = StaticText(~labelView, Rect(10, 0, 120, 20))
.font_(Font("Baskerville", 14))
.string_("Input signal is:");
~chooser = PopUpMenu(~labelView, Rect(10, 20, 110, 20))
.font_(Font("Baskerville"))
.items_([
	"Mono",
	"Stereo",
	"Live Input"
])
.value_(1);

/*********************************************
**************** REVERB GUTS *****************
*********************************************/

~revView = CompositeView(w, Rect(10, 60, 100, 380))
.background_(Color.new255(240, 234, 214));
~revButton = Button(~revView, Rect(0,310,50,50))
.states_([
	["PLAY", Color.green, Color.gray(0.8)],
	["STOP", Color.black, Color(0.2,0.75,0.95)]
])
.font_(Font("Baskerville", 18))
.action_({
	arg obj;
	if(
		obj.value == 1, //If reverb unit is on:
		{
			if(
				(~chooser.value == 1).or(~chooser.value == 2),  //If audio input signal is stereo:
				{
					~revSynthL = Synth(\reverb,
						[
							\in, ~stereoBus.subBus(0),
							\amp, ~revAmpSpec.map(~revAmpSlider.value),
							\spec, ~irSpectrumL
						],
						addAction: \addToTail
					).register;

					~revSynthR = Synth(\reverb,
						[
							\in, ~stereoBus.subBus(1),
							\amp, ~revAmpSpec.map(~revAmpSlider.value),
							\spec, ~irSpectrumR,
							\out, 1
						],
						addAction: \addToTail
					).register;
				},
				{ //else if ~chooser.value == 0 || 2
				  //(i.e., mono and/or live input via mic)
					~revSynthL = Synth(\reverb,
						[
							\in, ~monoBus,
							\amp, ~revAmpSpec.map(~revAmpSlider.value),
							\spec, ~irSpectrumL
						],
						addAction: \addToTail
					).register;
				}
			);
		},
		{
			if(
				~revSynthL.isPlaying,
				{
					~revSynthL.free;
				}
			);
			if(
				~revSynthR.isPlaying,
				{
					~revSynthR.free;
				}
			);
		};
	);
});

~revAmpSpec = ControlSpec(0.001,1,\exponential,0.001);
~revAmpSlider = Slider(~revView, Rect(60, 0, 35, 320))
.valueAction_(0.25)
.action_({
	arg obj;
	~revAmpNum.value_(~revAmpSpec.map(obj.value));
	if(
		~revSynthL.isPlaying,
		{
			~revSynthL.set(\amp, ~revAmpSpec.map(obj.value));
		}
	);
	if(
		~revSynthR.isPlaying,
		{
			~revSynthR.set(\amp, ~revAmpSpec.map(obj.value));
		}
	);
});
~revAmpNum = NumberBox(~revView, Rect(60, ~revAmpSlider.bounds.height + 5, 35, 18))
.value_(~revAmpSpec.map(~revAmpSlider.value))
.font_(Font("Baskerville"));
~revAmpLabel = StaticText(~revView, Rect(60, ~revAmpSlider.bounds.height + 20, 35, 17))
.font_(Font("Baskerville", 12))
.string_("amp")
.align_(\center);
~revLabel = StaticText(~revView, Rect(0,360, 95, 20))
.font_(Font("Baskerville", 16))
.string_("Reverb")
.align_(\center);

/************** FILTER CONTROLS **************/

~hiPassSpec = ControlSpec(5, 200, \exponential, 1);
~hiPassNum = NumberBox(~revView, Rect(5, 285, 45, 20))
.value_(~hiPassSpec.map(0))
.font_(Font("Baskerville"));
~hiPassKnob = Knob(~revView, Rect(5, 240, 45, 45))
.value_(~hiPassSpec.unmap(5))
.action_({
	arg obj;
	~hiPassNum.value_(~hiPassSpec.map(obj.value));
	if(
		~revSynthL.isPlaying,
		{
			~revSynthL.set(\loFreq, ~hiPassSpec.map(obj.value));
		}
	);
	if(
		~revSynthR.isPlaying,
		{
			~revSynthR.set(\loFreq, ~hiPassSpec.map(obj.value));
		}
	);
});
~hiPassLabel = StaticText(~revView, Rect(5, 220, 55, 20))
.font_(Font("Baskerville", 12))
.string_("High Pass");

~loPassSpec = ControlSpec(800, 16000, \exponential, 1);
~loPassNum = NumberBox(~revView, Rect(5, 195, 45, 20))
.value_(~loPassSpec.map(1))
.font_(Font("Baskerville"));
~loPassKnob = Knob(~revView, Rect(5, 150, 45, 45))
.value_(~loPassSpec.unmap(16000))
.action_({
	arg obj;
	~loPassNum.value_(~loPassSpec.map(obj.value));
	if(
		~revSynthL.isPlaying,
		{
			~revSynthL.set(\hiFreq, ~loPassSpec.map(obj.value));
		}
	);
	if(
		~revSynthR.isPlaying,
		{
			~revSynthR.set(\hiFreq, ~loPassSpec.map(obj.value));
		}
	);
});
~loPassLabel = StaticText(~revView, Rect(5, 130, 55, 20))
.font_(Font("Baskerville", 12))
.string_("Low Pass");

/*********************************************
***************DRY SIGNAL GUTS****************
*********************************************/

~inputView = CompositeView(w, Rect(15 + ~revView.bounds.width, 60, 100, 380))
.background_(Color.new255(240, 234, 214));
~playButton = Button(~inputView, Rect(0,310,50,50))
.states_([
	["PLAY", Color.green, Color.gray(0.8)],
	["STOP", Color.black, Color(0.2,0.75,0.95)]
])
.font_(Font("Baskerville", 18))
.action_({
	arg obj;
	if(
		obj.value == 1,
		{
			case
			{~chooser.value == 1}
				{
					~pbmSynth = Synth(\playBufStereo,
						[
							\buf, ~hymn,
							\amp, ~pbmAmpSpec.map(~pbmAmpSlider.value),
							\out, ~stereoBus
						]
					).register;
				}
			{~chooser.value == 0}
				{
					~pbmSynth = Synth(\playBufMono,
						[
							\buf, ~target,
							\amp, ~pbmAmpSpec.map(~pbmAmpSlider.value),
							\out, ~monoBus
						]
					).register;
				}
			{~chooser.value == 2}
			{
				~pbmSynth = Synth(\liveInput,
					[
						\amp, ~pbmAmpSpec.map(~pbmAmpSlider.value),
						\out, ~stereoBus
					]
				).register;
			};
		},
		{
			if(
				~pbmSynth.isPlaying,
				{
					~pbmSynth.free;
				}
			);
		}
	);
});

~pbmAmpSpec = ControlSpec(0.001,1.5,\exponential,0.001);
~pbmAmpSlider = Slider(~inputView, Rect(60, 0, 35, 320))
.valueAction_(0.25)
.action_({
	arg obj;
	~pbmAmpNum.value_(~pbmAmpSpec.map(obj.value));
	if(
		~pbmSynth.isPlaying,
		{
			~pbmSynth.set(\amp, ~pbmAmpSpec.map(obj.value));
		}
	);
});
~pbmAmpNum = NumberBox(~inputView, Rect(60, ~pbmAmpSlider.bounds.height + 5, 35, 18))
.value_(~pbmAmpSpec.map(~pbmAmpSlider.value))
.font_(Font("Baskerville"));
~pbmAmpLabel = StaticText(~inputView, Rect(60, ~revAmpSlider.bounds.height + 20, 35, 17))
.font_(Font("Baskerville", 12))
.string_("amp")
.align_(\center);
~dryLabel = StaticText(~inputView, Rect(0,360, 95, 20))
.font_(Font("Baskerville", 16))
.string_("Dry Signal")
.align_(\center);

~toggleLabel = StaticText(~inputView, Rect(5, ~inputView.bounds.height - 155, 50,50))
.font_(Font("Baskerville"))
.string_("Add dry signal to mix:");
~togValue=false;
~toggle = UserView(~inputView, Rect(12.5, ~inputView.bounds.height - 105, 25,25))
.drawFunc_({|v|
	var width, height, offset=2;
	width =  v.bounds.width;
	height = v.bounds.height;
	Pen.use{ //draw outline and background
		Pen.strokeRect(Rect(offset, offset, width-(offset*2), height-(offset*2)));
		Pen.fillColor_(Color.white);
		Pen.fillRect(Rect(offset, offset, width-(offset*2), height-(offset*2)));
		if(~togValue){ //draw the toggle cross
			Pen.line(Point(offset, height-offset), Point(width-offset, offset));
			Pen.line(Point(offset, offset), Point(width-offset, height-offset));
			Pen.stroke;
		};
	}
})
.mouseDownAction_({|view| //switch states on mouse-down
	~togValue = ~togValue.not;
	view.refresh;
	if( ~togValue, // Dry mix box is X'd:
		{
				~drySynthStereo = Synth(\dryStereo,
					[
						\buf, ~hymn,
						\amp, 1,
						\in, ~stereoBus
					],
					addAction: \addToTail
				).register;

				~drySynthMono = Synth(\dryMono,
					[
						\buf, ~target,
						\amp, 1,
						\in, ~monoBus
					],
					addAction: \addToTail
				).register;
		},
		{// Else if dry mix box is blank:
			if( ~drySynthMono.isPlaying,
					{~drySynthMono.free;}
				);
			if( ~drySynthStereo.isPlaying,
				{~drySynthStereo.free;}
			);
		}
	);
});


/************************************************
************ IMPULSE RESPONSE CHOOSER ***********
************************************************/

// CompositeView and StaticTexts //
~irView = CompositeView(w, Rect(25 + (~inputView.bounds.width * 2), 10, 485, 430))
.background_(Color.new255(240, 234, 214));
~instructions = StaticText(~irView, Rect(10, 5, 400, 20))
.font_(Font("Baskerville"))
.string_("Directory where impulse responses are found:");
~more = StaticText(~irView, Rect(10, 50, 400, 20))
.font_(Font("Baskerville"))
.string_("Select an impulse response:");

// Real guts
~bufs = Array.new;
~bufList = ListView(~irView, Rect(10, 70, 465, 140));
~irDirectory = TextField(~irView, Rect(10, 25, 465, 25))
.font_(Font("Baskerville", 14))
.action_({
	|field|
	if( ~bufs[0].isNil.not, // if ~bufs is already filled:
		{
			~bufs.do({
				|item|
				item.free;
			});
			~bufs = Array.new;
		}
	);
	~bufPath = PathName(field.value);
	~bufPath.entries.do({
		|path|
		~bufs = ~bufs.add(Buffer.readChannel(s, path.fullPath, channels: [0]));
		~bufs = ~bufs.add(Buffer.readChannel(s, path.fullPath, channels: [1]));
		});
	~bufList.items_(~bufPath.entries.collect({|i| i.fileNameWithoutExtension}));
});
//.valueAction_("/Users/kyleshaw/Composition/SuperCollider/IRs/Good Ones/");

~bufList.action_({
	|i|
	Routine({
	var bufSizeL, bufSizeR;

	if( ~irSpectrumL.isNil.not, // free these buffers if they were formerly used
		{
			~irSpectrumL.free;
			~irSpectrumR.free;
		}
	);

	s.sync;

	bufSizeL = PartConv.calcBufSize(~fftsize, ~bufs[i.value * 2]);
	bufSizeR = PartConv.calcBufSize(~fftsize, ~bufs[(i.value * 2) + 1]);
	~irSpectrumL = Buffer.alloc(s, bufSizeL, 1);
	~irSpectrumR = Buffer.alloc(s, bufSizeR, 1);
	~irSpectrumL.preparePartConv(~bufs[i.value * 2], ~fftsize);
	~irSpectrumR.preparePartConv(~bufs[(i.value * 2) + 1], ~fftsize);

	s.sync;
	}).play(AppClock);
}
);

/************************************************
************ AUDIO INPUT FILE CHOOSER ***********
************************************************/

~audioDirectoryText = StaticText(~irView, Rect(10, 215, 400, 20))
.font_(Font("Baskerville"))
.string_("Directory where sound files to be processed are found:");
~audioSelectText = StaticText(~irView, Rect(10, 260, 400, 20))
.font_(Font("Baskerville"))
.string_("Select an audio file for processing:");

// Real guts
~audioBufs = Array.new;
~audioBufList = ListView(~irView, Rect(10, 280, 465, 140));
~audioFiles = TextField(~irView, Rect(10, 235, 465, 25))
.font_(Font("Baskerville", 14))
//.valueAction_("/Users/kyleshaw/Desktop/Sounds/Hits/Loud/")
.action_({
	|field|
	if( ~audioBufs[0].isNil.not, // if ~bufs is already filled:
		{
			~audioBufs.do({
				|item|
				item.free;
			});
			~audioBufs = Array.new;
		}
	);
	~audioBufPath = PathName(field.value);
	~audioBufPath.entries.do({
		|path|
		~audioBufs = ~audioBufs.add(Buffer.read(s, path.fullPath));
		});
	~audioBufList.items_(~audioBufPath.entries.collect({|i| i.fileNameWithoutExtension}));
});

~audioBufList.action_({
	|i|
	if(~chooser.value == 0,
		{~target = ~audioBufs[i.value]}
	);
	if(~chooser.value == 1,
		{~hymn = ~audioBufs[i.value]}
	);
}
);

}); // end waitForBoot
) // end body of code

