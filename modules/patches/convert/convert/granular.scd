
~grain_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc2/misc/metal tray hit with medium tail.wav");

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

(
~granulator = {arg buf;

	{
		//middle C is the original playback rate
        //\rate, (nn-60).midiratio
		var trig = \trig.tr;
		var buf_in = \buf.kr(buf);
		var pos = \pos.kr(0.1);
		var graindur = \graindur.kr(0.5);
		var rate = \rate.kr(1);
		var envbuf = \envbuf.kr(-1).lag(0.01);
		var pan = \pan.kr(0);
		var grainamp = \grainamp.kr(1);

		var amp = Dwhite(grainamp.clip(0,1), 1, inf);
		var panValue = Dwhite(pan.neg, pan, inf);//SinOsc.kr(10).range(pan.neg,pan);
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

		sig;
	};
};
)

~p[\grain_trig] = {Impulse.kr(\rate.kr(1))};
~p[\grain_trig].gui

(~p[\grain_env] = {
	Demand.kr(Dust.kr(1), 0, Drand([
		~envbuf[\welch].bufnum,
		~envbuf[\perc].bufnum,
		~envbuf[\hamming].bufnum,
		~envbuf[\blackman].bufnum
	], inf));
});

~p[\grain_pos] = ~lfo.(wave:\noise, freq:1/4, min:0, max:1);
~p[\grain_rate] = {Demand.kr(Dust.kr(1), 0, Drand([0.75, 1, 1.25, 2], inf));};

~p[\grain][0] = ~grainsynth.(buf:~grain_buf);
(~p[\grain].set(\trig, ~p[\grain_trig],
	\envbuf, ~p[\grain_env],
	\pos, ~p[\grain_pos],
	\rate, ~p[\grain_rate] )
)
~p[\grain].play;
~p[\grain].stop

~p[\grain_verb] = ~jpverb.(chans:~p[\grain].numChannels);
~p[\grain_verb] <<> ~p[\grain];
~p[\grain_verb].set(\wet, 0.6, \t60, 20, \size, 3)
~p[\grain_verb].play
~p[\grain_verb].stop

~p[\grain_sum] = ~splay.(chans:~p[\grain_verb].numChannels);
~p[\grain_sum] <<> ~p[\grain_verb]

~p[\grain_delay] = ~delayorama.(chans:~p[\grain_sum].numChannels);
~p[\grain_delay] <<> ~p[\grain_sum];
~p[\grain_delay].play
~p[\grain_delay].gui



