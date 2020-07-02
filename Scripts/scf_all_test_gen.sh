#!/bin/bash

NPP=-1
#=============================================SWITCHES=====================================================
TEST_KP=1                           #Use 1 to plot, 0 for not to plot
TEST_ECUT=1                         #Use 1 to plot, 0 for not to plot
TEST_ECUTrho=1                      #Use 1 to plot, 0 for not to plot
#=============================================BAND=========================================================
PREFIX="Si_ONC"
D_PREF=$PREFIX
#===============================================KP=========================================================
KP_START_VAL=1
KP_STOP_VAL=20
KP_INCREM=1
KP_VAL=$KP_START_VAL
INIT_ECUTW=60
INIT_ECUTRHO=500
#=============================================ECUTWFC======================================================
ECUT_START_VAL=20
ECUT_STOP_VAL=60
ECUT_INCREM=1
ECUT_VAL=$ECUT_START_VAL
KP_PICKED="13  13  1  0 0 0"
INIT_ECUTRHO2=500
#=============================================ECUTRHO======================================================
ECUTrho_START_VAL=100
ECUTrho_STOP_VAL=400
ECUTrho_INCREM=10
ECUTrho_VAL=$ECUTrho_START_VAL
KP_PICKED="9  9  1  0 0 0"
ECUT_PICKED=45
#===============================================DIR========================================================
D_INN="/Path_to_your_folder_input_file/$D_PREF"
D_PSEUDO="/Path_to_your_folder_of_PP/"
D_QEE="/Path_to_your_folder_of_QE/bin"
#=============================================STRUCTURE====================================================
A=4.07556486
C=25
NAT=2
NTYP=1
ATOM_SPE="\
Si     28.0855     Si_ONCV_PBE_sr.upf
"
ATOM_POS="\
Si     0.0000000000    0.0000000000    0.00000000
Si     0.0000000000    2.3530284690    0.57300000
"
#########################################--PROGRAM_SECTION--###############################################
#=============================================MAKE_DIR=====================================================
if [ ! -d "$PWD/$D_PREF/KP" ]; then
    mkdir $PWD/$D_PREF
    mkdir $PWD/$D_PREF/KP
fi
if [ ! -d "$PWD/$D_PREF/ECUT" ]; then
    mkdir $PWD/$D_PREF/ECUT
fi
if [ ! -d "$PWD/$D_PREF/ECUTrho" ]; then
    mkdir $PWD/$D_PREF/ECUTrho
fi
#===============================================KP=========================================================
if [ $TEST_KP == 1 ];then
touch $PWD/$D_PREF/$PREFIX\_KP.sh
cat > $PWD/$D_PREF/$PREFIX\_KP.sh << EOF
#!/bin/sh
F_PREFIX=KP_$PREFIX
D_IN="$D_INN/KP"
D_OUT="$D_INN/KP/OUT"
D_QE="$D_QEE"
NP="$NPP"

if [ ! -d "\$D_OUT" ]; then
    mkdir \$D_OUT
fi
touch \$D_OUT/KP_$PREFIX.gnu

echo "Started K_Point Test";
EOF

#SCF file creation
for KP_VAL in $(seq $KP_START_VAL $KP_INCREM $KP_STOP_VAL)
do

touch $PWD/$D_PREF/KP/KP_$PREFIX$KP_VAL.scf.in
cat > $PWD/$D_PREF/KP/KP_$PREFIX$KP_VAL.scf.in <<EOF
&CONTROL
    calculation   = "scf"
    outdir        = "$D_INN/work/"
    prefix        = "KP_$PREFIX$KP_VAL"
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
    ecutwfc     =  $INIT_ECUTW
    ecutrho     =  $INIT_ECUTRHO
    occupations = 'smearing'
    smearing    = 'mp'
    degauss     =  0.005
    vdw_corr	= 'DFT-D'
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
$KP_VAL  $KP_VAL  1  0 0 0

EOF

if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX\_KP.sh << EOF
\$D_QE/pw.x -i \$D_IN/KP_$PREFIX$KP_VAL.scf.in > \$D_OUT/KP_$PREFIX$KP_VAL.scf.out;
echo "K_Points >> $KP_VAL $KP_VAL 1";
grep ! \$D_OUT/KP_$PREFIX$KP_VAL.scf.out | awk {'print \$5'} >> \$D_OUT/KP_$PREFIX.gnu
EOF
else
cat >> $PWD/$D_PREF/$PREFIX\_KP.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/KP_$PREFIX$KP_VAL.scf.in > \$D_OUT/KP_$PREFIX$KP_VAL.scf.out;
echo "K_Points >> $KP_VAL $KP_VAL 1";
grep ! \$D_OUT/KP_$PREFIX$KP_VAL.scf.out | awk {'print \$5'} >> \$D_OUT/KP_$PREFIX.gnu
EOF
fi

