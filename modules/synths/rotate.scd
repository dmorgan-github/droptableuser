(
~rotate = {arg chans = 1;

	{
		var in = \in.ar(0.dup(chans));
		var x, y;
		#x, y = Rotate2.ar(in[0], in[1], LFSaw.kr(\rate.kr(0.1)));
		[x,y];
	};
};
)
