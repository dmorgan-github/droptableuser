(
s.options.safetyClipThreshold = 1;
//s.options.sampleRate = 48000.0;
s.options.memSize_(2 ** 18);
s.options.numAudioBusChannels = 1024 * 2;
s.options.numWireBufs = 2 ** 8;
s.options.numBuffers = 2 ** 16;

//"LADSPA_PATH".setenv("/Applications/LMMS.app/Contents/lib/lmms/ladspa");
//LADSPA.listPlugins;  //should post a long list of plugins

s.options.numOutputBusChannels = 16;
s.options.numInputBusChannels = 8;
s.options.inDevice_("supercollider-in");
s.options.outDevice_("supercollider-out");
//s.options.blockSize = 128;
//s.options.hardwareBufferSize = 32;//128;//512;

s.recHeaderFormat = "WAV";
//s.recSampleFormat = "int24";

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
    TempoClock.default = LinkClock.new.latency_(s.latency).permanent_(true);
    //"load synthdefs...".inform;
    //(App.librarydir.standardizePath ++ "synthdefs/*.scd").loadPaths;
    //"load vst".inform;
    // raum.vst3 is blacklisted but the vst2 version is ok
    //VSTPlugin.search(Server.default, dir: ["/Library/Audio/Plug-Ins/raum"], options: (exclude: ["/Library/Audio/Plug-Ins/VST", "/Users/david/Library/Audio/Plug-Ins/VST"]), verbose:false);

    VSTPlugin.search(Server.default, 
        dir: ["/Library/Audio/Plug-Ins/VST3", "/Users/david/Library/Audio/Plug-Ins/VST3", "/Library/Audio/Plug-Ins/raum"], 
        options: (exclude: ["/Library/Audio/Plug-Ins/VST", "/Users/david/Library/Audio/Plug-Ins/VST"]), 
        verbose:false);

    if (\SCNvim.asClass.notNil) {
        //Server.default.doWhenBooted {
            \SCNvim.asClass.updateStatusLine(1, \SCNvim.asClass.port);
        //}
    };

    Module.libraryDir = "~/projects/InstrProxyLib/library/".standardizePath;
    T.tagDir = "~/projects/droptableuser/library/tag/".standardizePath;

    InstrProxy.colors.addAll(
      [
          Color(0.80594773292541, 0.4751119852066, 0.32443220615387),
          Color(0.62813115119934, 0.50460469722748, 0.42918348312378),
          Color(0.50277349948883, 0.55445058345795, 0.85384097099304),
          Color(0.60549101829529, 0.63466150760651, 0.86493694782257),
          Color(0.55233793258667, 0.65434362888336, 0.71119487285614),
          Color(0.77472245693207, 0.82329275608063, 0.75887560844421),
          Color(0.67403962612152, 0.74898204803467, 0.83484077453613),
          Color(0.43814084529877, 0.35949912071228, 0.8521347284317),
          Color(0.60353236198425, 0.85716576576233, 0.54857833385468),
          Color(0.84560143947601, 0.71142382621765, 0.53232064247131),
          Color(0.75822179317474, 0.58384845256805, 0.37344696521759),
          Color(0.46127707958221, 0.63891048431396, 0.49481935501099),
          Color(0.7760725736618, 0.79725716114044, 0.52006945610046),
          Color(0.61446368694305, 0.50829205513, 0.49966106414795),
          Color(0.74614992141724, 0.8588672876358, 0.77721869945526),
          Color(0.67358100414276, 0.74493434429169, 0.40996670722961)
      ].scramble
    );

});

)
