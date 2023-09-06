#!/bin/bash

NPP=-1          #use -1 for no mpi

#======================SWITCHES=====================================================
CRE_RLX=1                   # 1 TO ENABLE, 0 TO DISABLE
CRE_SCF=1                   # 1 TO ENABLE, 0 TO DISABLE
CRE_BAND_NSCF=1             # 1 TO ENABLE, 0 TO DISABLE
CRE_BAND=1                  # 1 TO ENABLE, 0 TO DISABLE
CRE_DOS_NSCF=1              # 1 TO ENABLE, 0 TO DISABLE
CRE_DOS=1                   # 1 TO ENABLE, 0 TO DISABLE
CRE_PROJWFC=1               # 1 TO ENABLE, 0 TO DISABLE
CRE_PP_SCF=1                # 1 TO ENABLE, 0 TO DISABLE
CRE_PP=1                    # 1 TO ENABLE, 0 TO DISABLE
CRE_VB_CB=1                 # 1 TO ENABLE, 0 TO DISABLE
CRE_PH=1                    # 1 TO ENABLE, 0 TO DISABLE
#======================INPUT SIDE===================================================
PREFIX="graphene+silicene"
D_PREF="structure_1"

D_INN="/Path_to_your_folder_input_file/$D_PREF"
D_PSEUDO="/Path_to_your_folder_of_PP/"
D_QEE="/Path_to_your_folder_of_QE/bin"

A=3.10
C=25
NAT=4
NTYP=2
ECUTW=40
ECUTRHO=200

ATOM_SPE="\
Si     28.0107     Si.UPF
C      12.0100     C.UPF
"

ATOM_POS="\
C      0.0000000000    0.0000000000    0.0000000000
C      0.0000000000    1.7897858340    0.0000000000
Si     0.0000000000    0.0000000000    3.5000000000
Si     0.0000000000    1.7897858340    4.1000000000
"

COORDINATE_TYPE="angstrom"       #angstrom or crystal

K_SCF="9  9  1  0 0 0"
K_BANDS="\
4
gG 20
M  20
K  20
gG 20
"
K_DOS="32  32  1  0 0 0"


# FOR CHARGE DENSITY CALCULATIONS ONLY
PP_A=6.2

NAT_h=16
NTYP_h=2

ATOM_POS_heter="\
C     0.0000000000    0.0000000000    0.0000000000
C     0.0000000000    1.7897858340    0.0000000000
Si    0.0000000000    0.0000000000    3.5000000000
Si    0.0000000000    1.7897858340    4.1000000000
C    -1.5500000000    2.6846787520    0.0000000000
C    -1.5500000000    4.4744645860    0.0000000000
Si   -1.5500000000    2.6846787520    3.5000000000
Si   -1.5500000000    4.4744645860    4.1000000000
C     3.1000000000    0.0000000000    0.0000000000
C     3.1000000000    1.7897858340    0.0000000000
Si    3.1000000000    0.0000000000    3.5000000000
Si    3.1000000000    1.7897858340    4.1000000000
C     1.5500000000    2.6846787520    0.0000000000
C     1.5500000000    4.4744645860    0.0000000000
Si    1.5500000000    2.6846787520    3.5000000000
Si    1.5500000000    4.4744645860    4.1000000000
"
ATOM_SPE_heter="\
Si     28.0107     Si.UPF
C      12.0107     C.UPF
"

PREFIX_1=graphene
NAT_1=8
NTYP_1=1
ATOM_SPE_1="\
C      12.0107     C.UPF
"
ATOM_POS_1="\
C     0.0000000000    0.0000000000    0.0000000000
C     0.0000000000    1.7897858340    0.0000000000
C    -1.5500000000    2.6846787520    0.0000000000
C    -1.5500000000    4.4744645860    0.0000000000
C     3.1000000000    0.0000000000    0.0000000000
C     3.1000000000    1.7897858340    0.0000000000
C     1.5500000000    2.6846787520    0.0000000000
C     1.5500000000    4.4744645860    0.0000000000
"

