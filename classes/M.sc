/*
Matrix
*/
M : Device {

	var <map;

	var <slot;

	var <outbus;

	deviceInit {
		map = Order.new;
		slot = 0;
		outbus = Bus.audio(Server.default, 2);
	}

	postInit {
		this.put(0, { InFeedback.ar(outbus.index, 2) });
	}

	view {
		^U(\matrix, this)
	}

	addSrc {|srcNode|

		var srcIndex = map.detectIndex({|v|
			//[\v, v, \srcNode, srcNode].debug(\m_addsrc);
			v.key == srcNode.key
		});
		if (srcIndex.isNil) {
			srcIndex = slot;
			//srcNode.parentGroup = this.group;
			srcNode.monitor.out = outbus.index;
			map.put(srcIndex, srcNode);
			slot = slot + 1;
		};
		this.changed(\add, srcNode);
	}

	removeSrc {|key|

		// TODO: does this destroy the node?
		map.keysValuesDo({|k, v|
			if (v.key == key) {
				map.do({|obj|
					if (obj.respondsTo(\removeAt)){
						obj.removeAt(k);
					};
					if (obj.respondsTo(\nodeMap)) {
						obj.nodeMap.removeAt(key);
					}
				});
				map.removeAt(k);
				this.changed(\remove, key);
			}
		});
	}

	/*
	*initClass {
		all = IdentityDictionary();
	}
	*/

	/*
	save {
		var settings = List.new;
		var parent = PathName(thisProcess.nowExecutingPath).parentPath;
		var ts = Date.getDate.asSortableString;
		var path = parent ++ this.key.asString ++ "_" ++ ts ++ ".txt";
		var file;

		this.map.do({arg val;

			//var node = Ndef(val.asSymbol);
			//var path = "";
			//node.save(path);

			/*
			var props = List.new;
			if (node.isKindOf(V) ) {
				props.add(\pdata -> node.pdata)
			}{
				node.controlNames.do({arg cn;
					props.add(cn.name.asSymbol -> node.get(cn.name.asSymbol));
				});
			};
			settings.add( val ->  props );
			*/
		});

		/*
		file = File(path, "w");
		file.write(settings.asCompileString);
		file.close;
		path.debug(\saving);
		*/
	}
	*/
}
