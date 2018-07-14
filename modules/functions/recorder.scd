~recorder = {arg dur, src, buf=nil, bufnum=nil;

	var numChannels = src.numChannels;
	var frames = dur * s.sampleRate;
	var buffer = buf ? Buffer.alloc(s, frames, numChannels, bufnum:bufnum);

	var node = NodeProxy.new(s).source_({

		var in = src.ar;
		var buf = \buf.kr(buffer.bufnum);
		var rec = \rec.kr(0);
		var renv = Env.asr.kr(gate:rec);
		var penv = Env.asr.kr(gate:rec) * \plevel.kr(0);

		RecordBuf.ar(in,
			buf,
			recLevel:renv,
			preLevel:penv,
			run:rec,
			loop:\rec_loop.kr(0),
			trigger:\rec_trig.kr(1)
		);

		Silence.ar;
	});

	var obj = (

		buf: buffer,

		node: node,

		isRecording: false,

		rec: {arg self;
			"rec".debug("recorder");
			self.node.set(\rec, 1, \rec_trig, 1, \plevel, 0);
			self.isRecording = true;
		},

		ovrdub: {arg self;
			"ovrdub".debug("recorder");
			self.node.set(\rec, 1, \rec_trig, 1, \plevel, 1);
			self.isRecording = true;
		},

		punch: {arg self;
			"punch".debug("recorder");
			self.node.set(\rec, 1, \plevel, 1);
			self.isRecording = true;
		},

		end: {arg self;
			"end".debug("recorder");
			self.node.set(\rec, 0, \rec_trig, 0);
			self.isRecording = false;
		},

		free: {arg self;
			"free".debug("recorder");
			self.buf.free;
			self.node.free;
			self.isRecording = false;
		}
	);

	obj;
};