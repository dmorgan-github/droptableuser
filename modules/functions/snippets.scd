(
DDWSnippets.put("proxy", "
p = p ? ProxySpace.new(s, \p);
p.quant = 1.0;
");
)

(
DDWSnippets.put("jpverb", "
(p[\\##name##] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in,
        \\t60.kr(1),
        \\damp.kr(0),
        \\size.kr(1),
        \\earlyDiff.kr(0.707),
        \\modDepth.kr(0.1),
        \\modFreq.kr(2));
	fx;
})
");
)

