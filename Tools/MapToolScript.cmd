@ECHO OFF
set level="Egyptian"
set input_file=%level%.obj
set scale=0.2560800016
set floors=-2 -377 -189 -7 94
set output_file=%level%.map
@ECHO ON

MapTool %input_file% %scale% %floors% %output_file%
PAUSE