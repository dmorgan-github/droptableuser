(
~markov = {arg matrix;

	Routine({

		//var node = matrix[0].choose;
		var node = matrix.choose;
		node[0].value().yield;
		while({node[1].notNil}, {

			var next = node[1]
			.collect({arg item;
				item.value;
			}).normalizeSum.windex;

			var index = node[1][next].key;
			node = matrix[index];
			node[0].value().yield;
		});
	});
};

~pmarkov = {arg matrix;

	Routine({arg inval;

		var node = matrix.choose;
		node[0].value().embedInStream(inval);
		while({node[1].notNil}, {

			var next = node[1]
			.collect({arg item;
				item.value;
			}).normalizeSum.windex;

			var index = node[1][next].key;
			node = matrix[index];
			node[0].embedInStream(inval);
		});
	});
};

~constrainToSize = {arg m, limit;

	var result = List.new;
	while({result.size < limit}, {
		var val = m.next();
		result.add(val);
	});
	result;
};

~constrainToTally = {arg m, limit;

	var tally = 0;
	var result = List.new;
	var continue = true;
	var val = m.next();

	result.add(val);
	tally = tally + val;
	while({continue}, {
		val = m.next();
		tally = tally + val;
		if (tally > limit, {
			var diff = tally - limit;
			val = val - diff;
			if (val > 0, {
				result.add(val);
			});
			continue = false;
		}, {
			result.add(val);
		});
	});
	result;
};

~rewrite = {arg context, rules, level = 1;

	if (level > 0, {

		var result = "";
		context.do({arg val;

			var rule = rules.at(val.asString);
			result = result ++ rule.value(val.asString);
		});
		~rewrite.(result, rules, level - 1);
	}, {
		context;
	});
};
)

//Quarks.gui
//ContextSnake