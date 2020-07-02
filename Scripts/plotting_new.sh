#!/bin/bash
#======================SWITCHES=====================================================
CRE_BAND_PLT=1						#Use 1 to plot, 0 for not to plot
CRE_DOS_PLT=1						#Use 1 to plot, 0 for not to plot
CRE_PDOS_PLT_PER_ATOM=0				#Use 1 to plot, 0 for not to plot
CRE_PDOS_PLT_PER_ORBITAL=0			#Use 1 to plot, 0 for not to plot
CRE_PNG=1							#Use 1 to plot, 0 for not to plot
#======================INPUT SIDE===================================================
MANUAL_PREFIX=0
PREFIX="InN+C_III_"					#Manual input of PREFIX when MANUAL_PREFIX=1

#======================BAND=========================================================
AUTO_KP_FROM_BAND_NSCF_INPUT=1		#For manual input of make 0 and provide with KP_NAME
KP_NAME=(M Γ K M)    				#For gamma use "{/Symbol G}" or use Γ ; if AUTO_KP_FROM_BAND_NSCF_INPUT=1, this will be deactive

Y_RANGE_BND=(-1 1)					#For full range keep it empty
DRAW_VERTICAL_LINES=1				#Use 1 to plot, 0 for not to plot

LINE_COLOR_BAND=6
LINE_WIDTH_BAND=2

VERTICAL_LINE_COLOR=0
FERMI_LINE_COLOR=0

BND_LEGEND="Struct I"
Y_LBL_BND="Energy E-E_F (eV)"
X_LBL_BND="K Points"

TEXT_BND="Band Gap = 122.7 meV"
#TEXT_BND=""							#For no textbox in the graph just uncomment this. TIME SAVER
L_POS=(0.98 0.2)
FONT_SIZ=14

#======================DOS==========================================================
Y_RANGE_DOS=(-1 1)					#For full range keep it empty
X_RANGE_DOS=(0 4)					#For full range keep it empty

LINE_COLOR_DOS=18
LINE_WIDTH_DOS=2
DOS_LEGEND="Struct I"
Y_LBL_DOS="Energy E-E_F (eV)"
X_LBL_DOS="States (States/eV)"

#======================PDOS=========================================================
Y_RANGE_PDOS=( 0 25)					#For full range keep it empty
X_RANGE_PDOS=(-15 5)				#For full range keep it empty

PDOS_LEGEND="Struct I"
Y_LBL_PDOS="States (States/eV)"
X_LBL_PDOS="Energy E-E_F (eV)"

#Keep the order same in these catagories
#NAME_OF_ATOMS=(I Zn Si)
#NO_OF_ORBITALS=(2 4 2)
#USE_CUSTOM=(0 1 0)		#if it's not s p d f...
#ORBITALS_CUS=(s p d s)	#if it's not s p d f...

D_QEE="/media/sakib05/D/MaTerials/Deb/qe-6.5/bin"

# You can run the code once to get how many colors you
# need to declare. look for SET UNIQUE COLORS
COLORS_ATOM=(7 9 20)
COLORS_ORBITAL=(1 2 3 4 5 6 7)
COLORS_HETER=6				#Color of the heterostructure line
LINE_WIDTH_PDOS=1.4
#PDOS_TOTAL_COLOR=6
# PDOS_ACTIVE_TOT=1

