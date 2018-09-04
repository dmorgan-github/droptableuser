~kit_player = ~grid_player.();



/////////////////////////////////
// buffers
~bufs = ~bufs ? ();
~bufs[\kik] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/BassDrum/KickDrum0001.aif");
~bufs[\sn] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/SnareDrum/SnareDrum0001-2.aif");
~bufs[\clav] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Clav.aif");
~bufs[\hiconga] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Hi Conga/Hi Conga0001.aif");
~bufs[\ch] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Cls'd Hihat/Closed Hihat0001.aif");
~bufs[\mc] =  Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Mid Conga/Mid Conga0001.aif");

/////////////////////////////////
// config player
//~perc = ~grid_player.();
~kit_player.dur = Pseq([0.25], inf).asStream;
(
~kit_player.events = [
	(instrument:\oneshot, buf:~bufs[\kik], amp:0.8),
	(instrument:\oneshot, buf:~bufs[\sn], amp:0.5, rate:1),
	(instrument:\oneshot, buf:~bufs[\clav], amp:{rrand(0.1,0.2) * 1}, pan: -0.8, rate:0.5),
	(instrument:\oneshot, buf:~bufs[\hiconga], amp:0.5, pan: 0.8),
	(instrument:\oneshot, buf:~bufs[\ch], amp:0.18)
];
)

(
~kit_player.matrix = [
	[1,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,1,0],
	[0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0],
	[0,0,0,0, 0,0,0,1, 0,0,1,0, 0,0,0,0],
	[0,0,0,0, 0,0,0,0, 0,1,0,0, 0,0,0,0,0],
	[0,0,1,0, 0,0,1,0, 0,0,1,0, 0,1,0,0]
];
)

(
~kit_player.matrix = ~kit_player.matrix.collect({arg row;
	if (0.1.coin){
		(0..15).collect({arg i; if (0.1.coin) {1}{0} })
	} {
		row
	}
});
)

(
~kit_player.matrix = (0..4).collect({arg i;
	(0..32).collect({arg j;
		if (0.1.coin) {1} {0}
	})
});
)

/////////////////////////////////
// patch
~gridkit = ProxySpace.new(s);
~gridkit.quant = 4.0;
~gridkit.clock = TempoClock.default;

/////////////////////////////////
// play
~gridkit[\snd] = ~kit_player.player;

(~gridkit[\snd][4] = \filter -> {arg in;

	var input, numsamp, power;
	var sig = in;

	sig = Decimator.ar(sig, 44100/8, LFDNoise3.kr(1/3).range(8,12));//}.dup(4).sum;
    numsamp = 300;
	power = 4;//SinOsc.kr(1/4).range(0.1, 4);
	//sig = (RunningSum.ar(sig ** power, numsamp)/numsamp) ** (power.reciprocal);
	sig = RunningSum.rms(sig, 20);
	//sig = FreqShift.ar(sig, 100);

	sig;
});

(~gridkit[\snd].filter(6, {arg in;
	JPverb.ar(in);
}).set(\wet6, 0.4))

~gridkit[\snd].set(\wet4)

~gridkit[\snd].vol = 1;
~gridkit[\snd].play;
~gridkit[\snd].stop


App.defaultOut(s);
App.soundflowerOut(s);





