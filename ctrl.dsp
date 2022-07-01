
//meter
agc_l_gr2 = agc_meter(vbargraph("[2]AGC high[unit:dB]",-25,0));
agc_l_gr1 = agc_meter(vbargraph("[0]AGC low[unit:dB]",-25,0));
agc_r_gr2 = agc_meter(vbargraph("[3]AGC high R[unit:dB]",-25,0));
agc_r_gr1 = agc_meter(vbargraph("[1]AGC low R[unit:dB]",-25,0));
stbmeter = st_boost_meter(vbargraph("[1]Stereo Enhance[unit:dB]",-25,0));


b1_l_gr = comp_meter(vbargraph("1 L[unit:dB]",-25,0));
b1_r_gr = comp_meter(vbargraph("1 R[unit:dB]",-25,0));
b2_l_gr = comp_meter(vbargraph("2 L[unit:dB]",-25,0));
b2_r_gr = comp_meter(vbargraph("2 R[unit:dB]",-25,0));
b3_l_gr = comp_meter(vbargraph("3 L[unit:dB]",-25,0));
b3_r_gr = comp_meter(vbargraph("3 R[unit:dB]",-25,0));
b4_l_gr = comp_meter(vbargraph("4 L[unit:dB]",-25,0));
b4_r_gr = comp_meter(vbargraph("4 R[unit:dB]",-25,0));
b5_l_gr = comp_meter(vbargraph("5 L[unit:dB]",-25,0));
b5_r_gr = comp_meter(vbargraph("5 R[unit:dB]",-25,0));
//mono

b1_gr = comp_meter(vbargraph("1[unit:dB]",-25,0));
b2_gr = comp_meter(vbargraph("2[unit:dB]",-25,0));
b3_gr = comp_meter(vbargraph("3[unit:dB]",-25,0));
b4_gr = comp_meter(vbargraph("4[unit:dB]",-25,0));
b5_gr = comp_meter(vbargraph("5[unit:dB]",-25,0));

//limiter

b1l_l_gr = lim_L(vbargraph("1[unit:dB]",-25,0));
b1l_r_gr = lim_R(vbargraph("1[unit:dB]",-25,0));
b2l_l_gr = lim_L(vbargraph("2[unit:dB]",-25,0));
b2l_r_gr = lim_R(vbargraph("2[unit:dB]",-25,0));
b3l_l_gr = lim_L(vbargraph("3[unit:dB]",-25,0));
b3l_r_gr = lim_R(vbargraph("3[unit:dB]",-25,0));
b4l_l_gr = lim_L(vbargraph("4[unit:dB]",-25,0));
b4l_r_gr = lim_R(vbargraph("4[unit:dB]",-25,0));
b5l_l_gr = lim_L(vbargraph("5[unit:dB]",-25,0));
b5l_r_gr = lim_R(vbargraph("5[unit:dB]",-25,0));
//final
final_gr = final_meter(vbargraph("limit[unit:dB]",-25,0));
final_loudness_gr = final_meter(vbargraph("loudness[unit:dB]",-25,0));
composite_gr = final_meter(vbargraph("composite[unit:dB]",-25,0));

input = in_meter(vbargraph("input[unit:dB]",-25,+0));
output = out_meter(vbargraph("output[unit:dB]",-25,+0));
loudness_in=in_meter(lufs_any(2));
loudness_out=out_meter(lufs_any(2));


couple1(x) = couple(hgroup("band1 coupling", x));
couple2(x) = couple(hgroup("band2 coupling", x));
couple3(x) = couple(hgroup("band3 coupling", x));
couple4(x) = couple(hgroup("band4 coupling", x));
couple5(x) = couple(hgroup("band5 coupling", x));


b1(x) = mb(hgroup("band1", x));
b2(x) = mb(hgroup("band2", x));
b3(x) = mb(hgroup("band3", x));
b4(x) = mb(hgroup("band4", x));
b5(x) = mb(hgroup("band5", x));

