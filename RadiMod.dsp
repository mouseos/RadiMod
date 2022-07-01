import("stdfaust.lib");
import("mpx.dsp");
import("ctrl.dsp");
import("loudness.dsp");
import("maxmsp.lib");


process=loudness_in:
vu_meter(input),_:fi.highpass(3,30),fi.highpass(3,30):phase2:stg(AGCdrive):agc:
eqst:
stg(MBdrive):mb_comp:stg(FinalDrive) :itu1770_limiter_stereo(114514,FinalLoudness,0,0):loudness_out:pre_emph50_st:
final_limit:(vu_meter(output),_);
//pre emph 50μs
pre_emph50(x)=((high+x),x):select2(pre_emph_on)
with{
high=x-(x:fi.lowpass(1,2000));
};
pre_emph50_st=pre_emph50,pre_emph50;
//final limit
final_limit(x,y)=cgm:(_*x,_*y)
with{
    cgm=compST(10000, FinalThr, 0/1000, 50/1000, 0, 0,x,y):meter(final_gr),_;
};

//itu 1770 loudness limiter
itu1770_limiter_stereo(ratio,thresh,att,rel,x,y) = cgm * x, cgm * y 
    with {
        cgm = compression_gain_mono(ratio, thresh, att, rel,(Lk(x,y):ba.db2linear) ):meter(final_loudness_gr);
    };



//stereogain
stg(gain,x,y)=x*(ba.db2linear(gain)),y*(ba.db2linear(gain));
//phase rotate
APFSt(F,Q) = APF(_,F,0,Q),APF(_,F,0,Q);
apfs=APFSt(200,1);
phase=
apfs:apfs:apfs

;

phase2=seq(i,1,apfs);

//rms
RMS(time) = (ba.slidingRMSp((ba.sec2samp(time)),2048));



//k-filter by Julius Smith
highpass = fi.highpass(2, 40);
boostDB = 4;
boostFreqHz = 1430; // a little too high - they should give us this!
highshelf = fi.high_shelf(boostDB, boostFreqHz); // Looks very close, but 1 kHz gain has to be nailed
kfil = highshelf : highpass;




//comp
compression_gain_mono(ratio,thresh,att,rel) =
  an.amp_follower_ar(att,rel) : ba.linear2db : outminusindb(ratio,thresh) :
  kneesmooth(att) : ba.db2linear
with {
  // kneesmooth(att) installs a "knee" in the dynamic-range compression,
  // where knee smoothness is set equal to half that of the compression-attack.
  // A general 'knee' parameter could be used instead of tying it to att/2:
  kneesmooth(att) = si.smooth(ba.tau2pole(att/2.0));
  // compression gain in dB:
   outminusindb(ratio,thresh,level) = max(level-thresh,0.0) * (1.0/max(ma.EPSILON,float(ratio))-1.0);
  // Note: "float(ratio)" REQUIRED when ratio is an integer > 1!
};


compST(ratio, thr, att, rel, knee, post, x, y ) = cgm , cgm 
  with {
    cgm = compGainMono(ratio, thr, att, rel, (knee * 2  + 0.1), post, sqrt(x^2 + y^2) );
  };

compGainMono(ratio, thr, att, rel,knee, post, xPos ) =
  inDB 
  : gainDB 

  : ba.db2linear
  with {
    inDB = xPos : an.amp_follower_ar(att,rel) : ba.linear2db ;
    gainDB( xx ) = f0,f1,f2 : ba.selectn(3,nc)
      with{
        f0 = 0 ;
        f1 = 0-(xx^2) * rr/(4 * knee) + xx * rr * tmk /(2 * knee) - rr * (tmk^2) / (4 * knee);
        f2 = (thr-xx) * rr ;
        nc = 0 : ba.if(c1, 1) : ba.if(c2, 2);
        c1 = (xx > tmk) & (xx <= tpk) ;
        c2 = xx > tpk ;
        tmk = thr - knee ;
        tpk = thr + knee ;
        rr = 1 - 1 / ratio ;
      };
  };

//meter
//meter(m,in) = in <: attach(_,abs :ba.linear2db :m):>_;
meter(m) = _ <: _, (_:ba.linear2db: si.smoo : m) : attach ;

//vu_meter(m,in) = in <: attach(_,an.amp_follower(0.3):abs :ba.linear2db :m):>_;
vu_meter(m) = _ <: _, (_:an.amp_follower(0.3):ba.linear2db: si.smoo : m) : attach ;