PREFIX_2=silicene
NAT_2=8
NTYP_2=1
ATOM_SPE_2="\
Si     28.0107     Si.UPF
"
ATOM_POS_2="\
Si    0.0000000000    0.0000000000    3.5000000000
Si    0.0000000000    1.7897858340    4.1000000000
Si   -1.5500000000    2.6846787520    3.5000000000
Si   -1.5500000000    4.4744645860    4.1000000000
Si    3.1000000000    0.0000000000    3.5000000000
Si    3.1000000000    1.7897858340    4.1000000000
Si    1.5500000000    2.6846787520    3.5000000000
Si    1.5500000000    4.4744645860    4.1000000000
"

KBAND_VB=14
KBAND_CB=15
KPOINT_VB=5
KPOINT_CB=9

# FOR PHONON ONLY

NQ1=4
NQ2=4
NQ3=1

Q_POINTS="\
4
 0.00000    0.00000    0.00000   20
 0.00000    0.50000    0.00000   20
 0.33333    0.33333    0.00000   20
 0.00000    0.00000    0.00000   20
"

#======================END OF INPUT SIDE============================================
#======================PROGRAM SIDE=================================================
if [ ! -d "$PWD/$D_PREF" ]; then
    mkdir $PWD/$D_PREF
    mkdir $PWD/$D_PREF/OUT
fi

#=======================SCRIPT======================================================
touch $PWD/$D_PREF/$PREFIX.sh
cat > $PWD/$D_PREF/$PREFIX.sh << EOF
#!/bin/sh
F_PREFIX=$PREFIX
F_PREFIX_1=$PREFIX_1
F_PREFIX_2=$PREFIX_2
D_IN="$D_INN"
D_OUT="$D_INN/OUT"
D_QE="$D_QEE"
NP="$NPP"

if [ ! -d "\$D_OUT" ]; then
    mkdir \$D_OUT
fi

echo "Started Simulation";
date
EOF

#=======================SCF=========================================================
if [ $CRE_SCF == 1 ];then
touch $PWD/$D_PREF/$PREFIX.scf.in
cat > $PWD/$D_PREF/$PREFIX.scf.in <<EOF
&CONTROL
    calculation   = "scf"
    outdir        = "$D_INN/work/"
    prefix        = "$PREFIX"
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
$K_SCF

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pw.x -i \$D_IN/\$F_PREFIX.scf.in > \$D_OUT/\$F_PREFIX.scf.out;
echo "SCF Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/\$F_PREFIX.scf.in > \$D_OUT/\$F_PREFIX.scf.out;
echo "SCF Completed";
date
EOF
fi
fi

#=======================BAND NSCF===================================================
if [ $CRE_BAND_NSCF == 1 ];then
touch $PWD/$D_PREF/$PREFIX.band_nscf.in
cat > $PWD/$D_PREF/$PREFIX.band_nscf.in <<EOF
&CONTROL
    calculation   = "bands"
    outdir        = "$D_INN/work/"
    prefix        = "$PREFIX"
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
K_POINTS crystal_b
$K_BANDS

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pw.x -i \$D_IN/\$F_PREFIX.band_nscf.in > \$D_OUT/\$F_PREFIX.band_nscf.out;
echo "BAND_NSCF Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/\$F_PREFIX.band_nscf.in > \$D_OUT/\$F_PREFIX.band_nscf.out;
echo "BAND_NSCF Completed";
date
EOF
fi
fi

#=======================BAND========================================================
if [ $CRE_BAND == 1 ];then
touch $PWD/$D_PREF/$PREFIX.band.in
cat > $PWD/$D_PREF/$PREFIX.band.in <<EOF
&BANDS
    outdir	= "$D_INN/work/",
    prefix	= "$PREFIX",
    filband	= "$D_INN/OUT/$PREFIX.band",
    lsym	= .true.
/
EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/bands.x -i \$D_IN/\$F_PREFIX.band.in > \$D_OUT/\$F_PREFIX.band.out;
echo "BAND Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/bands.x -i \$D_IN/\$F_PREFIX.band.in > \$D_OUT/\$F_PREFIX.band.out;
echo "BAND Completed";
date
EOF
fi
fi

