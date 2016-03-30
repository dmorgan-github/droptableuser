(
/*
accumulative
1,
1, 2,
1, 2, 3,
1, 2, 3, 4
*/
var result = List.new;
var func = {arg level = 1, max = 4;

	level.do({arg i;
		var num = i + 1;
		result.add(num);
	});

	if (level < max) {
		func.value(level + 1);
	};
};
func.value(1, 4);
result.debug;
)

(
/*
accumulative repetitive
1
1 22
1 22 333
1 22 333 4444
*/
var result = List.new;
var func = {arg level = 1, max = 4;

	level.do({arg i;
		var num = i + 1;

		num.do({arg k;
			result.add(num)
		});
	});

	if (level < max) {
		func.value(level + 1);
	};
};
func.value(1, 4);
result.debug;
)

(
/*
accumulative repetitive accumulative
1
1 12 12
1 12 12 123 123 123
1 12 12 123 123 123 1234 1234 1234 1234
*/
var result = List.new;
var func = {arg level = 1, max = 4;

	level.do({arg i;
		var num = i + 1;

		num.do({arg k;
			num.do({arg j;
				result.add(j + 1)
			})
		});
	});

	if (level < max) {
		func.value(level + 1);
	};
};
func.value(1, 4);
result.debug;
)

(
/*
accumulative accumulative repetitive accumulative
1
1 1 12 1 12
1 1 12 1 12 1 12 123 1 12 123 1 12 123
*/
var result = List.new;
var func = {arg level = 1, max = 4;

	level.do({arg i;
		var num = i + 1;

		num.do({arg k;
			num.do({arg j;
				var num2 = j + 1;
				num2.do({arg n;
					result.add(n + 1);
				});
			});
		});
	});

	if (level < max) {
		func.value(level + 1, max);
	};
};
func.value(1, 3);
result.debug;
)


(
/*
accumulative palindome

1,
1, 2, 1,
1, 2, 3, 2, 1,
1, 2, 1,
1
*/
var result = List.new;
var func = {arg level = 1, max = 4, step = 1;

	var temp = List.new;
	level.do({arg i;
		var num = i + 1;
		temp.add(num);
	});
	result.add(temp.mirror);

	// handle forward and reverse
	// is there a more clever way to do this
	if (level == max) {
		func.value(level -1, max, -1);
	};
	if ( (step == -1) && (level > 0) ) {
		func.value(level + step, max, -1);
	};
	if ( (step == 1) && (level < max) ) {
		func.value(level + step, max, 1);
	};
};
func.value(1, 5);
result.flatten.debug;
result = result.flatten;
)

