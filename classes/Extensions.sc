+ Array {
	pseq {arg repeats=inf, offset=0; ^Pseq(this, repeats, offset) }
	prand {arg repeats=inf; ^Prand(this, repeats) }
	pwrand {arg weights, repeats=inf; ^Pwrand(this, weights, repeats)}
	place {arg repeats=inf, offset=0; ^Ppatlace(this, repeats, offset)}
}

+ Pattern {
	take {arg num; ^Pfin(num, this.iter) }
}