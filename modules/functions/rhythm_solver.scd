(
var func = {arg target, divs, nums = [], pref;

	var returnVal, current;
	// no preference, equal weight
	var val = divs.choose;

	// prefer shorter values
	if (pref == \fast) {
		val = divs.sort.wchoose( (divs.size-1..0).normalizeSum );
	};

	// prefer longer values
	if (pref == \slow) {
		val = divs.sort.reverse.wchoose( (divs.size-1..0).normalizeSum );
	};

	if (val == target) {
		returnVal = [val];
	};

	current = sum(nums ++ [val]);
	if ( current == target ) {
		returnVal = nums ++ [val];
	} {
		if (current < target) {
			nums = nums ++ val;
			returnVal = func.value(target, divs, nums, pref);
		} {
			val = target - sum(nums);
			returnVal = nums ++ [val];
		}
	};

	returnVal;
};
~rhythm_solver = func;
)

