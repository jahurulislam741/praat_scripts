
###################################################################
###	extract audio and corresponding TextGrid clips based on specific labels in TG
### Works iteratively for all audio-TG pairs stored in a folder
### By Jahurul Islam, UBC, Vancouver, Apr. 26, 2023
###################################################################

clearinfo

# USER INPUT
input_dir$ = "input_audio_and_TGs"
output_dir$ = "output_clips"
createFolder: output_dir$
target_tier_id = 1

# READ THE FILE NAMES FROM THE SPECIFIED input_dir
Create Strings as file list... sound_list 'input_dir$'/*.wav
Create Strings as file list... tg_list 'input_dir$'/*.TextGrid
num_of_soundfiles = Get number of strings

# LOOP THROUGH FILES
for file_id from 1 to num_of_soundfiles
	# READ IN SOUND FILE NAME FROM LIST AND THEN OPEN FILE
	select Strings sound_list
	sound_name$ = Get string... file_id
	Open long sound file... 'input_dir$'/'sound_name$'
	sound_name$ = left$(sound_name$, (length(sound_name$) - 4))

	# READ IN TEXTGRID FILE NAME FROM LIST AND THEN OPEN FILE
	select Strings tg_list
	tg_name$ = Get string... file_id
	Read from file... 'input_dir$'/'tg_name$'
	tg_name$ = left$(tg_name$, (length(tg_name$) - 9))
	num_of_intervals = Get number of intervals... target_tier_id ; get the number of intervals in target tier

	if sound_name$ != tg_name$
		exitScript: "No TextGrid named ['sound_name$'] was found. "
	endif

	# GO THROUGH THE PHONE INTERVALS ONE BY ONE
	for i from 2 to num_of_intervals-1
		selectObject: "TextGrid 'tg_name$'"
		interval_label$ = Get label of interval: target_tier_id, i

		if interval_label$ != "<p:>"
			#GET START AND END TIME OF CURRENT INTERVAL
			interval_start = Get starting point: target_tier_id, i
			interval_end = Get end point: target_tier_id, i

			# GET DURATION OF FOLLOWING INTERVAL
			foll_interval_start = Get starting point: target_tier_id, i + 1
			foll_interval_end = Get end point: target_tier_id, i + 1
			foll_interval_dur = foll_interval_end - foll_interval_start

			# DETERMINE THE PAD DURATION to be added before and after the chunk
			if foll_interval_dur > 0.200
				pad_dur =  randomInteger(50, 300)/1000
			else
				pad_dur =  randomInteger(20, 150)/1000
			endif

			extract_start = interval_start - pad_dur
			extract_end = interval_end + pad_dur

			# EXTRACT THE AUDIO AND CORRESPONDING PARTS OF THE TEXTGRID
			selectObject: "LongSound 'sound_name$'"
			Extract part: extract_start, extract_end, "no"
			fname$ = "'interval_label$'" + "_" + "'i'"
			out_wav_fpath$ = "'output_dir$'" + "/" + "'fname$'" + ".wav"
			Save as WAV file: out_wav_fpath$
			Remove

			selectObject: "TextGrid 'tg_name$'"
			# Extract part: 0, 1, "yes"
			Extract part: extract_start, extract_end, "no"
			# Shift times to: "start time", 0
			out_TG_fpath$ = "'output_dir$'" + "/" + "'fname$'" + ".TextGrid"
			Save as text file: out_TG_fpath$
			Remove

			printline 'sound_name$', 'interval_label$'
		endif
	endfor

	selectObject: "LongSound 'sound_name$'"
	plusObject: "TextGrid 'sound_name$'"
	Remove
endfor

selectObject: "Strings tg_list"
plusObject: "Strings sound_list"
Remove