//view
graph(x) = (hgroup("[0]graph", x));
comp_meter(x) = graph(hgroup("[2]compressor", x));
lim_meter(x) = graph(tgroup("[3]limiter", x));
agc_meter(x) = graph(hgroup("[1]AGC", x));
in_meter(x) = graph(hgroup("[0]input", x));
final_meter(x) = graph(hgroup("[4]Final", x));


out_meter(x) = graph(hgroup("[5]output", x));

lim_L(x) = lim_meter(hgroup("[0]L", x));
lim_R(x) = lim_meter(hgroup("[1]R", x));




AGC(x) = control_tab(vgroup("AGC", x));


mb(x) = control_tab(vgroup("MB control", x));

couple(x) = control_tab(vgroup("Coupling", x));

EQ(x) = control_tab(vgroup("Equalizer", x));
LIMIT(x) = control_tab(vgroup("Limiter", x));
FM(x) = control_tab(vgroup("FM", x));

DIST(x) = control_tab(vgroup("Distortion", x));








//tab

control_tab(x) = tgroup("[1]Control", x);
multiband_tab(x) = tgroup("[2]multiband", x);




//settings
b11=couple1(hslider("band 1>1", 100, 0,+100, 0.1)/100);
b12=couple1(hslider("band 1>2", 70.9, 0,+100, 0.1)/100);
b13=couple1(hslider("band 1>3", 0, 0,+100, 0.1)/100);
b14=couple1(hslider("band 1>4", 0, 0,+100, 0.1)/100);
b15=couple1(hslider("band 1>5", 0, 0,+100, 0.1)/100);

b21=couple2(hslider("band 2>1", 20, 0,+100, 0.1)/100);
b22=couple2(hslider("band 2>2", 100, 0,+100, 0.1)/100);
b23=couple2(hslider("band 2>3", 0, 0,+100, 0.1)/100);
b24=couple2(hslider("band 2>4", 0, 0,+100, 0.1)/100);
b25=couple2(hslider("band 2>5", 0, 0,+100, 0.1)/100);

b31=couple3(hslider("band 3>1", 0, 0,+100, 0.1)/100);
b32=couple3(hslider("band 3>2", 0, 0,+100, 0.1)/100);
b33=couple3(hslider("band 3>3", 100, 0,+100, 0.1)/100);
b34=couple3(hslider("band 3>4", 0, 0,+100, 0.1)/100);
b35=couple3(hslider("band 3>5", 0, 0,+100, 0.1)/100);

b41=couple4(hslider("band 4>1", 0, 0,+100, 0.1)/100);
b42=couple4(hslider("band 4>2", 0, 0,+100, 0.1)/100);
b43=couple4(hslider("band 4>3", 0, 0,+100, 0.1)/100);
b44=couple4(hslider("band 4>4", 100, 0,+100, 0.1)/100);
b45=couple4(hslider("band 4>5", 22, 0,+100, 0.1)/100);


b51=couple5(hslider("band 5>1", 0, 0,+100, 0.1)/100);
b52=couple5(hslider("band 5>2", 0, 0,+100, 0.1)/100);
b53=couple5(hslider("band 5>3", 0, 0,+100, 0.1)/100);
b54=couple5(hslider("band 5>4", 50, 0,+100, 0.1)/100);
b55=couple5(hslider("band 5>5", 100, 0,+100, 0.1)/100);

b1att=b1(hslider("b1 Attack", 32, 0,+50, 0.1)/1000);
b2att=b2(hslider("b2 Attack", 15, 0,+50, 0.1)/1000);
b3att=b3(hslider("b3 Attack", 11, 0,+50, 0.1)/1000);
b4att=b4(hslider("b4 Attack", 12, 0,+50, 0.1)/1000);
b5att=b5(hslider("b5 Attack", 15, 0,+50, 0.1)/1000);

b1rel=b1(hslider("b1 Release", 600, 0,+2000, 0.1)/1000);
b2rel=b2(hslider("b2 Release", 500, 0,+2000, 0.1)/1000);
b3rel=b3(hslider("b3 Release", 550, 0,+2000, 0.1)/1000);
b4rel=b4(hslider("b4 Release", 500, 0,+2000, 0.1)/1000);
b5rel=b5(hslider("b5 Release", 500, 0,+2000, 0.1)/1000);


