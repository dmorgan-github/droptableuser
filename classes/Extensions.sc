+ Array {
	pseq { ^Pseq(this, inf) }
	prand { ^Prand(this, inf) }
	pwrand { ^Pwrand(this[0], this[1], inf)}
	place { ^Ppatlace(this, inf)}
	// Pindex
}

+ Pattern {
	take {arg num; ^Pfin(num, this.iter) }
}