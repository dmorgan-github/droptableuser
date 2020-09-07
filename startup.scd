(
thisProcess.platform.recordingsDir_("~/Documents/supercollider/workspaces".standardizePath);

s.options.memSize_(2 ** 18);
s.options.numAudioBusChannels = 1024 * 2;
s.options.numWireBufs = 2 ** 7;

// for superdirt
s.options.numBuffers = 1024 * 16;

"LADSPA_PATH".setenv("/Applications/LMMS.app/Contents/lib/lmms/ladspa");
//LADSPA.listPlugins;  //should post a long list of plugins

Font.setDefault(Font("Courier New", 10));

s.options.numOutputBusChannels = 24;
s.options.inDevice_("supercollider-in");

//s.options.outDevice = "JackRouter";
s.options.outDevice_("supercollider-out");
s.recHeaderFormat = "WAV";

s.waitForBoot({

	MIDIClient.init;
	MIDIClient.initialized.debug("midi initialized");
	Pdef.defaultQuant_(1);

	(
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
	)
})
)