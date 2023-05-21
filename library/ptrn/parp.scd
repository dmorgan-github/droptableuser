(
func: {

    var obj = (
        notes: Order.new
    );

    var algo = ~algo.debug("algo");

    obj[\ptrn] = Pbind(
        \midinote, Plazy({
            var vals = obj['notes'].indices;
            if (algo.notNil) {
                vals = vals.perform(algo.asSymbol);
            };
            if (vals.size == 0) {
                Rest(1)
            }{
                Pseq(vals, 1)
            }
        }).repeat,
        \dur, 0.25
    );

    obj;
}
)