#=======================DOS NSCF====================================================
if [ $CRE_DOS_NSCF == 1 ];then
touch $PWD/$D_PREF/$PREFIX.dos_nscf.in
cat > $PWD/$D_PREF/$PREFIX.dos_nscf.in <<EOF
&CONTROL
    calculation   = "nscf"
    outdir        = "$D_INN/work/"
    prefix        = "$PREFIX"
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
    occupations = 'tetrahedra'
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
$K_DOS

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pw.x -i \$D_IN/\$F_PREFIX.dos_nscf.in > \$D_OUT/\$F_PREFIX.dos_nscf.out;
echo "DOS_NSCF Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/\$F_PREFIX.dos_nscf.in > \$D_OUT/\$F_PREFIX.dos_nscf.out;
echo "DOS_NSCF Completed";
date
EOF
fi
fi

#=======================DOS=========================================================
if [ $CRE_DOS == 1 ];then
touch $PWD/$D_PREF/$PREFIX.dos.in
cat > $PWD/$D_PREF/$PREFIX.dos.in <<EOF
&DOS
    outdir = "$D_INN/work/"
    prefix = "$PREFIX"
    fildos = "$D_INN/OUT/$PREFIX.dos"
/
EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/dos.x -i \$D_IN/\$F_PREFIX.dos.in > \$D_OUT/\$F_PREFIX.dos.out;
echo "DOS Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/dos.x -i \$D_IN/\$F_PREFIX.dos.in > \$D_OUT/\$F_PREFIX.dos.out;
echo "DOS Completed";
date
EOF
fi
fi

#=======================PROGWFC=====================================================
if [ $CRE_PROJWFC == 1 ];then
touch $PWD/$D_PREF/$PREFIX.projwfc.in
cat > $PWD/$D_PREF/$PREFIX.projwfc.in <<EOF
&PROJWFC
    outdir = "$D_INN/work/"
    prefix = "$PREFIX"
    filpdos = "$D_INN/OUT/$PREFIX"
/
EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/projwfc.x -i \$D_IN/\$F_PREFIX.projwfc.in > \$D_OUT/\$F_PREFIX.projwfc.out;
echo "PDOS Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/projwfc.x -i \$D_IN/\$F_PREFIX.projwfc.in > \$D_OUT/\$F_PREFIX.projwfc.out;
echo "PDOS Completed";
date
EOF
fi
fi

#=======================PP_SCF_HETERO==================================================
if [[ $CRE_PP_SCF == 1 || $CRE_VB_CB == 1 ]];then
touch $PWD/$D_PREF/$PREFIX.pp_scf.in
cat > $PWD/$D_PREF/$PREFIX.pp_scf.in <<EOF
&CONTROL
    calculation   = "scf"
    outdir        = "$D_INN/work/"
    prefix        = "$PREFIX"
    pseudo_dir    = "$D_PSEUDO"
    restart_mode  = "from_scratch"
    verbosity     = 'high'
/

&SYSTEM
    ibrav       =  4
    a           =  $PP_A
    c           =  $C
    nat         =  $NAT_h
    ntyp        =  $NTYP_h
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
$ATOM_SPE_heter
ATOMIC_POSITIONS (angstrom)
$ATOM_POS_heter
K_POINTS {automatic}
$K_SCF

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pw.x -i \$D_IN/\$F_PREFIX.pp_scf.in > \$D_OUT/\$F_PREFIX.pp_scf.out;
echo "PP SCF $PREFIX Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/\$F_PREFIX.pp_scf.in > \$D_OUT/\$F_PREFIX.pp_scf.out;
echo "PP SCF $PREFIX Completed";
date
EOF
fi
fi

#=======================PP SCF LAYER 1=============================================
if [ $CRE_PP_SCF == 1 ];then
touch $PWD/$D_PREF/$PREFIX_1.pp_scf.in
cat > $PWD/$D_PREF/$PREFIX_1.pp_scf.in <<EOF
&CONTROL
    calculation   = "scf"
    outdir        = "$D_INN/work/"
    prefix        = "$PREFIX_1"
    pseudo_dir    = "$D_PSEUDO"
    restart_mode  = "from_scratch"
    verbosity     = 'high'
/

