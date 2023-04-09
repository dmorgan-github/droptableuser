(
s.options.safetyClipThreshold = 1;
//s.options.sampleRate = 48000.0;
s.options.memSize_(2 ** 18);
s.options.numAudioBusChannels = 1024 * 2;
s.options.numWireBufs = 2 ** 8;
s.options.numBuffers = 2 ** 12;

//"LADSPA_PATH".setenv("/Applications/LMMS.app/Contents/lib/lmms/ladspa");
//LADSPA.listPlugins;  //should post a long list of plugins

s.options.numOutputBusChannels = 16;
s.options.numInputBusChannels = 8;
s.options.inDevice_("supercollider-in");
s.options.outDevice_("supercollider-out");
//s.options.blockSize = 128;
//s.options.hardwareBufferSize = 32;//128;//512;

s.recHeaderFormat = "WAV";

s.waitForBoot({

    ~miditrace = false;
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

    EventPatternProxy.defaultQuant = 4;
    Server.default.latency = 0.21.debug("server latency");
    W.clock = LinkClock.new.latency_(s.latency).permanent_(true);
    TempoClock.default = W.clock;
    //"load synthdefs...".inform;
    //(App.librarydir.standardizePath ++ "synthdefs/*.scd").loadPaths;
    "load vst".inform;
    VSTPlugin.search(Server.default, options: (exclude: ["/Library/Audio/Plug-Ins/VST", "/Users/david/Library/Audio/Plug-Ins/VST"]), verbose:false);

    if (\SCNvim.asClass.notNil) {
        Server.default.doWhenBooted {
            \SCNvim.asClass.updateStatusLine(1, \SCNvim.asClass.port);
        }
    };

    DMModule.libraryDir = "~/projects/DMModuleLib/library/".standardizePath;
    thisProcess.platform.recordingsDir_("/Users/david/Documents/supercollider/patches/");

});

)
