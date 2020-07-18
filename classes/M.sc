M : Ndef {

	var <map;
	var <slot;

	*new {arg key;
		var res;
		if (Ndef.all[key].isNil) {
			res = super.new(key).prMInit();
		} {
			res = Ndef.all[key];
		};
		^res;
	}

	prMInit {
		map = Order.new;
		slot = 0;
		this.wakeUp;
	}

	add {arg src, stop=false;

		var srcIndex = map.detectIndex({arg v; v == src});

		if (srcIndex.isNil) {
			srcIndex = slot;
			map.put(srcIndex, src);
			this.mix(srcIndex, Ndef(src));
			if (stop) {
				Ndef(src).stop;
			};
			slot = slot + 1;
		}
	}

	mgui {
		^U(\matrix, this)
	}
}