done
fi
#=============================================ECUTWFC======================================================
if [ $TEST_ECUT == 1 ];then
touch $PWD/$D_PREF/$PREFIX\_ECUT.sh
cat > $PWD/$D_PREF/$PREFIX\_ECUT.sh << EOF
#!/bin/sh
F_PREFIX=ECUT_$PREFIX
D_IN="$D_INN/ECUT"
D_OUT="$D_INN/ECUT/OUT"
D_QE="$D_QEE"
NP="$NPP"

if [ ! -d "\$D_OUT" ]; then
    mkdir \$D_OUT
fi
touch \$D_OUT/ECUT_$PREFIX.gnu

echo "Started ECUTWFC Test";
EOF

#SCF file creation
for ECUT_VAL in $(seq $ECUT_START_VAL $INCREM $ECUT_STOP_VAL)
do

touch $PWD/$D_PREF/ECUT/ECUT_$PREFIX$ECUT_VAL.scf.in
cat > $PWD/$D_PREF/ECUT/ECUT_$PREFIX$ECUT_VAL.scf.in <<EOF
&CONTROL
    calculation   = "scf"
    outdir        = "$D_INN/work/"
    prefix        = "ECUT_$PREFIX$ECUT_VAL"
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
    ecutwfc     =  $ECUT_VAL
    ecutrho     =  $INIT_ECUTRHO2
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
$KP_PICKED

EOF

if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX\_ECUT.sh << EOF
\$D_QE/pw.x -i \$D_IN/ECUT_$PREFIX$ECUT_VAL.scf.in > \$D_OUT/ECUT_$PREFIX$ECUT_VAL.scf.out;
echo "Completed >> $ECUT_VAL Ry";
grep ! \$D_OUT/ECUT_$PREFIX$ECUT_VAL.scf.out | awk {'print \$5'} >> \$D_OUT/ECUT_$PREFIX.gnu
EOF
else
cat >> $PWD/$D_PREF/$PREFIX\_ECUT.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/ECUT_$PREFIX$ECUT_VAL.scf.in > \$D_OUT/ECUT_$PREFIX$ECUT_VAL.scf.out;
echo "Completed >> $ECUT_VAL Ry";
grep ! \$D_OUT/ECUT_$PREFIX$ECUT_VAL.scf.out | awk {'print \$5'} >> \$D_OUT/ECUT_$PREFIX.gnu
EOF
fi
done
fi

#=============================================ECUTWFC======================================================
if [ $TEST_ECUTrho == 1 ];then
touch $PWD/$D_PREF/$PREFIX\_ECUTrho.sh
cat > $PWD/$D_PREF/$PREFIX\_ECUTrho.sh << EOF
#!/bin/sh
F_PREFIX=ECUTrho_$PREFIX
D_IN="$D_INN/ECUTrho"
D_OUT="$D_INN/ECUTrho/OUT"
D_QE="$D_QEE"
NP="$NPP"

if [ ! -d "\$D_OUT" ]; then
    mkdir \$D_OUT
fi
touch \$D_OUT/ECUTrho_$PREFIX.gnu

echo "Started ECUTrho Test";
EOF

#SCF file creation
for ECUTrho_VAL in $(seq $ECUTrho_START_VAL $INCREM $ECUTrho_STOP_VAL)
do

touch $PWD/$D_PREF/ECUTrho/ECUTrho_$PREFIX$ECUTrho_VAL.scf.in
cat > $PWD/$D_PREF/ECUTrho/ECUTrho_$PREFIX$ECUTrho_VAL.scf.in <<EOF
&CONTROL
    calculation   = "scf"
    outdir        = "$D_INN/work/"
    prefix        = "ECUTrho_$PREFIX$ECUTrho_VAL"
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
    ecutwfc     =  $ECUT_PICKED
    ecutrho     =  $ECUTrho_VAL
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
$KP_PICKED

EOF

if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX\_ECUTrho.sh << EOF
\$D_QE/pw.x -i \$D_IN/ECUTrho_$PREFIX$ECUTrho_VAL.scf.in > \$D_OUT/ECUTrho_$PREFIX$ECUTrho_VAL.scf.out;
echo "Completed >> $ECUTrho_VAL Ry";
grep ! \$D_OUT/ECUTrho_$PREFIX$ECUTrho_VAL.scf.out | awk {'print \$5'} >> \$D_OUT/ECUTrho_$PREFIX.gnu
EOF
else
cat >> $PWD/$D_PREF/$PREFIX\_ECUTrho.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/ECUTrho_$PREFIX$ECUTrho_VAL.scf.in > \$D_OUT/ECUTrho_$PREFIX$ECUTrho_VAL.scf.out;
echo "Completed >> $ECUTrho_VAL Ry";
grep ! \$D_OUT/ECUTrho_$PREFIX$ECUTrho_VAL.scf.out | awk {'print \$5'} >> \$D_OUT/ECUTrho_$PREFIX.gnu
EOF
fi
done
fi

#=============================================THE_END===================================================




