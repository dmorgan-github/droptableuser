/////////////////////////////////////////
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(1);

(
SynthDef(\oneshot_s, {

	var numChannels = 2;
	var buf = \buf.kr;
	var rate = \rate.kr(1);
	var frames = BufFrames.kr(buf);
	var start = \start.kr(0) * frames;
	var end = \end.kr(1) * frames;
	var dur = ((end-start)/44100) * rate.reciprocal;

	var phase = Env([0, start, end],[0, dur],0).ar(gate:1);
	var sig = BufRd.ar(numChannels, buf, phase, interpolation:4);
	var env = Env.linen(0, 1, 0).kr(gate:1, timeScale:dur, doneAction:Done.freeSelf);
	sig = sig * env * \amp.kr(-12.dbamp);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////////////
// oneshot
~p[\oneshot].clear;
~p[\oneshot].mold;
~p[\oneshot].play(vol:1);
~p[\oneshot].stop(fadeTime:5);


~oneshot_buffs = ();
/////////////////////////////////////////
// touchosc
(
var dir = PathName.new("/Users/david/projects/droptableuser/workspaces/ws2/");
var rows = 4;
var cols = 4;
dir.entries.do({arg pathname, i;
	var buf = Buffer.read(s, pathname.fullPath);
	var col = i % cols;
	var row = (i / rows).floor;
	var key = ('/1/buttons1/' ++ row ++ '/' ++ col).asSymbol;
	~oneshot_buffs[key] = buf;
});
)

(
Fdef('/1/buttons1', {arg row, col, val;
	var key = ('/1/buttons1/' ++ row ++ '/' ++ col).asSymbol;
	var buf = ~oneshot_buffs[key];
	if (val == 1) {
		if (buf.isNil.not) {
			Synth(\oneshot_s, [\buf, buf, \amp, 1])
		}
	}
})
)


/////////////////////////////////////////
// roli-blocks/midi
(
var start = 48;
var dir = PathName.new("/Users/david/projects/droptableuser/workspaces/ws2/");
dir.entries.do({arg pathname;
	if ( pathname.extension == "wav") {
		//pathname.fullPath.postln;
		var buf = Buffer.read(s, pathname.fullPath);
		var key = ('noteOn/' ++ start).asSymbol;

		Fdef(key, {
			Synth(\oneshot_s, [\buf, buf, \amp, 1])
		});
		start = start + 1;
	}
});
)