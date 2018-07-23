/*
major/diatonic
0  1  2  3  4  5  6  7  8  9  10  11  12  13
c  d  e  f  g  a  b  c  d  e  f   g   a   b
0, 2, 4, 5, 7, 9, 11 0, 2, 4, 5,  7,  9,  11
*/

(
var circle = (
	\first: [0, 2, 4],
	\fifth: [4, 6, 8],
	\second: [1, 3, 5],
	\sixth: [5, 7, 9],
	\third: [2, 4, 6],
	\seventh: [6, 8, 10],
	\fourth: [3, 5, 7],
);
Library.put(\circle, circle);
)
