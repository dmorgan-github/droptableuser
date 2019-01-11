(
thisProcess.platform.recordingsDir_("/Users/david/projects/droptableuser/workspaces");

//s.options.memSize = 256 ** 2;
s.options.memSize_(65536 * 4);
//s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 16;

s.options.numAudioBusChannels = 1024 * 2;

s.options.numWireBufs = 2 ** 7;

// for superdirt
s.options.numBuffers = 1024 * 16;

"LADSPA_PATH".setenv("/Applications/LMMS.app/Contents/lib/lmms/ladspa");
//LADSPA.listPlugins;  //should post a long list of plugins

Font.setDefault(Font("Courier New", 10));

s.options.numOutputBusChannels = 16;
s.options.inDevice_("supercollider-in");
s.options.outDevice_("supercollider-out");

s.waitForBoot({

	~bufs = ();

	/////////////////////////////////////////
	// proxy space
	~p = ~p ? ProxySpace.new(s, \p);
	~p.quant = 4.0;
	~p.fadeTime = 2;
	~p.clock = TempoClock.default.tempo_(60/60);

	"~p proxy space initialized".postln;

	//SuperDirt.stop;
	//SuperDirt.start;
})
)