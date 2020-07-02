#!/bin/bash

#======================INPUT SIDE===================================================
NPP=-1

PREFIX="graphene+silicene"
D_PREF="structure_1_Int"

Z_START_VAL=3.00
Z_STOP_VAL=4.50
INCREM=0.1
BUCKLING=0.6

A=3.10
C=25
NAT=4
NTYP=2
ECUTW=40
ECUTRHO=200

ATOM_SPE="\
Si     28.0107     Si.UPF
C      12.0107     C.UPF
"

K_SCF="9  9  1  0 0 0"
K_BANDS="\
4
gG 20
M  20
K  20
gG 20
"

# Z_VAL_1=$Z_START_VAL
# Z_VAL_2=$(calc $Z_START_VAL+$BUCKLING)

D_INN="/Path_to_your_folder_input_file/$D_PREF"
D_PSEUDO="/Path_to_your_folder_of_PP/"
D_QEE="/Path_to_your_folder_of_QE/bin"

if [ ! -d "$PWD/$D_PREF" ]; then
    mkdir $PWD/$D_PREF
    mkdir $PWD/$D_PREF/OUT
fi

touch $PWD/$D_PREF/${PREFIX}.sh
cat > $PWD/$D_PREF/${PREFIX}.sh << EOF
#!/bin/sh
F_PREFIX=${PREFIX}
D_IN="$D_INN"
D_OUT="$D_INN/OUT"
D_QE="$D_QEE"
NP="$NPP"

if [ ! -d "\$D_OUT" ]; then
    mkdir \$D_OUT
fi

echo "Started Tunability (Interlayer dist. vs Eg) Calculation for ${PREFIX}"

EOF

#SCF file creation
for Z_VAL in $(seq $Z_START_VAL $INCREM $Z_STOP_VAL)
do
Z_VAL_1=$(calc $Z_VAL+1.8987937184 | awk {'print $1'})
Z_VAL_2=$(calc $Z_VAL+1.8987937184+$BUCKLING | awk {'print $1'})
Z_VAL_PREFIX=$(printf %.3f $Z_VAL)

ATOM_POS="\
C      0.0000000000    0.0000000000    0.0000000000
C      0.0000000000    1.7897858340    0.0000000000
Si     0.0000000000    0.0000000000    $Z_VAL_1
Si     0.0000000000    1.7897858340    $Z_VAL_2
"
# YOU CAN COPY FROM HERE
#   $Z_VAL_1
#   $Z_VAL_2
#   $Z_VAL_1
#   $Z_VAL_2
#   $Z_VAL_1
#   $Z_VAL_2
#   $Z_VAL_1
#   $Z_VAL_2
#   $Z_VAL_1
#   $Z_VAL_2
#   $Z_VAL_1
#   $Z_VAL_2
#   $Z_VAL_1
#   $Z_VAL_2
#   $Z_VAL_1
#   $Z_VAL_2

#======================END OF INPUT SIDE============================================
#======================PROGRAM SIDE=================================================
touch $PWD/$D_PREF/${PREFIX}_$Z_VAL_PREFIX.scf.in
cat > $PWD/$D_PREF/${PREFIX}_$Z_VAL_PREFIX.scf.in <<EOF
&CONTROL
    calculation   = "scf"
    outdir        = "$D_INN/work/"
    prefix        = "${PREFIX}_$Z_VAL_PREFIX"
    pseudo_dir    = "$D_PSEUDO"
    restart_mode  = "from_scratch"
    verbosity     = 'high'
/

&SYSTEM
    ibrav       =  4
    a           =  $A
    c           =  $C
    nat         =  $NAT
    ntyp        =  $NTYP
    input_dft   = 'PBE'
    ecutwfc     =  $ECUTW
    ecutrho     =  $ECUTRHO
    occupations = 'smearing'
    smearing    = 'mp'
    degauss     =  0.005
    vdw_corr    = 'DFT-D'
/

&ELECTRONS
    conv_thr         =  1.00000e-8
    mixing_beta      =  0.7
/

ATOMIC_SPECIES
$ATOM_SPE
ATOMIC_POSITIONS (angstrom)
$ATOM_POS
K_POINTS {automatic}
$K_SCF

