(
~markov = {arg matrix, first = nil;

	Routine({

		var node;
		if (first == nil, {
			node = matrix.choose;
		}, {
			node = matrix[first];
		});

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

/*
Lindenmayer
a = ~rewrite.("AC", Dictionary[
	"A" -> {"ABC"},
	"B" -> {"AB"},
	"C" -> {"BCD"},
	"D" -> {"CD"}
], 5 );
*/
~rewrite = {arg context, rules, level = 1;

	if (level > 0, {

		var result = "";
		context.do({arg val;

			var rule = rules.at(val.value.asString);
			result = result ++ rule.value(val.value.asString);
		});
		~rewrite.(result, rules, level - 1);
	}, {
		context;
	});
};
)