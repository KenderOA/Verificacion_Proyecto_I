source /mnt/vol_NFS_rh003/estudiantes/archivos_config/synopsys_tools.sh;
rm -rfv `ls |grep -v ".*\.sv\|.*\.sh"`;
vcs -Mupdate Test_Driver.sv  -o salida -full64 -debug_all -sverilog -kdb -l log_test +lint=TFIPC-L;