//meter_db(m,in) = in <: attach(_, m):>_;
meter_db(m) = _ <: _, (_: si.smoo : m) : attach ;


comp_st_link(ratio,thr,att,rel,link,det,x,y)=l,r
with{
    px=x:det;
    py=y:det;
l=float((abs(px)+(abs(px)*(1-(link/100))+abs(py)*(link/100)))/2):det:compression_gain_mono(ratio,thr,att,rel);
r=float((abs(py)+(abs(py)*(1-(link/100))+abs(px)*(link/100)))/2):det:compression_gain_mono(ratio,thr,att,rel);
};





//agc 
afc1=200; 
agc2=fi.filterbank(3,(afc1))
:agc_fix
;

agc_fix(a,b)=(a,b);
athresh=-15;
ast_cop=0; 
arel=1;
aatt=400/1000;
aopt=kfil
//kfil:RMS(20/1000)
;
agc_knee=5;
agc_ratio=20;
agc(x,y)=agc_st
with{
agc_st=x,y:agc2,agc2:ro.interleave(2,2):comp:>_,_;
comp(a,b,c,d)=colev
with{

    colev=
//      comp_st_link(20,athresh,aatt,arel,st_cop,aopt,a,b),
//      comp_st_link(20,athresh,aatt+0.1,arel+0.5,st_cop,aopt,c,d)
compST(AGCratio, AGCb2thr, AGCb2att/1000, AGCrel/1000, AGCknee, 0,a, b ),
compST(AGCratio, AGCb1thr, AGCb1att/1000, AGCrel/1000, AGCknee, 0,c, d )
        :par(u,4,ba.linear2db):_,_,_,_:
        comp_cop;
        //a,b,c,d,e,f,g,h,i,j;
            comp_cop(k,l,m,n)=cop
                with{
                    cop=
                    ba.db2linear((k*1)+(m*0)
                    :meter_db(agc_l_gr2))
                    
                    *a
                    ,
                    ba.db2linear((l*1)+(n*0)
                    //:meter_db(agc_r_gr2)
                    )
                    //:meter(agc_r_gr2)
                    *b
                    ,
                    ba.db2linear((k*0)+(m*1):meter_db(agc_l_gr1))
                    //:meter(agc_l_gr1)
                    *c
                    ,
                    ba.db2linear((l*0)+(n*1)
                    //:meter_db(agc_r_gr1)
                    )
                    //:meter(agc_r_gr2)
                    *d
                    ;
                    };
    };
};

oct2q(x)=sqrt(2^x)/(2^x-1);

eq=(fi.low_shelf(eq1db,eq1freq):fi.peak_eq_cq(eq2db,eq2freq,eq2width):fi.peak_eq_cq(eq3db,eq3freq,eq3width):fi.peak_eq_cq(eq4db,eq4freq,oct2q(eq4width)));
eqst=eq,eq;
//multiband 
fc1=100; fc2=400; fc3=1000; fc4=3700; fc5=6200;
multiband=fi.filterbank(3,(fc1,fc2,fc3,fc4,fc5))
:multiband_fix
;

