(

)


~perc = ~grid_player.();


/////////////////////////////////
// buffers
~bufs = ~bufs ? ();
~bufs[\darbuka] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc1/darbuka/darbuka pied soft.wav");
~bufs[\guiro] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc1/misc/guiro voix.wav");
~bufs[\linn_clap] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/LinnDrum LM-2/Normalized/Clap.aif");

/////////////////////////////////
// config player
//~perc = ~grid_player.();
~perc.dur = Pseq([0.5], inf).asStream;
(
var rateseq = Pseq([0.75, 1, 2, 4], inf).asStream;
~perc.events = [
	(instrument:\oneshot, buf:~bufs[\darbuka], amp:2, rate:1.3, pan: -0.5),
	(instrument:\oneshot, buf:~bufs[\guiro], amp:2, rate:{rateseq.next}, pan: 0.5),
	(instrument:\oneshot, buf:~bufs[\linn_clap], amp:{rrand(0.2,0.3)})
];
)
(
~perc.matrix = (0..4).collect({arg i;
	(0..32).collect({arg j;
		if (0.1.coin) {1} {0}
	})
});
)

/////////////////////////////////
// patch
~perckit = ProxySpace.new(s);
~perckit.quant = 4.0;
~perckit.clock = TempoClock.default;

/////////////////////////////////
// play
~perckit[\snd] = ~perc.player;
~perckit[\snd].play;
~perckit[\snd].stop










