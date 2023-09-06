# QE-Automators
Scripts for automating the tasks while working with __Quantum Espresso (QE)__.  

With the help of these basic scripts you can automate your boring, robotic tasks of making input files, plotting etc. and so you will be able to focus more on brain-intensive tasks. There are other GUI apps, kind of similar to this but the main intension of making these scripts is __"Control"__. Everything of the scripts can be modified easily satisfying your needs and the code is very close to the actual input files of QE.  

## List of scripts
* `gen.sh` is for generating input files for scf, band, DOS, PDOS, CDD, CD of VB and CB.
* `plotting.sh` is for plotting band structure, DOS, PDOS for atoms and orbitals.
* `mismatch_calc.sh` is for calculating lattice mismatch using lattice constant.
* `scf_all_test_gen.sh` is for testing pseudopotential files for suitable values of K_POINT, ecutwfc, ecutrho.
* `interlayerChBnd.sh` is for generating input files related to interlayer distance vs band gap.
* `rlx_gen.sh` is for generating input files for manual relax.

__Update (6/9/23): Phonon has been added.__

The scripts are written in __bash__. In fact I didn't like bash but in bash, it's easier to combine other Linux programs. The code may be made more optimized, may be written in other languages but I don't want do it now because my research is nearly finished. I started working on it at late stages of my thesis and now I won't be making major improvements. You are welcomed to improve and contribute to this project and any help will be appreciated.  

__Goto [Wiki page](https://github.com/hn46/QE-Automators/wiki) to learn how to use the scripts. Goto [Resources page](https://github.com/hn46/QE-Automators/wiki/Resources) to get resources to learn about QE simulation.__  

If your are having any problem then go __Issues__ tab, create a __New Issue__ and describe your problem. You can also contact me by sending DMs on facebook.  

## Contributor
* Me (Sakib)

## Special Thanks to
* Prof. Dr. Md. Sherajul Islam Sir
* Naim Ferdous Vai
* Munjurul Alam Zihad Vai
* Jikrul Sayeed
* Rayid Hasan Mojumder