multiband_fix(u,v,w,x,y,z)=(u+v,w,x,y,z);
thresh=-10;
ratio=8;
st_cop=100;
att=30/1000;
rel=1000/1000;
mb_knee=8;
opt=_
//kfil:RMS(20/1000)
;
mb_comp(x,y)=mb_st
with{
mb_st=x,y:multiband,multiband:ro.interleave(5,2):stg(brilliance),_,_,_,_,_,_,_,_:comp:>_,_:stg(3):multiband,multiband:ro.interleave(5,2):lim:>_,_;
comp(a,b,c,d,e,f,g,h,i,j)=colev
with{
    colev=
        compST(ratio, b5thr, b5att, b5rel, mb_knee, 0,a, b ),
        compST(ratio, b4thr, b4att, b4rel, mb_knee, 0,c, d ),
        compST(ratio, b3thr, b3att, b3rel, mb_knee, 0,e, f ),
        compST(ratio, b2thr, b2att, b2rel, mb_knee, 0,g, h ),
        compST(ratio, b1thr, b1att, b1rel, mb_knee, 0,i, j )
        

        /*
        comp_st_link(ratio,12,20/1000,rel,st_cop,opt,a,b),
        comp_st_link(ratio,-8,20/1000,rel,st_cop,opt,c,d),
        comp_st_link(ratio,-7,20/1000,rel,st_cop,opt,e,f),
        comp_st_link(ratio,-6,20/1000,rel,st_cop,opt,g,h),
        comp_st_link(ratio,-8,30/1000,rel,st_cop,opt,i,j)*/

        :par(u,10,ba.linear2db):
        comp_cop;
        //a,b,c,d,e,f,g,h,i,j;
            comp_cop(k,l,m,n,o,p,q,r,s,t)=cop
                with{
                     
                    cop=
                    ba.db2linear((k*(1-b45))+(m*b45)+(o*0)+(q*0)+(s*0)
                    :meter_db(b5_gr)
                    )*a,
                    ba.db2linear((l*(1-b45))+(n*b45)+(p*0)+(r*0)+(t*0)
                    //:meter_db(b5_l_gr)
                    )*b,
                    ba.db2linear((k*0)+(m*(1-b34))+(o*b34)+(q*0)+(s*0)
                    :meter_db(b4_gr)
                    )*c,
                    ba.db2linear((l*0)+(n*(1-b34))+(p*b34)+(r*0)+(t*0)
                    //:meter_db(b4_l_gr)
                    )*d,
                    ba.db2linear((k*0)+(m*b34)+(o*(1-b32))+(q*b32)+(s*0)
                    :meter_db(b3_gr)
                    )*e,
                    ba.db2linear((l*0)+(n*b34)+(p*(1-b32))+(r*b32)+(t*0)
                    //:meter_db(b3_l_gr)
                    )*f,
                    ba.db2linear((k*0)+(m*0)+(o*b32)+(q*(1-b32))+(s*0)
                    :meter_db(b2_gr)
                    )*g,
                    ba.db2linear((l*0)+(n*0)+(p*b32)+(r*(1-b32))+(t*0)
                    //:meter_db(b2_l_gr)
                    )*h,
                    ba.db2linear((k*0)+(m*0)+(o*0)+(q*b12)+(s*(1-b12))
                    :meter_db(b1_gr)
                    )*i,
                    ba.db2linear((l*0)+(n*0)+(p*0)+(r*b12)+(t*(1-b32))
                    //:meter_db(b1_l_gr)
                    )*j;
                    };
    };
limatt=0;
limrel=50/1000;
limst_cop=0;
lad=1;
limopt=kfil;
limthr=MBLimThr;
lim(a,b,c,d,e,f,g,h,i,j)=colev
with{
    colev=
        comp_st_link(114514,limthr,limatt,limrel,limst_cop,limopt,a,b),
        comp_st_link(114514,limthr,limatt,limrel,limst_cop,limopt,c,d),
        comp_st_link(114154,limthr,limatt,limrel,limst_cop,limopt,e,f),
        comp_st_link(114514,limthr,limatt,limrel,limst_cop,limopt,g,h),
        comp_st_link(114514,limthr,limatt,limrel,limst_cop,limopt,i,j)
        :
        comp_cop
        :stg(MBb5out),stg(MBb4out),stg(MBb3out),stg(MBb2out),stg(MBb1out)
        ;
        //a,b,c,d,e,f,g,h,i,j;
            comp_cop(k,l,m,n,o,p,q,r,s,t)=cop
                with{
                     
                    cop=
                    (k
                    :meter(b5l_r_gr))
                    *(a@(ba.sec2samp(lad/10000))),
                    (l
                    :meter(b5l_l_gr))
                    *(b@(ba.sec2samp(lad/10000))),
                    (m
                    :meter(b4l_r_gr))
                    *(c@(ba.sec2samp(lad/10000))),
                    (n
                    :meter(b4l_l_gr))
                    *(d@(ba.sec2samp(lad/10000))),
                    (o
                    :meter(b3l_r_gr))
                    *(e@(ba.sec2samp(lad/10000))),
                    (p
                    :meter(b3l_l_gr))
                    *(f@(ba.sec2samp(lad/10000))),
                    (q
                    :meter(b2l_r_gr))
                    *(g@(ba.sec2samp(lad/1000))),
                    (r
                    :meter(b2l_l_gr))
                    *(h@(ba.sec2samp(lad/1000))),
                    (s
                    :meter(b1l_r_gr))
                    *(i@(ba.sec2samp(lad/1000))),
                    (t
                    :meter(b1l_l_gr))
                    *(j@(ba.sec2samp(lad/1000)));
                    };
    };



};