#======================END OF INPUT SIDE============================================
#======================PROGRAM SIDE=================================================
if [[ MANUAL_PREFIX -eq 0 ]]; then
	PREFIX_TMP=($(ls | grep -w "scf.in" | tr "." "\n" | grep -wv "scf" | grep -wv "in"))
	PREFIX=${PREFIX_TMP[0]}
	for (( i = 1; i < ${#PREFIX_TMP[*]}; i++ )); do
		PREFIX=$PREFIX.${PREFIX_TMP[i]}
	done	
fi

ORBITALS=(s p d f)

#======================BAND=========================================================
if [ $CRE_BAND_PLT -eq 1 ];then
	KP_HS_POINTS=($(grep "high" $PWD/OUT/$PREFIX.band.out | tr "-" " "| awk {'print $9'}))
	F_ENG_BND=$(grep "Fermi" $PWD/OUT/$PREFIX.scf.out | awk {'print $5'})
	KP_NAME_2=($(grep -A 5 "K_POINTS" $PWD/$PREFIX.band_nscf.in | grep -v "K_P" | awk '{print $1}')) #Automation of KP
	
	for (( i = 0; i < 6; i++ )); do
		if [[ ${KP_NAME_2[i]} == "gG" ]]; then
			KP_NAME_2[i]='Γ'
		fi
	done
	
	touch $PWD/Plot_band_$PREFIX.sh
	if [[ $CRE_PNG -eq 1 ]]; then
		cat > $PWD/Plot_band_$PREFIX.sh <<EOF
#!/usr/bin/gnuplot -persist

reset
set term pngcairo font 'Arial-Bold,14'
set output "${PREFIX}_BANDS.png"
set label '$TEXT_BND' at ${L_POS[0]},${L_POS[1]} font ',$FONT_SIZ'

EOF
	else
		cat > $PWD/Plot_band_$PREFIX.sh <<EOF
#!/usr/bin/gnuplot -persist

reset
set label '$TEXT_BND' at ${L_POS[0]},${L_POS[1]} font ',$FONT_SIZ'

EOF
fi

	if [[ $AUTO_KP_FROM_BAND_NSCF_INPUT == '1' ]];then 			#Automation of KP
		cat >> $PWD/Plot_band_$PREFIX.sh <<EOF
set xtics ("${KP_NAME_2[1]}" ${KP_HS_POINTS[0]},"${KP_NAME_2[2]}" ${KP_HS_POINTS[1]},"${KP_NAME_2[3]}" ${KP_HS_POINTS[2]},"${KP_NAME_2[4]}" ${KP_HS_POINTS[3]}) font ',14'
EOF
	else
		cat >> $PWD/Plot_band_$PREFIX.sh <<EOF
set xtics ("${KP_NAME[0]}" ${KP_HS_POINTS[0]},"${KP_NAME[1]}" ${KP_HS_POINTS[1]},"${KP_NAME[2]}" ${KP_HS_POINTS[2]},"${KP_NAME[3]}" ${KP_HS_POINTS[3]}) font ',14'
EOF
	fi

	if [ $DRAW_VERTICAL_LINES -eq 1 ];then
		cat >> $PWD/Plot_band_$PREFIX.sh <<EOF
#set arrow from ${KP_HS_POINTS[0]},graph(0,0) to ${KP_HS_POINTS[0]},graph(1,1) nohead lc $FERMI_LINE_COLOR lw 1.5
set arrow from ${KP_HS_POINTS[1]},graph(0,0) to ${KP_HS_POINTS[1]},graph(1,1) nohead lc $FERMI_LINE_COLOR lw 1.5
set arrow from ${KP_HS_POINTS[2]},graph(0,0) to ${KP_HS_POINTS[2]},graph(1,1) nohead lc $FERMI_LINE_COLOR lw 1.5
set arrow from 0,0 to ${KP_HS_POINTS[3]},0 nohead dt "-" lc $VERTICAL_LINE_COLOR lw 1.5
EOF
	fi
	
	cat >> $PWD/Plot_band_$PREFIX.sh <<EOF
set yrange [${Y_RANGE_BND[0]} : ${Y_RANGE_BND[1]}]
set ylabel '$Y_LBL_BND' offset 2
set xlabel '$X_LBL_BND'
FE=$F_ENG_BND

plot "$PWD/OUT/$PREFIX.band.gnu" using 1:(\$2-FE) w l lc $LINE_COLOR_BAND lw $LINE_WIDTH_BAND title "$BND_LEGEND" 

EOF
	./Plot_band_$PREFIX.sh
else
	echo BAND NOT ACTIVATED
fi
#=======================DOS=========================================================
if [ $CRE_DOS_PLT -eq 1 ];then
	#F_ENG_DOS=$(grep "Fermi" $PWD/OUT/$PREFIX.dos | awk {'print $9'})
	F_ENG_DOS=$(grep "Fermi" $PWD/OUT/$PREFIX.scf.out | awk {'print $5'})

	touch $PWD/Plot_dos_$PREFIX.sh
	if [[ $CRE_PNG -eq 1 ]]; then
		cat > $PWD/Plot_dos_$PREFIX.sh <<EOF
#!/usr/bin/gnuplot -persist
reset
set term pngcairo font 'Arial-Bold,14'
set output "${PREFIX}_DOS.png"
EOF
	else
		cat > $PWD/Plot_dos_$PREFIX.sh <<EOF
#!/usr/bin/gnuplot -persist
reset
EOF
	fi
	
	cat >> $PWD/Plot_dos_$PREFIX.sh <<EOF
set arrow from 0,0 to ${X_RANGE_DOS[1]},0 nohead dt "-" lc $FERMI_LINE_COLOR lw 1.5
set yrange [${Y_RANGE_DOS[0]} : ${Y_RANGE_DOS[1]}]
set xrange [${X_RANGE_DOS[0]} : ${X_RANGE_DOS[1]}]
set ylabel '$Y_LBL_DOS' offset 2
set xlabel '$X_LBL_DOS'
FE=$F_ENG_DOS
plot "$PWD/OUT/$PREFIX.dos" using 2:(\$1-FE) w l lc $LINE_COLOR_DOS lw $LINE_WIDTH_DOS  title '$DOS_LEGEND'
EOF
	./Plot_dos_$PREFIX.sh
else
	echo DOS NOT ACTIVATED
fi

#========================PDOS_1=======================================================
if [ $CRE_PDOS_PLT_PER_ATOM -eq 1 ];then
	#F_ENG_PDOS=$(grep "Fermi" $PWD/OUT/$PREFIX.dos | awk {'print $9'})
	F_ENG_PDOS=$(grep "Fermi" $PWD/OUT/$PREFIX.scf.out | awk {'print $5'})

	
	touch $PWD/Plot_pdos_ATOM_$PREFIX.sh
	if [[ $CRE_PNG -eq 1 ]]; then
		cat > $PWD/Plot_pdos_ATOM_$PREFIX.sh <<EOF
#!/usr/bin/gnuplot -persist

reset
set term pngcairo font 'Arial-Bold,14'
set output "${PREFIX}_PDOS_PER_ATOM.png"
EOF
	else
		cat > $PWD/Plot_pdos_ATOM_$PREFIX.sh <<EOF
#!/usr/bin/gnuplot -persist

reset
EOF
	fi
		cat >> $PWD/Plot_pdos_ATOM_$PREFIX.sh <<EOF
set yrange [${Y_RANGE_PDOS[0]} : ${Y_RANGE_PDOS[1]}]
set xrange [${X_RANGE_PDOS[0]} : ${X_RANGE_PDOS[1]}]
set ylabel '$Y_LBL_PDOS' offset 2
set xlabel '$X_LBL_PDOS'
set arrow from 0,0 to 0,${Y_RANGE_PDOS[1]} nohead dt "-" lc $FERMI_LINE_COLOR lw 1.5
FE=$F_ENG_PDOS

plot \\
EOF
	NO_OF_ATOMS=$(grep "ntyp" $PWD/$PREFIX.scf.in | awk {'print $3'})
	NAME_OF_ATOMS=($(grep -A $NO_OF_ATOMS "ATOMIC_SPECIES" $PWD/$PREFIX.scf.in | awk {'print $1'}))
	if [[ ! -d "$PWD/OUT/PDOS_post" ]]; then
		mkdir $PWD/OUT/PDOS_post
	fi

	for (( i = 1; i <= $(($NO_OF_ATOMS)); i++ )); do
		FILE_ATOM_IND=($(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})"))
		NO_FILE_ATOM_IND=$(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})" | wc -l)
		for (( j = 0; j < NO_FILE_ATOM_IND; j++ )); do
			FILE_ATOM_IND[j]="$PWD/OUT/${FILE_ATOM_IND[j]}"
		done
		$D_QEE/sumpdos.x ${FILE_ATOM_IND[*]} > $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}
		cat >> $PWD/Plot_pdos_ATOM_$PREFIX.sh <<EOF
"$PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}" using (\$1-FE):2 w l lc ${COLORS_ATOM[i-1]} lw $LINE_WIDTH_PDOS title '${NAME_OF_ATOMS[i]}', \\
EOF
	done
	echo "====== SET $(($i-1)) UNIQUE ATOM COLORS ======"
	FILE_ATOM_TOT=($(ls $PWD/OUT/ | grep "pdos_atm"))
	NO_FILE_ATOM_TOT=$(ls $PWD/OUT/ | grep "pdos_atm" | wc -l)
	for (( j = 0; j < NO_FILE_ATOM_TOT; j++ )); do
		FILE_ATOM_TOT[j]="$PWD/OUT/${FILE_ATOM_TOT[j]}"
	done
	$D_QEE/sumpdos.x ${FILE_ATOM_TOT[*]} > $PWD/OUT/PDOS_post/$PREFIX.pdos_total
	cat >> $PWD/Plot_pdos_ATOM_$PREFIX.sh <<EOF
"$PWD/OUT/PDOS_post/$PREFIX.pdos_total" using (\$1-FE):2 w l lc $COLORS_HETER lw $LINE_WIDTH_PDOS title 'Heterostructure', \\
EOF
	chmod +x ./Plot_pdos_ATOM_$PREFIX.sh
	./Plot_pdos_ATOM_$PREFIX.sh
else
	echo PDOS_PER_ATOM NOT ACTIVATED
fi	


#========================PDOS_2=======================================================
if [ $CRE_PDOS_PLT_PER_ORBITAL -eq 1 ];then
	#F_ENG_PDOS=$(grep "Fermi" $PWD/OUT/$PREFIX.dos | awk {'print $9'})
	F_ENG_PDOS=$(grep "Fermi" $PWD/OUT/$PREFIX.scf.out | awk {'print $5'})

	
	touch $PWD/Plot_pdos_ORBITAL_$PREFIX.sh
	if [[ $CRE_PNG -eq 1 ]]; then
		cat > $PWD/Plot_pdos_ORBITAL_$PREFIX.sh <<EOF
#!/usr/bin/gnuplot -persist

reset
set term pngcairo font 'Arial-Bold,14'
set output "${PREFIX}_PDOS_PER_ORBITAL.png"
EOF
	else
		cat > $PWD/Plot_pdos_ORBITAL_$PREFIX.sh <<EOF
#!/usr/bin/gnuplot -persist

reset
EOF
	fi
		cat >> $PWD/Plot_pdos_ORBITAL_$PREFIX.sh <<EOF
set yrange [${Y_RANGE_PDOS[0]} : ${Y_RANGE_PDOS[1]}]
set xrange [${X_RANGE_PDOS[0]} : ${X_RANGE_PDOS[1]}]
set ylabel '$Y_LBL_PDOS' offset 2
set xlabel '$X_LBL_PDOS'
set arrow from 0,0 to 0,${Y_RANGE_PDOS[1]} nohead dt "-" lc $FERMI_LINE_COLOR lw 1.5
FE=$F_ENG_PDOS

plot \\
EOF
	NO_OF_ATOMS=$(grep "ntyp" $PWD/$PREFIX.scf.in | awk {'print $3'})
	NAME_OF_ATOMS=($(grep -A $NO_OF_ATOMS "ATOMIC_SPECIES" $PWD/$PREFIX.scf.in | awk {'print $1'}))
	if [[ ! -d "$PWD/OUT/PDOS_post" ]]; then
		mkdir $PWD/OUT/PDOS_post
	fi
	color_counter=0
	for (( i = 1; i <= $(($NO_OF_ATOMS)); i++ )); do
		for (( k = 0; k <= 5; k++ )); do
			if [ $(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})" | grep -c "(${ORBITALS[k]})") -ge 1 ]; then
				FILE_ORB_IND=($(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})" | grep "(${ORBITALS[k]})"))
				NO_FILE_ORB_IND=$(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})" | grep "(${ORBITALS[k]})" | wc -l)
				for (( j = 0; j < NO_FILE_ORB_IND; j++ )); do
					FILE_ORB_IND[j]="$PWD/OUT/${FILE_ORB_IND[j]}"
				done
				$D_QEE/sumpdos.x ${FILE_ORB_IND[*]} > $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}-${ORBITALS[k]}
				cat >> $PWD/Plot_pdos_ORBITAL_$PREFIX.sh <<EOF
