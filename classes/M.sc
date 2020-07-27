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

	save {
		var settings = List.new;
		var parent = PathName(thisProcess.nowExecutingPath).parentPath;
		var ts = Date.getDate.asSortableString;
		var path = parent ++ this.key.asString ++ "_" ++ ts ++ ".txt";
		var file;

		this.map.do({arg val;
			var props = List.new;
			var node = Ndef(val.asSymbol);
			if (node.isKindOf(Vst) ) {
				props.add(\pdata -> node.pdata)
			}{
				node.controlNames.do({arg cn;
					props.add(cn.name.asSymbol -> node.get(cn.name.asSymbol));
				});
			};
			settings.add( val ->  props );
		});

		file = File(path, "w");
		file.write(settings.asCompileString);
		file.close;
		path.debug(\saving);
	}
}

