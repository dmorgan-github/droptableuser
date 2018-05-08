
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

~bufs = ~bufs ? ();

~bufManager = {

	var soundIn = NodeProxy.audio(s, 1).source_({
		Mix.ar(SoundIn.ar([0,1]));
	});

	var font = Font("Courrier new", 10);

	var win = View().layout_(VLayout().spacing_(2).margins_(2))
	.palette_(QPalette.dark);

	var view = View()
	.layout_(VLayout().spacing_(0).margins_(0));

	var bufferView = {

		var sfv = SoundFileView()
		.background_(Color.gray(0.3));

		sfv.timeCursorOn = true;
		sfv.timeCursorColor = Color.blue(alpha:0.5);
		sfv.setSelectionColor(0, Color.blue(alpha:0.5));
		sfv.gridResolution = 0.0;
		sfv;
	};

	var addRow = {

		var rec_buf;

		var bufnum = s.nextBufferNumber(1);

		var key = ('buf' ++ bufnum).asSymbol;

		var sfv = bufferView.();

		var durBox = NumberBox()
		.fixedWidth_(35)
		.font_(font)
		.stringColor_(Color.white)
		.normalColor_(Color.white)
		.action_({arg ctrl;
			rec.enabled = true;
			overdub.enabled = true;
		});

		var updatePlot = {arg buf;

			buf.loadToFloatArray(action: {arg array;
				{
					sfv.setData(array);
					sfv.minWidth_(200);
					sfv.minHeight_(100);
					durBox.value_(buf.duration);
				}.defer
			});
		};

		var onRec = {
			var bufdur = durBox.value;
			rec_buf = rec_buf ? ~recorder.(bufdur, soundIn, bufnum:bufnum);
			rec_buf.rec();
			~bufs[key] = rec_buf.buf;
			{
				updatePlot.(rec_buf.buf);
			}.defer(bufdur + 1);
		};

		var onRecStop = {
			rec_buf.end();
			updatePlot.(rec_buf.buf);
		};

		var onPlay = {
			rec_buf.buf.play;
		};

		var onPlayStop = {
		};

		var onRowRemove = {
			rec_buf.free;
			~bufs[key] = nil;
		};

		var onLoad = {arg buf;
			rec_buf = rec_buf ? ~recorder.(buf.duration, soundIn, buf);
			~bufs[key] = buf;
		};

		var onRename = {arg oldKey, newKey;
			~bufs[newKey.asSymbol] = ~bufs[oldKey.asSymbol];
			~bufs[oldKey.asSymbol] = nil;
		};

		var onOverdub = {
			rec_buf.ovrdub();
		};

		var onOverdubStop = {
			rec_buf.end();
			updatePlot.(rec_buf.buf);
		};

		var onBufLoad = {arg buf;
			updatePlot.(buf);
		};

		var play = Button().states_([
			[">"],
			["||"]
		])
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				onPlay.value();
			} {
				onPlayStop.value();
			}
		})
		.fixedWidth_(50)
		.font_(font)
		.enabled_(false);

		var rec = Button().states_([
			["o"],
			["||"]
		])
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				onRec.value();
			} {
				onRecStop.value();
				play.enabled = true;
			}
		})
		.fixedWidth_(50)
		.font_(font)
		.enabled_(false);

		var overdub = Button().states_([
			["^"],
			["||"]
		])
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				onOverdub.value();
			} {
				onOverdubStop.value();
				play.enabled = true;
			}
		})
		.fixedWidth_(50)
		.font_(font)
		.enabled_(false);

		var file = Button()
		.font_(font)
		.states_([ ["..."] ])
		.action_({arg ctrl;

			Dialog.openPanel({ arg path;
				Buffer.read(s, path, action:{arg buf;
					onBufLoad.(buf);
					{
						play.enabled = true;
						rec.enabled = true;
						overdub.enabled = true;
						durBox.enabled = false;
						onLoad.value(buf);
					}.defer(0.01);
				}, bufnum: bufnum);
			},{
				"cancelled".postln;
			});
		});

		var row = View().layout_(

			VLayout (
				HLayout(

					StaticText()
					.string_(bufnum)
					.font_(font)
					.maxWidth_(25),

					TextField()
					.value_(key)
					.minWidth_(50)
					.font_(font)
					.action_({arg ctrl;
						var newKey = ctrl.value;
						onRename.value(key, newKey);
						key = newKey.asSymbol;
					}),

					Button()
					.font_(font)
					.maxWidth_(15)
					.states_([ ["+"]])
					.action_({arg ctrl;
						addRow.();
					}),

					Button()
					.font_(font)
					.maxWidth_(15)
					.states_([ ["-"] ])
					.action_({arg ctrl;

						row.remove();
						onRowRemove.value();

						{
							//var sizeHint = view.sizeHint;
							//view.resizeTo(sizeHint.width, sizeHint.height);
							if (view.children.size == 0) {
								addRow.();
							}
						}.defer(0.01);
					}),

					durBox,
					rec,
					overdub,
					play,
					file

				).spacing_(1).margins_(1),
				sfv
			).spacing_(1).margins_(1)
		);

		view.layout.add(row);
	};

	addRow.();

	win.layout.add(view);
	win;//.alwaysOnTop_(true).front;
};


{
	(view:~bufManager.())
}.()



