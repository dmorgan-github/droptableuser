// distortion
(
var sig, amount, amCoef;
sig = HPF.ar(in, 400)*5;
amount = 0.99;
amCoef= 2*amount/(1-amount);
MidEQ.ar(LPF.ar((1+amCoef)*sig/(1+(amCoef*sig.abs)), [3800, 3900])*0.5, 120, 0.7, 8);
)