"$PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}-${ORBITALS[k]}" using (\$1-FE):2 w l lc ${COLORS_ORBITAL[$color_counter]} lw $LINE_WIDTH_PDOS title '${NAME_OF_ATOMS[i]}-${ORBITALS[k]}', \\
EOF
			color_counter=$(($color_counter+1))
			fi
		done
	done
	echo "====== SET $color_counter UNIQUE ORBITAL COLORS ======"
	FILE_ORB_TOT=($(ls $PWD/OUT/ | grep "pdos_atm"))
	NO_FILE_ORB_TOT=$(ls $PWD/OUT/ | grep "pdos_atm" | wc -l)
	for (( j = 0; j < NO_FILE_ORB_TOT; j++ )); do
		FILE_ORB_TOT[j]="$PWD/OUT/${FILE_ORB_TOT[j]}"
	done
	$D_QEE/sumpdos.x ${FILE_ORB_TOT[*]} > $PWD/OUT/PDOS_post/$PREFIX.pdos_total
	cat >> $PWD/Plot_pdos_ORBITAL_$PREFIX.sh <<EOF
"$PWD/OUT/PDOS_post/$PREFIX.pdos_total" using (\$1-FE):2 w l lc $COLORS_HETER lw $LINE_WIDTH_PDOS title 'Heterostructure', \\
EOF
	chmod +x ./Plot_pdos_ORBITAL_$PREFIX.sh
	./Plot_pdos_ORBITAL_$PREFIX.sh
	
