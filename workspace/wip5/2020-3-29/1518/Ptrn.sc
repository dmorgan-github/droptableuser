// degree, dur
Dd {
	*new{arg list, repeats=inf;

		^Routine({
			var parse = {arg seq, div=1;

				var myval = seq;
				if (myval.class != Ref) {
					// if the value is a ref don't unpack it here
					myval = myval.value;
				};

				if (myval.isArray) {
					var myseq = myval;
					var mydiv = 1/myseq.size * div;
					var stream = Pseq(myseq, 1).asStream;
					var val = stream.next;
					while ({val.isNil.not},
						{
							parse.(val, mydiv);
							val = stream.next
						}
					);
				} {
					if (myval.isRest) {
						myval = Rest();
						div = Rest(div);
					} {
						if (myval.isKindOf(Ref)) {
							// if the value is a Ref
							// unpack it and use as-is
							// this allows use to chords
							// and multi-channel expansion
							myval = myval.value;
						};
					};
					[myval, div].yield;
				}
			};

			var pseq = Pseq(list, repeats).asStream;
			inf.do({
				var val = pseq.next;
				parse.(val);
			});
		})
	}
}
