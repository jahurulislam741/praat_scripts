
###################################################################
###	Script: get_f0_across_sounds.praat
# This script extracts F0 at every 30 ms through an audio file.
# Works for all audio files in a directory
# Put all audio files in a folder named "input_audio_files"
# Results written in an outpute CSV file
# Written by: Jahurul Islam, UBC, Vancouver, Mar 23, 2023
###################################################################

clearinfo

# USER INPUT (change as necessary)
input_directory$ = "input_audio_files"
hop_length = 0.030
pitch_floor = 100 ; (use 75 for male speakers)
pitch_ceiling = 600 ; (use 300 for male speakers)

# READ THE FILE NAMES FROM THE SPECIFIED input_directory
Create Strings as file list... soundfiles_list 'input_directory$'/*.wav
num_of_soundfiles = Get number of strings

# DELETE THE OLD FORMANT FILE IF IT EXISTS
output_file$ = "praat_f0_out.csv"
filedelete 'output_file$'

# CREATE A HEADER ROW FOR THE OUTPUT FILE [DONE BY FILE APPENDING OUTSIDE THE 'FOR LOOP']
fileappend 'output_file$' soundfile,time,f0 'newline$'

# ITERATE OVER SOUNDFILES
for file_id from 1 to num_of_soundfiles

	# READ IN SOUND FILE NAME FROM LIST AND THEN OPEN FILE
	select Strings soundfiles_list
	sound_name$ = Get string... file_id
	Open long sound file... 'input_directory$'/'sound_name$'
	sound_name$ = left$(sound_name$, (length(sound_name$) - 4))
	sound_duration = Get total duration

	extract_start = 0.30

	# GO THROUGH THE SOUNDFILE AND MEASURE F0
	while extract_start < (sound_duration - hop_length)

		extract_end = extract_start + hop_length

		selectObject: "LongSound 'sound_name$'"
		Extract part: 'extract_start', 'extract_end', "yes"
		To Pitch: 0, pitch_floor, pitch_ceiling

		measurement_point = extract_start + (hop_length/2)
		f0 = Get value at time: 'measurement_point', "Hertz", "linear"
		if string$(f0) == "--undefined--"
			f0 = 0
		endif

		# RECORD FORMANT MEASUREMENTS IN OUTPUT FILE
		printline 'sound_name$','measurement_point','f0','sound_duration'
		fileappend 'output_file$' 'sound_name$', 'measurement_point', 'f0' 'newline$'

		# update extract_start
		extract_start = extract_end

		selectObject: "Sound 'sound_name$'"
		plusObject: "Pitch 'sound_name$'"
		Remove
	endwhile

	selectObject: "LongSound 'sound_name$'"
	Remove
endfor

selectObject: "Strings soundfiles_list"
Remove