else
	echo PDOS_PER_ORBITAL NOT ACTIVATED
fi	
	
	
		
# 	if [[ -d "$PWD/PDOS_tmp" ]]; then
# 		rm -fr $PWD/PDOS_tmp
# 	fi
# 	mkdir $PWD/PDOS_tmp
# 	touch $PWD/PDOS_tmp/sum_all
# #indivisual atom type
# 	for (( i = 1; i <= $(($NO_OF_ATOMS)); i++ )); do
# 		FILE_ATOM_IND=($(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})"))
# 		NO_FILE_ATOM_IND=$(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})" | wc -l)
# 		touch $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}
# 		touch $PWD/PDOS_tmp/sum $PWD/PDOS_tmp/sum1
# 		cat $PWD/OUT/${FILE_ATOM_IND[0]} | awk {'print $1'} > $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}
# 		cat $PWD/OUT/${FILE_ATOM_IND[0]} | awk {'print $2'} > $PWD/PDOS_tmp/sum
# 		for (( j = 1; j < $NO_FILE_ATOM_IND; j++ )); do
# 			cat $PWD/OUT/${FILE_ATOM_IND[j]} | awk {'print $2'} > $PWD/PDOS_tmp/${FILE_ATOM_IND[j]}_tmp
# 			paste $PWD/PDOS_tmp/sum $PWD/PDOS_tmp/${FILE_ATOM_IND[j]}_tmp | awk '{print $1 + $2}' > $PWD/PDOS_tmp/sum1
# 			cat $PWD/PDOS_tmp/sum1 > $PWD/PDOS_tmp/sum
# 			if [[ i -eq 1 && j -eq 1 ]]; then
# 				cat $PWD/PDOS_tmp/sum > $PWD/PDOS_tmp/sum_all
# 			else
# 				paste $PWD/PDOS_tmp/sum $PWD/PDOS_tmp/sum_all | awk '{print $1 + $2}' > $PWD/PDOS_tmp/sum1
# 				cat $PWD/PDOS_tmp/sum1 > $PWD/PDOS_tmp/sum_all
# 			fi
# 		done
# 		paste $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]} $PWD/PDOS_tmp/sum > $PWD/PDOS_tmp/sum1
# 		cat $PWD/PDOS_tmp/sum1 > $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}
# 		cat >> $PWD/Plot_pdos_ATOM_$PREFIX.sh <<EOF
# "$PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}" using (\$1-FE):2 w l lc ${COLORS_ATOM[i-1]} lw $LINE_WIDTH_PDOS title '${NAME_OF_ATOMS[i]}', \\
# EOF
# 	done
# 	echo "Set $(($i-1)) unique atom colors"
# 	cat $PWD/OUT/${FILE_ATOM_IND[0]} | awk {'print $1'} > $PWD/OUT/PDOS_post/$PREFIX.pdos_total
# 	paste $PWD/OUT/PDOS_post/$PREFIX.pdos_total $PWD/PDOS_tmp/sum_all > $PWD/PDOS_tmp/sum1
# 	cat $PWD/PDOS_tmp/sum1 > $PWD/OUT/PDOS_post/$PREFIX.pdos_total
# 	cat >> $PWD/Plot_pdos_ATOM_$PREFIX.sh <<EOF
# "$PWD/OUT/PDOS_post/$PREFIX.pdos_total" using (\$1-FE):2 w l lc $COLORS_HETER lw $LINE_WIDTH_PDOS title 'Heterostructure', \\
# EOF
# 	chmod +x ./Plot_pdos_ATOM_$PREFIX.sh
# 	./Plot_pdos_ATOM_$PREFIX.sh

	
	
