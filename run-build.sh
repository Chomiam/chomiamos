#\!/bin/bash
cd /home/chomiam/chomiamos/chomiamos/archiso
echo 'Cleaning work and out directories...'
rm -rf work out
echo 'Running mkarchiso...'
mkarchiso -v -w work/ -o out/ .
echo 'Done\!'