b1thr=b1(hslider("b1 threshold", -12,-20,+20, 0.1));
b2thr=b2(hslider("b2 threshold", -13,-20,+20, 0.1));
b3thr=b3(hslider("b3 threshold", -13,-20,+20, 0.1));
b4thr=b4(hslider("b4 threshold", -10,-20,+20, 0.1));
b5thr=b5(hslider("b5 threshold", -10,-20,+20, 0.1));


AGCdrive=AGC(hslider("Drive", 10,-30,+30, 0.1));
AGCb1att=AGC(hslider("b1 attack ", 500,0,+5000, 0.1));
AGCb2att=AGC(hslider("b2 attack ", 420,0,+5000, 0.1));
AGCrel=AGC(hslider("Release", 1900,0,+5000, 0.1));
AGCratio=AGC(hslider("Ratio", 20,1,+1000, 1));
AGCknee=AGC(hslider("Knee", 8,0,32, 0.1));
AGCb1thr=AGC(hslider("b1 threshold", -10,-30,+5000, 0.1));
AGCb2thr=AGC(hslider("b2 threshold", -10,-30,+5000, 0.1));



MBdrive=mb(hslider("Drive", 4,-30,+30, 0.1));
MBb1out=b1(hslider("b1 out", 0,-30,+30, 0.1));
MBb2out=b2(hslider("b2 out", 0,-30,+30, 0.1));
MBb3out=b3(hslider("b3 out", 0,-30,+30, 0.1));
MBb4out=b4(hslider("b4 out", 1,-30,+30, 0.1));
MBb5out=b5(hslider("b5 out", 2,-30,+30, 0.1));
//eq
//low band

eq1db=EQ1(hslider("Bass Gain", 1.2,0,+12, 0.1));
eq1freq=EQ1(hslider("Bass Frequency", 90,1,500, 0.1));
eq1slope=EQ1(hslider("Bass Slope", 6,6,18, 6)/6);
//low band
eq2db=EQ2(hslider("Low Gain", 0,-10,+10, 0.1));
eq2freq=EQ2(hslider("Low Frequency", 20,20,500, 0.1));
eq2width=EQ2(hslider("Low width", 0.8,0.1,20, 0.1)/6);
//mid band
eq3db=EQ3(hslider("Mid Gain", 0,-10,+10, 0.1));
eq3freq=EQ3(hslider("Mid Frequency", 250,250,600, 0.1));
eq3width=EQ3(hslider("Mid width", 0.8,0.1,20, 0.1)/6);
//high band
eq4db=EQ4(hslider("High Gain", 1.2,-10,+10, 0.1));
eq4freq=EQ4(hslider("High Frequency", 10400,1000,15000, 0.1));
eq4width=EQ4(hslider("High width", 5.9,0.1,20, 0.1)/6);
//brilliance
brilliance=EQ5(hslider("Brilliance", 4,0,20, 0.1));

EQ1(x) = EQ(hgroup("Low Shelf Equalizer", x));
EQ2(x) = EQ(hgroup("Low Band Equalizer", x));
EQ3(x) = EQ(hgroup("Mid Band Equalizer", x));
EQ4(x) = EQ(hgroup("High Band Equalizer", x));
EQ5(x) = EQ(hgroup("Brilliance", x));
 
//bass clipper
MBLimThr=LIMIT(hslider("Multiband Limit", -3,-20,+20, 0.1));
BassClipThr=LIMIT(hslider("Bass Clipper Threshold", 0,-30,+30, 0.1));
FinalDrive=LIMIT(hslider("Final limiter Drive", 0,-30,+30, 0.1));
FinalThr=LIMIT(hslider("Final limiter Threshold", 0,-30,+30, 0.1));
FinalLoudness=LIMIT(hslider("Loudness", -10,-20,+20, 0.1));

//preemph
pre_emph_on = FM(hslider("Pre-Emph[style:radio{'ON':0;'OFF':1}]",1,0,1,1));

