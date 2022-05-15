Udef(\rainLF, {
	URandSeed.ir();
	UOut.ar(0,GVerb.ar(
		LPF.ar(
     			10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(3).clip(0,1)*LFNoise1.kr(2).clip(0,1) ** 1.8), 20),
     			LFNoise1.kr(1).exprange(100,2500)
		).tanh,
    	270,30,0.7,drylevel:0.5))
})
.category_(\synthesis)