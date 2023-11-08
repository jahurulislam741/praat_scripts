# This script saves all the selected sounds as .wav files in an output directory
# Simply select the sounds in the Object window; run the script and specify the output directory
# By Jahurul Islam, UBC, Vacouver; last update Mar. 30, 2021


clearinfo

form Enter the name of the output directory	
	comment Enter directory path herefor the new files (a folder that already exists) (if you're saving output)
		sentence output_dir output_folder
endform

#output_dir$ = "test"

# get the IDs of the sounds selected in the Objects window
sounds# = selected# ("Sound")

# loop through the selected files
number_of_sounds_selected = size(sounds#)
for i from 1 to number_of_sounds_selected
	selectObject: sounds# [i]
	name$ = selected$ ("Sound")

	# save as a .wav file
	Save as WAV file: "'output_dir$'" + "/" + "'name$'.wav"

	appendInfoLine: "Saved audio file: ", name$,".wav"
endfor


