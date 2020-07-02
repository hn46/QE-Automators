#!/bin/bash
rm .~lock.mismatch.csv#
rm mismatch.csv

a=3.50			# LATTICE CONSTANT OF 1st MATERIAL
b=3.03			# LATTICE CONSTANT OF 2nd MATERIAL


r=0
s=0

r=$(calc "print (((($a - $b)^2)^.5)/($b))" | tr '~' ',')			
cat > mismatch.csv << EOF
1,1$r
EOF

for (( i = 1; i < 10; i++ )); do
	for (( j = 1; j < 10; j++ )); do
		if [[ i -ne j ]]; then
			r=$(calc "print (((($a*$i - $j*$b)^2)^.5)/($b*$j))" | tr '~' ',')
			cat >> mismatch.csv << EOF
$i,$j$r
EOF
		fi
	done
done

libreoffice --calc mismatch.csv  # COMMENT THIS LINE IF YOU DONT HAVE LIBREOFFICE. AND YOU OTHER PROGRAMS TO OPEN IT