&SYSTEM
    ibrav       =  4
    a           =  $PP_A
    c           =  $C
    nat         =  $NAT_1
    ntyp        =  $NTYP_1
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
$ATOM_SPE_1
ATOMIC_POSITIONS (angstrom)
$ATOM_POS_1
K_POINTS {automatic}
$K_SCF

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pw.x -i \$D_IN/\$F_PREFIX_1.pp_scf.in > \$D_OUT/\$F_PREFIX_1.pp_scf.out;
echo "PP SCF$PREFIX_1 Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/\$F_PREFIX_1.pp_scf.in > \$D_OUT/\$F_PREFIX_1.pp_scf.out;
echo "PP SCF$PREFIX_1 Completed";
date
EOF
fi
fi


#=======================PP SCF LAYER 2===============================================
if [ $CRE_PP_SCF == 1 ];then
touch $PWD/$D_PREF/$PREFIX_2.pp_scf.in
cat > $PWD/$D_PREF/$PREFIX_2.pp_scf.in <<EOF
&CONTROL
    calculation   = "scf"
    outdir        = "$D_INN/work/"
    prefix        = "$PREFIX_2"
    pseudo_dir    = "$D_PSEUDO"
    restart_mode  = "from_scratch"
    verbosity     = 'high'
/

&SYSTEM
    ibrav       =  4
    a           =  $PP_A
    c           =  $C
    nat         =  $NAT_2
    ntyp        =  $NTYP_2
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
$ATOM_SPE_2
ATOMIC_POSITIONS (angstrom)
$ATOM_POS_2
K_POINTS {automatic}
$K_SCF

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pw.x -i \$D_IN/\$F_PREFIX_2.pp_scf.in > \$D_OUT/\$F_PREFIX_2.pp_scf.out;
echo "PP SCF $PREFIX_2 Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/\$F_PREFIX_2.pp_scf.in > \$D_OUT/\$F_PREFIX_2.pp_scf.out;
echo "PP SCF $PREFIX_2 Completed";
date
EOF
fi
fi

#=======================PP HETERO=======================================================
if [ $CRE_PP == 1 ];then
touch $PWD/$D_PREF/$PREFIX.pp.in
cat > $PWD/$D_PREF/$PREFIX.pp.in <<EOF
&INPUTPP
    prefix      = "$PREFIX"
    outdir      = "$D_INN/work/"
    plot_num    = 0
    filplot     = "$D_INN/OUT/$PREFIX.charge"
/
&PLOT
    iflag       = 3
    output_format = 6
    fileout     = "$D_INN/OUT/$PREFIX.cube"
/

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pp.x -i \$D_IN/\$F_PREFIX.pp.in > \$D_OUT/\$F_PREFIX.pp.out;
echo "$PREFIX PP Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pp.x -i \$D_IN/\$F_PREFIX.pp.in > \$D_OUT/\$F_PREFIX.pp.out;
echo "$PREFIX PP Completed";
date
EOF
fi
fi


#=======================PP LAYER 1=====================================================
if [ $CRE_PP == 1 ];then
touch $PWD/$D_PREF/$PREFIX_1.pp.in
cat > $PWD/$D_PREF/$PREFIX_1.pp.in <<EOF
&INPUTPP
    prefix      = "$PREFIX_1"
    outdir      = "$D_INN/work/"
    plot_num    = 0
    filplot     = "$D_INN/OUT/$PREFIX_1.charge"
/
&PLOT
    iflag       = 3
    output_format = 6
    fileout     = "$D_INN/OUT/$PREFIX_1.cube"
/

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pp.x -i \$D_IN/\$F_PREFIX_1.pp.in > \$D_OUT/\$F_PREFIX_1.pp.out;
echo "$PREFIX_1 PP Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pp.x -i \$D_IN/\$F_PREFIX_1.pp.in > \$D_OUT/\$F_PREFIX_1.pp.out;
echo "$PREFIX_1 PP Completed";
date
EOF
fi
fi


#=======================PP LAYER 2=====================================================
if [ $CRE_PP == 1 ];then
touch $PWD/$D_PREF/$PREFIX_2.pp.in
cat > $PWD/$D_PREF/$PREFIX_2.pp.in <<EOF
&INPUTPP
    prefix      = "$PREFIX_2"
    outdir      = "$D_INN/work/"
    plot_num    = 0
    filplot     = "$D_INN/OUT/$PREFIX_2.charge"
/
&PLOT
    iflag       = 3
    output_format = 6
    fileout     = "$D_INN/OUT/$PREFIX_2.cube"
