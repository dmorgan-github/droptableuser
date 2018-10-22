(
a = { (0..30).scramble }.dup(2).plot;
a.superpose = true;

a.setProperties(
	\font, Font("Times New Roman", 12), // Font("Arial", 12),
	\fontColor, Color.cyan,
	\plotColor, [Color.green(0.8), Color.red(0.8)],
	\backgroundColor, Color.grey(0.1, 0.9),
	\gridColorX, Color.white,
	//\gridColorX, Color.yellow,
	\gridColorY, Color.grey,
	//\gridLinePattern, // I do not know how to use it.
	\gridLineSmoothing, true,
	\labelX, "x", // I do not know how to display it on the plooter window.
	\labelY, "y", // I do not know how to display it on the plooter window.
	\gridOnX, true,
	\gridOnY, true
);

a.refresh;
)