/////////////////////////////////////////
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(1);


~bufs[\drone] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws6/hybrid3.wav");
~bufs[\noise] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws6/in-sc.wav");
~bufs[\noise2] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/windows-system-samples/cdosys.dll.wav");

/////////////////////////////////////////
// bufplay
~p[\bufplay].clear;
~p[\bufplay].mold;
(~p[\bufplay][0] = {

	var trig = \trig.tr(0);
	var buf = \buf.kr();
	var rate = \rate.kr(1);
	var frames = BufFrames.kr(buf);
	var start = \start.kr(0) * frames;
	var end = \end.kr(1) * frames;
	var dur = ((end-start)/44100) * rate.reciprocal;

	var phase = Env([0, start, end],[0, dur],0).ar(gate:trig);
	var sig = BufRd.ar(1, buf, phase, interpolation:4);
	var env = Env.linen(0, 1, 0).kr(gate:trig, timeScale:dur);
	Pan2.ar(sig, \pan.kr(0)) * env;
});
~p[\bufplay].set(\buf, ~bufs[\noise2], \start, 0.21, \end, 0.212, \rate, 0.05, \trig, 1);
~p[\bufplay].play(vol:1);
~p[\bufplay].stop(fadeTime:5);
~p[\bufplay].gui;
~p[\bufplay].set(\trig, 1);
~p[\bufplay].set(\rate, 1);

Env.linen(0, 1, 0).plot(minval:0, maxval: 2)

/////////////////////////////////////////
// bufplay2
~p[\bufplay2].clear;
~p[\bufplay2].mold;
(~p[\bufplay2][0] = {

	var trig = \trig.tr(0);
	var buf = ~bufs[\noise];
	var dur = BufFrames.kr(buf.bufnum)/44100;
	var frames = BufFrames.kr(buf.bufnum);
	var phase = Env([0,0,frames],[0,dur],0).ar(gate:trig);
	var sig = BufRd.ar(2, buf, phase , loop:0, interpolation:4);
	sig;// * env;
});
~p[\bufplay2].play(vol:0.1);
~p[\bufplay2].stop(fadeTime:5);
~p[\bufplay2].gui;
~p[\bufplay2].set(\trig, 1)