/

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pp.x -i \$D_IN/\$F_PREFIX_2.pp.in > \$D_OUT/\$F_PREFIX_2.pp.out;
echo "$PREFIX_2 PP Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pp.x -i \$D_IN/\$F_PREFIX_2.pp.in > \$D_OUT/\$F_PREFIX_2.pp.out;
echo "$PREFIX_2 PP Completed";
date
EOF
fi
fi

#=======================CDD========================================================
if [ $CRE_PP == 1 ];then
touch $PWD/$D_PREF/$PREFIX.chdiff.in
cat > $PWD/$D_PREF/$PREFIX.chdiff.in <<EOF
&INPUTPP
/
&PLOT
    nfile       = 3
    filepp(1)   = "$D_INN/OUT/$PREFIX.charge", 
    filepp(2)   = "$D_INN/OUT/$PREFIX_1.charge", 
    filepp(3)   = "$D_INN/OUT/$PREFIX_2.charge", 
    weight(1)   = 1
    weight(2)   =-1
    weight(3)   =-1
    iflag       = 3
    output_format= 6
    fileout     = "$D_INN/OUT/${PREFIX}_chargediff.cube"
/

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pp.x -i \$D_IN/\$F_PREFIX.chdiff.in > \$D_OUT/\$F_PREFIX.chdiff.out;
echo "ChargeDiff Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pp.x -i \$D_IN/\$F_PREFIX.chdiff.in > \$D_OUT/\$F_PREFIX.chdiff.out;
echo "ChargeDiff Completed";
date
EOF
fi
fi

#=======================VB CD=========================================================
if [ $CRE_VB_CB == 1 ];then
touch $PWD/$D_PREF/$PREFIX.vb_pp.in
cat > $PWD/$D_PREF/$PREFIX.vb_pp.in <<EOF
&INPUTPP
    prefix      = "$PREFIX"
    outdir      = "$D_INN/work/"
    plot_num    = 7
    kpoint      = $KPOINT_VB
    kband       = $KBAND_VB
    filplot     = "$D_INN/OUT/${PREFIX}_VB.charge"
/
&PLOT
    iflag       = 3
    output_format = 6
    fileout     = "$D_INN/OUT/${PREFIX}_VB.cube"
/

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pp.x -i \$D_IN/\$F_PREFIX.vb_pp.in > \$D_OUT/\$F_PREFIX.vb_pp.out;
echo "$PREFIX VB CD Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pp.x -i \$D_IN/\$F_PREFIX.vb_pp.in > \$D_OUT/\$F_PREFIX.vb_pp.out;
echo "$PREFIX VB CD Completed";
date
EOF
fi
fi

#=======================CB CD=========================================================
if [ $CRE_VB_CB == 1 ];then
touch $PWD/$D_PREF/$PREFIX.cb_pp.in
cat > $PWD/$D_PREF/$PREFIX.cb_pp.in <<EOF
&INPUTPP
    prefix      = "$PREFIX"
    outdir      = "$D_INN/work/"
    plot_num    = 7
    kpoint      = $KPOINT_CB
    kband       = $KBAND_CB
    filplot     = "$D_INN/OUT/${PREFIX}_CB.charge"
/
&PLOT
    iflag       = 3
    output_format = 6
    fileout     = "$D_INN/OUT/${PREFIX}_CB.cube"
/

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pp.x -i \$D_IN/\$F_PREFIX.cb_pp.in > \$D_OUT/\$F_PREFIX.cb_pp.out;
echo "$PREFIX CB CD Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pp.x -i \$D_IN/\$F_PREFIX.cb_pp.in > \$D_OUT/\$F_PREFIX.cb_pp.out;
echo "$PREFIX CB CD Completed";
date
EOF
fi
fi


#=======================PHONON DISPERSION=========================================================
if [ $CRE_PH == 1 ];then
touch $PWD/$D_PREF/$PREFIX.ph.disp.in
cat > $PWD/$D_PREF/$PREFIX.ph.disp.in <<EOF
&inputph
    prefix      = '$PREFIX'
    verbosity   = 'high'
    outdir      = '$D_INN/work/'
    fildyn      = '$D_INN/OUT/$PREFIX.disp.dyn'
    tr2_ph      =  1.0d-14
    ldisp       = .true.
    nq1         =  $NQ1
    nq2         =  $NQ2
    nq3         =  $NQ3