# 	if [[ -d "$PWD/PDOS_tmp" ]]; then
# 		rm -fr $PWD/PDOS_tmp
# 	fi
# 	if [[ ! -d "$PWD/OUT/PDOS_post" ]]; then
# 		mkdir $PWD/OUT/PDOS_post
# 	fi
# 	mkdir $PWD/PDOS_tmp
# 	touch $PWD/PDOS_tmp/sum_all
# #indivisual orbital type
# 	color_counter=0
# 	for (( i = 1; i <= $(($NO_OF_ATOMS)); i++ )); do
# 		for (( k = 0; k <= 5; k++ )); do
# 			if [ $(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})" | grep -c "(${ORBITALS[k]})") -ge 1 ]; then
# 				FILE_ORB_IND=($(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})" | grep "(${ORBITALS[k]})"))
# 				NO_FILE_ORB_IND=$(ls $PWD/OUT/ | grep "(${NAME_OF_ATOMS[i]})" | grep "(${ORBITALS[k]})" | wc -l)
# 				#echo ${FILE_ORB_IND[*]} $NO_FILE_ORB_IND
# 				touch $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}-${ORBITALS[k]}
# 				touch $PWD/PDOS_tmp/sum $PWD/PDOS_tmp/sum1
# 				cat $PWD/OUT/${FILE_ORB_IND[0]} | awk {'print $1'} > $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}-${ORBITALS[k]}
# 				cat $PWD/OUT/${FILE_ORB_IND[0]} | awk {'print $2'} > $PWD/PDOS_tmp/sum
# 				for (( j = 1; j < $NO_FILE_ORB_IND; j++ )); do
# 					cat $PWD/OUT/${FILE_ORB_IND[j]} | awk {'print $2'} > $PWD/PDOS_tmp/${FILE_ORB_IND[j]}_tmp
# 					paste $PWD/PDOS_tmp/sum $PWD/PDOS_tmp/${FILE_ORB_IND[j]}_tmp | awk '{print $1 + $2}' > $PWD/PDOS_tmp/sum1
# 					cat $PWD/PDOS_tmp/sum1 > $PWD/PDOS_tmp/sum
# 					if [[ i -eq 1 && k -eq 0 && j -eq 1 ]]; then
# 						cat $PWD/PDOS_tmp/sum > $PWD/PDOS_tmp/sum_all
# 					else
# 						paste $PWD/PDOS_tmp/sum $PWD/PDOS_tmp/sum_all | awk '{print $1 + $2}' > $PWD/PDOS_tmp/sum1
# 						cat $PWD/PDOS_tmp/sum1 > $PWD/PDOS_tmp/sum_all
# 					fi
# 				done
# 				paste $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}-${ORBITALS[k]} $PWD/PDOS_tmp/sum > $PWD/PDOS_tmp/sum1
# 				cat $PWD/PDOS_tmp/sum1 > $PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}-${ORBITALS[k]}
# 				# rm -fr $PWD/PDOS_tmp	#Comment it for debugging purpose
# 				cat >> $PWD/Plot_pdos_ORBITAL_$PREFIX.sh <<EOF
# "$PWD/OUT/PDOS_post/$PREFIX.pdos_${NAME_OF_ATOMS[i]}-${ORBITALS[k]}" using (\$1-FE):2 w l lc ${COLORS_ORBITAL[$color_counter]} lw $LINE_WIDTH_PDOS title '${NAME_OF_ATOMS[i]}-${ORBITALS[k]}', \\
# EOF
# 			color_counter=$(($color_counter+1))
# 			fi
# 		done
# 	done
# 	echo "Set $color_counter unique orbital colors"
# 	cat $PWD/OUT/${FILE_ATOM_IND[0]} | awk {'print $1'} > $PWD/OUT/PDOS_post/$PREFIX.pdos_total
# 	paste $PWD/OUT/PDOS_post/$PREFIX.pdos_total $PWD/PDOS_tmp/sum_all > $PWD/PDOS_tmp/sum1
# 	cat $PWD/PDOS_tmp/sum1 > $PWD/OUT/PDOS_post/$PREFIX.pdos_total
# 	cat >> $PWD/Plot_pdos_ORBITAL_$PREFIX.sh <<EOF
# "$PWD/OUT/PDOS_post/$PREFIX.pdos_total" using (\$1-FE):2 w l lc $COLORS_HETER lw $LINE_WIDTH_PDOS title 'Heterostructure', \\
# EOF
# 	chmod +x ./Plot_pdos_ORBITAL_$PREFIX.sh
# 	./Plot_pdos_ORBITAL_$PREFIX.sh
	
