/////////////////////////////////
// envelope buffers
(
var blackman = {arg size = 2048;

	var sig, alpha, a0, a1, a2;
	alpha = 0.16;
	sig = Signal.newClear(size);

	a0 = 0.5*(1-alpha);
	a1 = 0.5;
	a2 = alpha*0.5;

	sig.waveFill( { arg x, i; a0 - (a1*cos( (2*pi*x)/(size-1) ) ) + (a2*cos( (4*pi*x)/(size-1) ) )}, 0, size );
	sig;
};

var windowSize = 1024;

~envbuf = (
	hanning: Buffer.sendCollection(s, Signal.hanningWindow(windowSize), 1),
	hamming: Buffer.sendCollection(s, Signal.hammingWindow(windowSize), 1),
	welch: Buffer.sendCollection(s, Signal.welchWindow(windowSize), 1),
	rectangle: Buffer.sendCollection(s, Signal.rectWindow(windowSize), 1),
	perc: Buffer.sendCollection(s, Env.perc.asSignal(windowSize), 1),
	triangle: Buffer.sendCollection(s, Env.triangle.asSignal(windowSize), 1),
	blackman: Buffer.sendCollection(s, blackman.(windowSize), 1)
);
)

/////////////////////////////////
// buffers
~grain_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/vox/OpenPathMusic44V5/child-imitate-owl.wav");
~grain_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc2/misc/metal tray hit with medium tail.wav");
~grain_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/vox/OpenPathMusic44V5/voice-womanMA-37.wav");
~grain_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/foley/papercrumple.mono.aiff");

/////////////////////////////////
// patch
~gran = ProxySpace.new(s);
~gran.quant = 1.0;

~gran[\grain_trig] = {Impulse.kr( LFNoise2.kr(1/8).range(1,4) )};

(~gran[\grain_env] = {
	Demand.kr(Dust.kr(1), 0, Drand([
		~envbuf[\welch].bufnum,
		~envbuf[\perc].bufnum,
		~envbuf[\hamming].bufnum,
		~envbuf[\blackman].bufnum
	], inf));
});

~gran[\grain_pos] = {LFDNoise3.kr(1/4).range(0,1);};// ~lfo.(wave:\noise, freq:1/4, min:0, max:1);
//~gran[\grain_rate] = {Demand.kr(Dust.kr(1), 0, Drand([0.75, 1, 1.25, 2], inf));};
~gran[\grain_rate] = {Demand.kr(Dust.kr(1), 0, Drand(Scale.kumoi.ratios, inf) );};

/////////////////////////////////
// synth
(~gran[\snd][0] = {

	//middle C is the original playback rate
	//\rate, (nn-60).midiratio
	var trig = \trig.tr;
	var buf_in = \buf.kr(0);
	var pos = \pos.kr(0.1);
	var graindur = \graindur.kr(0.5);
	var rate = \rate.kr(1);
	var envbuf = \envbuf.kr(-1).lag(0.01);
	var pan = \pan.kr(0);
	var grainamp = \grainamp.kr(1);

	var amp = Dwhite(grainamp.clip(0,1), 1, inf);
	var panValue = Dwhite(pan.neg, pan, inf);
	var reverse = \reverse.kr(0);
	var rev = Dwrand([-1,1], [reverse,1-reverse], inf);

	var sig = GrainBufJ.ar(2,
		trig,
		dur: graindur,
		sndbuf: buf_in,
		rate: rate * rev,
		pos: pos,
		loop: 0,
		interp: 4,
		grainAmp: amp,
		pan: panValue,
		envbufnum: envbuf
	);

	Splay.ar(sig);
})

/////////////////////////////////
// settings
(~gran[\snd].set(
	\buf, ~grain_buf,
	\trig, ~gran[\grain_trig],
	\envbuf, ~gran[\grain_env],
	\pos, ~gran[\grain_pos],
	\rate, ~gran[\grain_rate],
	\reverse, 0.5
)
)

/////////////////////////////////
// fx
(~gran[\snd][4] = \filter -> {arg in;
	JPverb.ar(in, t60:20, size:3);
})
(~gran[\snd][50] = \filter -> {arg in;
	Limiter.ar(in, 0.7)
})
~gran[\snd].set(\wet4, 0.6)

/////////////////////////////////
// play
~gran[\snd].play;
~gran[\snd].stop;
~gran[\snd].vol = 1;