/
EOF

touch $PWD/$D_PREF/$PREFIX.q2r.in
cat > $PWD/$D_PREF/$PREFIX.q2r.in <<EOF
&input
    zasr    = 'simple'
    fildyn  = '$D_INN/OUT/$PREFIX.disp.dyn'
    flfrc   = '$D_INN/OUT/$PREFIX.fc'
!    loto_2d = .true.
/
EOF


touch $PWD/$D_PREF/$PREFIX.matdyn.in
cat > $PWD/$D_PREF/$PREFIX.matdyn.in <<EOF
&input
    asr     = 'simple'
    flfrc   = '$D_INN/OUT/$PREFIX.fc'
    flfrq   = '$D_INN/OUT/$PREFIX.freq'
    q_in_band_form   = .true.
    q_in_cryst_coord = .true.
!    loto_2d = .true.
/
$Q_POINTS

EOF
touch $PWD/$D_PREF/$PREFIX.plotband.in
cat > $PWD/$D_PREF/$PREFIX.plotband.in <<EOF
$D_INN/OUT/$PREFIX.freq
-100 2000
$D_INN/OUT/$PREFIX.freq.disp.plot
$D_INN/OUT/$PREFIX.freq.disp.ps
0.0
50.0 0.0

EOF

if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/ph.x -i \$D_IN/\$F_PREFIX.ph.disp.in > \$D_OUT/\$F_PREFIX.ph.disp.out;
echo "PHONON Completed";
date
\$D_QE/q2r.x -i \$D_IN/\$F_PREFIX.q2r.in > \$D_OUT/\$F_PREFIX.q2r.out;
echo "Q2R Completed";
date
\$D_QE/matdyn.x -i \$D_IN/\$F_PREFIX.matdyn.in > \$D_OUT/\$F_PREFIX.matdyn.out;
echo "MATDYN Completed";
date
\$D_QE/plotband.x < \$D_IN/\$F_PREFIX.plotband.in > \$D_OUT/\$F_PREFIX.plotband.out;
echo "PLOT Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/ph.x -i \$D_IN/\$F_PREFIX.ph.disp.in > \$D_OUT/\$F_PREFIX.ph.disp.out;
echo "PHONON Completed";
date
mpirun -np \$NP \$D_QE/q2r.x -i \$D_IN/\$F_PREFIX.q2r.in > \$D_OUT/\$F_PREFIX.q2r.out;
echo "Q2R Completed";
date
\$D_QE/matdyn.x -i \$D_IN/\$F_PREFIX.matdyn.in > \$D_OUT/\$F_PREFIX.matdyn.out;
echo "MATDYN Completed";
date
\$D_QE/plotband.x < \$D_IN/\$F_PREFIX.plotband.in > \$D_OUT/\$F_PREFIX.plotband.out;
echo "PLOT Completed";
date
EOF
fi

fi



#=======================RELAX=========================================================
if [ $CRE_RLX == 1 ];then
touch $PWD/$D_PREF/$PREFIX.relax.in
cat > $PWD/$D_PREF/$PREFIX.relax.in <<EOF
&CONTROL
    calculation   = "relax"
    outdir        = "$D_INN/work/"
    prefix        = "$PREFIX"
    pseudo_dir    = "$D_PSEUDO"
    restart_mode  = "from_scratch"
    verbosity     = 'high'
    nstep         = 500
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

&IONS

/

ATOMIC_SPECIES
$ATOM_SPE
ATOMIC_POSITIONS ($COORDINATE_TYPE)
$ATOM_POS
K_POINTS {automatic}
$K_SCF

EOF
if [ $NPP == -1 ];then
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
\$D_QE/pw.x -i \$D_IN/\$F_PREFIX.relax.in > \$D_OUT/\$F_PREFIX.relax.out;
echo "RELAX Completed";
date
EOF
else
cat >> $PWD/$D_PREF/$PREFIX.sh << EOF
mpirun -np \$NP \$D_QE/pw.x -i \$D_IN/\$F_PREFIX.relax.in > \$D_OUT/\$F_PREFIX.relax.out;
echo "RELAX Completed";
date
EOF
fi
fi

#===================================THE_END=========================================
