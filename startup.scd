(
//s.options.sampleRate = 48000.0;
s.options.memSize_(2 ** 18);
s.options.numAudioBusChannels = 1024 * 2;
s.options.numWireBufs = 2 ** 7;

// for superdirt
//s.options.numBuffers = 1024 * 16;

"LADSPA_PATH".setenv("/Applications/LMMS.app/Contents/lib/lmms/ladspa");
//LADSPA.listPlugins;  //should post a long list of plugins

s.options.numOutputBusChannels = 16;
s.options.numInputBusChannels = 2;
s.options.inDevice_("supercollider-in");
//s.options.inDevice = "TASCAM DR Series";
s.options.outDevice_("supercollider-out");
s.recHeaderFormat = "WAV";

s.waitForBoot({

    Knob.defaultMode = \vert;
    QtGUI.palette = QPalette.dark;
    GUI.skins.put(\jit, (
        fontSpecs: 		["Andale Mono", 11],
        fontColor: 		QtGUI.palette.baseText,
        background: 	QtGUI.palette.base,
        foreground:		QtGUI.palette.base,
        onColor:		QtGUI.palette.highlight,
        onColor2:   	QtGUI.palette.highlight,
        offColor:		QtGUI.palette.highlight,
        hiliteColor:	QtGUI.palette.buttonText,
        gap:			0 @ 0,
        margin: 		2@2,
        buttonHeight:	18,
        headHeight: 	24
    ));

    Font.setDefault(Font("Andale Mono", 11));

    W.clock = LinkClock.new.latency_(s.latency).permanent_(true);
    TempoClock.default = W.clock;
    "load synthdefs...".inform;
    (App.librarydir.standardizePath ++ "synthdefs/*.scd").loadPaths;
    "load mixins...".inform;
    (App.librarydir.standardizePath ++ "mixin/*.scd").loadPaths;
    VSTPlugin.search(verbose:true);

    if (\SCNvim.asClass.notNil) {
        Server.default.doWhenBooted {
            \SCNvim.asClass.updateStatusLine(1, \SCNvim.asClass.port);
        }
    };

    {
        "start midi".inform;
        MidiCtrl.start;
    }.defer(2);

    s.makeGui;

    Spec.add(\freq, ControlSpec(20, 20000, 'exp', 0, 60.midicps, units:" Hz"));
    Spec.add(\cutoff, ControlSpec(20, 20000, 'exp', 0, 1000, units:"filter"));
	Spec.add(\ffreq, ControlSpec(20, 20000, 'exp', 0, 1000, units:"filter"));
	Spec.add(\hpf, ControlSpec(20, 20000, 'exp', 0, 20, units:"filter"));
	Spec.add(\lpf, ControlSpec(20, 20000, 'exp', 0, 20000, units:"filter"));
	Spec.add(\res, ControlSpec(0, 1, \lin, 0, 0.5, units:"filter"));
	Spec.add(\fvel, ControlSpec(0.001, 20, \lin, 0, 10, units:"filter"));
	Spec.add(\fatk, ControlSpec(0, 1, \lin, 0, 0.01, units:"filter"));
    Spec.add(\fdec, ControlSpec(0, 1, \lin, 0, 0.2, units:"filter"));
	Spec.add(\frel, ControlSpec(0, 8, \lin, 0, 0.29, units:"filter"));
	Spec.add(\fsuslevel, ControlSpec(0, 1, \lin, 0, 1, units:"filter"));
	Spec.add(\fcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"filter"));
    Spec.add(\fatkcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"filter"));
    Spec.add(\fdeccurve, ControlSpec(-8, 8, \lin, 0, -4, units:"filter"));
    Spec.add(\frelcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"filter"));
    Spec.add(\fbias, ControlSpec(0, 2, \lin, 0, 0, units:"filter"));
    Spec.add(\fpeak, ControlSpec(0, 1, \lin, 0, 1, units:"filter"));
    Spec.add(\snappy, ControlSpec(0, 1, \lin, 0, 0.5, "filter"));

	Spec.add(\atk, ControlSpec(0, 4, \lin, 0, 0.01, units:"aeg"));
	Spec.add(\dec, ControlSpec(0, 1, \lin, 0, 0.2, units:"aeg"));
	Spec.add(\rel, ControlSpec(0, 8, \lin, 0, 1, units:"aeg"));
	Spec.add(\suslevel, ControlSpec(0, 1, \lin, 0, 0.7, units:"aeg"));
	Spec.add(\curve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\atkcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\deccurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\relcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\ts, ControlSpec(0.001, 100, \lin, 0, 1, units:"aeg"));

	Spec.add(\detunehz, ControlSpec(0, 10, \lin, 0, 0, units:"pitch"));
	Spec.add(\bend, ControlSpec(-12, 12, \lin, 0, 0, units:"pitch"));
	Spec.add(\vrate, ControlSpec(0, 440, \lin, 0, 6, units:"pitch"));
	Spec.add(\vdepth, ControlSpec(0, 1, \lin, 0, 0, units:"pitch"));
    Spec.add(\glis, ControlSpec(0, 1, \lin, 0, 0, units:"pitch"));
    Spec.add(\octave, ControlSpec(1, 8, \lin, 1, 5, "pitch"));
    Spec.add(\mtranspose, ControlSpec(-12, 12, \lin, 1, 0, "pitch"));
    Spec.add(\root, ControlSpec(-12, 12, \lin, 1, 0, "pitch"));
    Spec.add(\ctranspose, ControlSpec(-12, 12, \lin, 1, 0, "pitch"));

    Spec.add(\legato, ControlSpec(0.001, 8, \lin, 0, 1, "dur"));
    Spec.add(\stretch, ControlSpec(0.001, 8, \lin, 0, 1, "dur"));

	Spec.add(\spread, ControlSpec(0, 1, \lin, 0, 1, units:"stereo"));
	Spec.add(\center, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));
	Spec.add(\pan, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));

	Spec.add(\vel, ControlSpec(0, 1, \lin, 0, 0, units:"vol"));
	Spec.add(\drive, ControlSpec(1, 100, \lin, 0, 1, units:"vol"));
	Spec.add(\amp, ControlSpec(0, 2.dbamp, \lin, 0, -10.dbamp, units:"vol"));

    Spec.add(\startPos, ControlSpec(0, 1, \lin, 0, 0, units:"buf"));
    Spec.add(\endPos, ControlSpec(0, 1, \lin, 0, 1, units:"buf"));
    Spec.add(\rate, ControlSpec(0.0625, 4, \lin, 0, 1, units:"buf"));
    Spec.add(\dir, ControlSpec(0, 1, \lin, 0, 1, units:"buf"));
    Spec.add(\buf, ControlSpec(0, s.options.numBuffers, \lin, 1, 0, "buf"));

    Spec.add(\focus, ControlSpec(0, 1, \lin, 0, 1, "timbre"));
    Spec.add(\skew, ControlSpec(-2, 2, \lin, 0, 0, "timbre"));
    Spec.add(\fb, ControlSpec(0, 1.5, \lin, 0, 0, "timbre"));

})
)