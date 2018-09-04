~bufs[\piano] = Buffer.read(s, "/Users/david/Downloads/171326__bradovic__piano-improvisation.wav");

/////////////////////////////////////////
// glitch_buf
~p[\glitch_buf].clear;
~p[\glitch_buf].mold;
(~p[\glitch_buf][0] = {

	var buf = ~bufs[\piano];//\buf.kr(0);
	var startPos = \start.kr(0);
	var loop = \loop.kr(1);

	var rev = Demand.kr(Dust.kr(1), 0, Drand([-1,1], inf));
	var sig = PlayBuf.ar(2, buf, rate:1 * rev, trigger:1, startPos: startPos, loop: 1);
	var which = Demand.kr(Impulse.kr(1), 0, Dxrand([0,1], inf));
	var env = Env([0,1,0], [0.1,0.5], 0);
	var index = SinOsc.kr(LFNoise2.kr(1/16).range(0.2,10)).range(0, env.times.sum);
	sig = sig * IEnvGen.kr(env, index);
	sig = SelectX.ar(which, [sig, Silence.ar]);

	sig = sig * \amp.kr(-12.dbamp) * 2;
	sig;
};
);
~p[\glitch_buf].play;
~p[\glitch_buf].stop;
~glitch_buf_win = App.guiHelper(~p[\glitch_buf], "glitch_buf");
~glitch_buf_win.front;