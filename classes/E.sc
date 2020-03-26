
/*
OrderedIdentitySet.new

(
var envir, order;
order = OrderedIdentitySet();
envir = EnvironmentRedirect(());
envir.dispatch = {arg key, val;
	order.remove(key);
	order.add(key);
};

envir.use {
	~a = 1;
	~b = 2;
	~c = 3;
};

order.postln;
order.do {
	|k|
	"% -> %".format(k, envir[k]).postln;
}
)
*/
E : IdentityDictionary {

	var <order;

	*newFromAssociationArray{arg arr, recursive = true;
		var result = this.new;
		if(recursive, {
			if(arr.isTrulyAssociationArray, {
				arr.do({arg assoc;
					var val = assoc.value;
					if(val.isKindOf(SequenceableCollection) and: {val.isTrulyAssociationArray}, {
						val = this.newFromAssociationArray(assoc.value);
					}, {
						val = assoc.value;
					});
					result.put(assoc.key, val);
				});
			});
		}, {
			if(arr.isTrulyAssociationArray, {
				arr.do({arg assoc;
					result.put(assoc.key, assoc.value);
				});
			});
		});
		^result;
	}

	put{| key, value |
		if(this.includesKey(key).not, {
			order = order.add(key);
		});
		^super.put(key, value);
	}

	keysValuesArrayDo { | argArray, function |
		var arr;
		if(this.isEmpty.not, {
			arr = [
				order,
				order.collect({| item | this.at(item); })
			].lace;
			super.keysValuesArrayDo(arr, function);
		});
	}

	keys { | species(Array) |
		^super.keys(species);
	}

	values {
		var list = List.new(size);
		this.do({ | value | list.add(value) });
		^list
	}

	sorted{
		var result = this.class.new(size);
		order.sort.do({| item |
			result.put(item, this.at(item));
		});
		^result;
	}

	//adding additional check for equal order
	== {| what |
		var result = super == what;
		if(result.not, { ^false; });
		if(order != what.order, {^false;});
		^true;
	}

	removeAt{| key |
		if(order.includes(key), {
			order.remove(key);
		});
		^super.removeAt(key);
	}

	first{
		^this.at(this.order.first);
	}
}