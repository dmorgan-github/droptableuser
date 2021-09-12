(

s.options.memSize_(2 ** 18);
s.options.numAudioBusChannels = 1024 * 2;
s.options.numWireBufs = 2 ** 7;

// for superdirt
s.options.numBuffers = 1024 * 16;

"LADSPA_PATH".setenv("/Applications/LMMS.app/Contents/lib/lmms/ladspa");
//LADSPA.listPlugins;  //should post a long list of plugins

s.options.numOutputBusChannels = 20;
s.options.numInputBusChannels = 2;
s.options.inDevice_("supercollider-in");
s.options.outDevice_("supercollider-out");
s.recHeaderFormat = "WAV";

s.waitForBoot({

    Knob.defaultMode = \vert;
    QtGUI.palette = QPalette.dark;
    GUI.skins.put(\jit, (
        fontSpecs: 		["LCDMono2", 11],
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

    Font.setDefault(Font("LCDMono2", 11));
    thisProcess.platform.recordingsDir_(App.workspacedir.standardizePath);

    // ctrl: 262144
    // alt: 524288
    // apple : 1048576
    //~func = {|ctrl, char, mod, unicode, keycode, key| [ctrl, char, mod, unicode, keycode, key].postln}
    //Document.globalKeyUpAction = func

	{
		var func = {arg code;
			if (code == "scid") {
				//var id = ("\\" ++ App.idgen).asSymbol;
				var id = (App.idgen).asSymbol;
				code = code.replace("scid", id);
				Document.current.selectedString_(id);
			};
			code;
		};
		this.preProcessor = func;
	}.();

    W.clock = LinkClock.new.latency_(s.latency).permanent_(true);
    TempoClock.default = W.clock;
    (App.librarydir.standardizePath ++ "synthdefs/*.scd").loadPaths;
    (App.librarydir.standardizePath ++ "mixins/*.scd").loadPaths;
    VSTPlugin.search(verbose:false);

    if (\SCNvim.asClass.notNil) {
        Server.default.doWhenBooted {
            \SCNvim.asClass.updateStatusLine(1, \SCNvim.asClass.port);
        }
    };
    s.makeGui;

	Spec.add(\cutoff, ControlSpec(20, 20000, 'exp', 0, 100, units:"filter"));
	Spec.add(\hpf, ControlSpec(20, 20000, 'exp', 0, 20, units:"filter"));
	Spec.add(\lpf, ControlSpec(20, 20000, 'exp', 0, 20000, units:"filter"));
	Spec.add(\res, ControlSpec(0, 1, \lin, 0, 0.5, units:"filter"));
	Spec.add(\fvel, ControlSpec(0.001, 20, \lin, 0, 10, units:"filter"));
	Spec.add(\fatk, ControlSpec(0, 1, \lin, 0, 0.01, units:"filter"));
	Spec.add(\frel, ControlSpec(0, 8, \lin, 0, 0.29, units:"filter"));
	Spec.add(\fsuslevel, ControlSpec(0, 1, \lin, 0, 1, units:"filter"));
	Spec.add(\fcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"filter"));

	Spec.add(\atk, ControlSpec(0, 2, \lin, 0, 0.01, units:"aeg"));
	Spec.add(\dec, ControlSpec(0, 1, \lin, 0, 0.2, units:"aeg"));
	Spec.add(\rel, ControlSpec(0, 8, \lin, 0, 0.29, units:"aeg"));
	Spec.add(\suslevel, ControlSpec(0, 1, \lin, 0, 1, units:"aeg"));
	Spec.add(\curve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\atkcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\deccurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\relcurve, ControlSpec(-8, 8, \lin, 0, -4, units:"aeg"));
	Spec.add(\ts, ControlSpec(0.001, 100, \lin, 0, 1, units:"aeg"));

	Spec.add(\detunehz, ControlSpec(0, 10, \lin, 0, 0, units:"pitch"));
	Spec.add(\bend, ControlSpec(-12, 12, \lin, 0, 0, units:"pitch"));
	Spec.add(\vrate, ControlSpec(0, 440, \lin, 0, 6, units:"pitch"));
	Spec.add(\vdepth, ControlSpec(0, 0.5, \lin, 0, 0, units:"pitch"));
    Spec.add(\octave, ControlSpec(1, 8, \lin, 1, 5, "pitch"));

	Spec.add(\spread, ControlSpec(0, 1, \lin, 0, 1, units:"stereo"));
	Spec.add(\center, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));
	Spec.add(\pan, ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"));

	Spec.add(\vel, ControlSpec(0, 1, \lin, 0, 1, units:"vol"));
	Spec.add(\drive, ControlSpec(1, 100, \lin, 0, 1, units:"vol"));
	Spec.add(\amp, ControlSpec(0, 1, \lin, 0, -10.dbamp, units:"vol"));

    Spec.add(\startPos, ControlSpec(0, 1, \lin, 0, 0, units:"buf"));
    Spec.add(\endPos, ControlSpec(0, 1, \lin, 0, 1, units:"buf"));
    Spec.add(\legato, ControlSpec(0.0625, 2, \lin, 0, 0.7, "dur"));

    Spec.add(\buf, ControlSpec(0, s.options.numBuffers, \lin, 1, 0, "buf"));

})
)