EOF

Z_VAL_OLD=$(calc $Z_VAL-$INCREM)

if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/${PREFIX}.sh << EOF
\$D_QE/pw.x -i \$D_IN/${PREFIX}_$Z_VAL_PREFIX.scf.in > \$D_OUT/${PREFIX}_$Z_VAL_PREFIX.scf.out;
echo "Completed >> $Z_VAL Ang";
EOF
else
cat >> $PWD/$D_PREF/${PREFIX}.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/${PREFIX}_$Z_VAL_PREFIX.scf.in > \$D_OUT/${PREFIX}_$Z_VAL_PREFIX.scf.out;
echo "Completed >> $Z_VAL Ang";
EOF
fi

########################################################################################
#Band_nscf file creation
touch $PWD/$D_PREF/${PREFIX}_$Z_VAL_PREFIX.band_nscf.in
cat > $PWD/$D_PREF/${PREFIX}_$Z_VAL_PREFIX.band_nscf.in <<EOF
&CONTROL
    calculation   = "bands"
    outdir        = "$D_INN/work/"
    prefix        = "${PREFIX}_$Z_VAL_PREFIX"
    pseudo_dir    = "$D_PSEUDO"
    restart_mode  = "from_scratch"
    verbosity     = "high"
/

&SYSTEM
    ibrav       =  4
    a           =  $A
    c           =  $C
    nat         =  $NAT
    ntyp        =  $NTYP
    input_dft   = 'PBE'
    ecutwfc     =  $ECUTW
    ecutrho     =  $ECUTRHO
    occupations = 'smearing'
    smearing    = 'mp'
    degauss     =  0.005
    vdw_corr    = 'DFT-D'
/

&ELECTRONS
    conv_thr         =  1.00000e-8
    mixing_beta      =  0.7
/

ATOMIC_SPECIES
$ATOM_SPE
ATOMIC_POSITIONS (angstrom)
$ATOM_POS
K_POINTS crystal_b
$K_BANDS

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/${PREFIX}.sh << EOF
\$D_QE/pw.x -i \$D_IN/${PREFIX}_$Z_VAL_PREFIX.band_nscf.in > \$D_OUT/${PREFIX}_$Z_VAL_PREFIX.band_nscf.out;
echo "BAND_NSCF Completed";
EOF
else
cat >> $PWD/$D_PREF/${PREFIX}.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/${PREFIX}_$Z_VAL_PREFIX.band_nscf.in > \$D_OUT/${PREFIX}_$Z_VAL_PREFIX.band_nscf.out;
echo "BAND_NSCF Completed";
EOF
fi

########################################################################################
#Band file creation
touch $PWD/$D_PREF/${PREFIX}_$Z_VAL_PREFIX.band.in
cat > $PWD/$D_PREF/${PREFIX}_$Z_VAL_PREFIX.band.in <<EOF
&BANDS
    outdir  = "$D_INN/work/",
    prefix  = "${PREFIX}_$Z_VAL_PREFIX",
    filband = "$D_INN/OUT/${PREFIX}_$Z_VAL_PREFIX.band",
    lsym    = .true.
/
EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/${PREFIX}.sh << EOF
\$D_QE/bands.x -i \$D_IN/${PREFIX}_$Z_VAL_PREFIX.band.in > \$D_OUT/${PREFIX}_$Z_VAL_PREFIX.band.out;
echo "BAND Completed";
EOF
else
cat >> $PWD/$D_PREF/${PREFIX}.sh << EOF
mpirun -np \$NP \$D_QE/bands.x -i \$D_IN/${PREFIX}_$Z_VAL_PREFIX.band.in > \$D_OUT/${PREFIX}_$Z_VAL_PREFIX.band.out;
echo "BAND Completed";
EOF
fi
# NEW_VAL=\$(grep ! $D_INN/OUT/${PREFIX}_$Z_VAL_PREFIX.scf.out)
# OLD_VAL=\$(grep ! $D_INN/OUT/${PREFIX}_$Z_VAL_PREFIX_OLD.scf.out)
# if [[ \$NEW_VAL < \$OLD_VAL ]]; then
#     exit
# fi

# EOF
done

