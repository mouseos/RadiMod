// LUFS metering (without channel weighting)
Tg = 3; // 3 second window for 'short-term' measurement

//envelope via lp by Dario Sanphilippo
lp1p(cf, x) = fi.pole(b, x * (1 - b)) with {
    b = exp(-2 * ma.PI * cf / ma.SR);
};
zi_lp(x) = lp1p(1 / Tg, x * x);


// one channel
Lk(L,R) = lufs
with{
LL=L:kfil: zi_lp ;
RL=R:kfil: zi_lp ;
lufs=LL+RL:10 * log10(max(ma.EPSILON)) : -(0.691);
};
// N-channel
LkN = par(i,Nch,kfil : zi_lp) :> 10 * log10(max(ma.EPSILON)) : -(0.691);

// N-channel by Yann Orlarey
lufs_any(N) = B <: B, (B : Lk : vbargraph("LUFS S",-40,0)) : si.bus(N-1), attach(_,_)
    with { 
        B = si.bus(N); 
        
    };




