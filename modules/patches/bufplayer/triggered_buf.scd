/////////////////////////////////////////
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(1);


/////////////////////////////////////////
// bufplay
~p[\bufplay].clear;
~p[\bufplay].mold;
(~p[\bufplay][0] = {

	var numChannels = 2;
	var trig = \trig.tr(0);
	var buf = \buf.kr;
	var rate = \rate.kr(1);
	var frames = BufFrames.kr(buf);
	var start = \start.kr(0) * frames;
	var end = \end.kr(1) * frames;
	var dur = ((end-start)/44100) * rate.reciprocal;

	var phase = Env([0, start, end],[0, dur],0).ar(gate:trig);
	var sig = BufRd.ar(numChannels, buf, phase, interpolation:4);
	var env = Env.linen(0, 1, 0).kr(gate:trig, timeScale:dur);
	sig = sig * env * \amp.kr(-12.dbamp);
	Balance2.ar(sig[0], sig[1], \pan.kr(0));
});
//~p[\bufplay].set(\buf, ~bufs[\noise2], \start, 0.21, \end, 0.212, \rate, 0.05, \trig, 1);
~p[\bufplay].play(vol:1);
~p[\bufplay].stop(fadeTime:5);
~p[\bufplay].gui;
~p[\bufplay].set(\trig, 1);
~p[\bufplay].set(\rate, 1);



(
var start = '48';
var dir = PathName.new("/Users/david/projects/droptableuser/workspaces/ws2/");
dir.entries.do({arg pathname;
	if ( pathname.extension == "wav") {
		//pathname.fullPath.postln;
		var buf = Buffer.read(s, pathname.fullPath);

		Fdef('noteOn/51', {
			~p[\bufplay].set(\trig, 1, \buf, buf)
		})
	}
});
)

(
Fdef('noteOn/51', {
	~p[\pmosc].set(\trig, 1)
})
)