# 	TYPES=$(grep "ntyp" $PWD/$PREFIX.scf.in | awk {'print $3'})
# 	ATM=($(grep -A $(calc $NO_OF_ATOMS+1) "ATOMIC_POSITION" $PWD/$PREFIX.scf.in | awk {'print $1'}))  #ARRAY
# 	ORBITALS=(s p d)
# 	FIRST_TIME=(1 1 1 1 1 1 1 1 1 1 1)
	
# 	#i for var atoms number, j for actual orbital no., k for var orbital no.,
	
# 	for (( i = 1; i <= $NO_OF_ATOMS; i++ )); do
# 		for (( j = 0; j < $TYPES; j++ )); do
# 			if [[ ${ATM[i]} == ${NAME_OF_ATOMS[j]} ]]; then #Determining the position in NO_OF_ORBITALS var by comparing the name.
# 				break
# 			fi
# 		done
		
# 		for (( k = 0, kk= 1; k < ${NO_OF_ORBITALS[j]}; k++, kk++ )); do
# 			if [[ ${USE_CUSTOM[j]} -eq 1 ]]; then
# 				if [[ ${FIRST_TIME[j]} -eq 1 ]]; then
# 					FIRST_TIME[j]=0
# 					cat >> $PWD/Plot_pdos_$PREFIX.sh <<EOF
# "$PWD/OUT/$PREFIX.pdos_atm#$i(${ATM[i]})_wfc#$kk(${ORBITALS_CUS[k]})" using (\$1-FE):2 w l lc ${COLORS[j]} lw $LINE_WIDTH_PDOS title '${ATM[i]}', \\
# EOF
# 				else
# 					cat >> $PWD/Plot_pdos_$PREFIX.sh <<EOF
# "$PWD/OUT/$PREFIX.pdos_atm#$i(${ATM[i]})_wfc#$kk(${ORBITALS_CUS[k]})" using (\$1-FE):2 w l lc ${COLORS[j]} lw $LINE_WIDTH_PDOS notitle, \\
# EOF
# 				fi
# 			else
# 				if [[ ${FIRST_TIME[j]} -eq 1 ]]; then
# 					FIRST_TIME[j]=0
# 					cat >> $PWD/Plot_pdos_$PREFIX.sh <<EOF
# "$PWD/OUT/$PREFIX.pdos_atm#$i(${ATM[i]})_wfc#$kk(${ORBITALS[k]})" using (\$1-FE):2 w l lc ${COLORS[j]} lw $LINE_WIDTH_PDOS title '${ATM[i]}', \\
# EOF
# 				else
# 					cat >> $PWD/Plot_pdos_$PREFIX.sh <<EOF
# "$PWD/OUT/$PREFIX.pdos_atm#$i(${ATM[i]})_wfc#$kk(${ORBITALS[k]})" using (\$1-FE):2 w l lc ${COLORS[j]} lw $LINE_WIDTH_PDOS notitle, \\
# EOF
# 				fi
# 			fi
#  		done
# 	done
# 	if [[ $PDOS_ACTIVE_TOT -eq 1 ]]; then
# 		cat >> $PWD/Plot_pdos_$PREFIX.sh <<EOF
# "$PWD/OUT/$PREFIX.pdos_tot" using (\$1-FE):2 w l lc $PDOS_TOTAL_COLOR lw $LINE_WIDTH_PDOS title 'Heterostructure'
# EOF
# 	fi
# 	./Plot_pdos_$PREFIX.sh
# else
# 	echo PDOS NOT ACTIVATED
# fi



#===================================THE_END=========================================