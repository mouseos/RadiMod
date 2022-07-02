import("stdfaust.lib");
mpx(L,R)=m+am+pilot
with{
    m=L+R;
    s=L-R;
    pilot=os.oscsin(19000)*(10/100);
    am=s*os.oscsin(38000);
};

