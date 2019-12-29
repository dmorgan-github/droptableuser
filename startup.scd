(
thisProcess.platform.recordingsDir_("/Users/david/projects/droptableuser/workspaces");

s.options.memSize_(2 ** 18);
s.options.numAudioBusChannels = 1024 * 2;
s.options.numWireBufs = 2 ** 7;

// for superdirt
s.options.numBuffers = 1024 * 16;

"LADSPA_PATH".setenv("/Applications/LMMS.app/Contents/lib/lmms/ladspa");
//LADSPA.listPlugins;  //should post a long list of plugins

Font.setDefault(Font("Courier New", 10));

s.options.numOutputBusChannels = 2; // 24
s.options.inDevice_("supercollider-in");

//s.options.outDevice = "JackRouter";
s.options.outDevice_("supercollider-out");

s.waitForBoot({

	File.open("/Users/david/projects/scynapse/_main.scd", "r").readAllString.interpret;
	MIDIClient.init;
	MIDIClient.initialized.debug("midi initialized");
	//MIDIIn.connectAll;
	Pdef.defaultQuant_(1);

	{
		// load synthdefs
		var pathname = PathName.new("/Users/david/projects/scynapse/_synthdefs/");
		pathname.files.do({arg pn;
			File.open(pn.fullPath, "r").readAllString.interpret;
		});
	}.();

	// trigger bitwig record
	//m = NetAddr("127.0.0.1", 8000); // loopback
	//m.sendMsg("/record");

	// mini preprocessor to generate id values
	{
		var func = {arg code;
			if (code == "scid") {
				var id = ("\\" ++ App.idgen).asSymbol;
				code = code.replace("scid", id);
				Document.current.selectedString_(id);
			};
			code;
		};
		this.preProcessor = func;
	}.();
})
)