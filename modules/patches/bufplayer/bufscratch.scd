
~os = ProxySpace.new(s);
~os.quant = 1.0;

~noise_buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/windows-system-samples/clbcatq.wav");

(~os[\bufrd][0] = {
	var buf_in = ~noise_buf;
	var phase = LFNoise1.ar(0.04) * BufFrames.ir(~noise_buf);
	var sig = BufRd.ar(1, buf_in, phase, interpolation:4);
	Splay.ar(sig);
})

~os[\bufrd].play(fadeTime:8);
~os[\bufrd].stop(fadeTime:10);
~os[\bufrd].vol = 0.15;
(~os[\bufrd].filter(4, {arg in;
	JPverb.ar(in);
}));
~os[\bufrd].set(\wet4, 0.3);


