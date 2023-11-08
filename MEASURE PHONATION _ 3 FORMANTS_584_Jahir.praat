#SCRIPT FOR MEASURING VOICE QUALITY MEASURES FROM FORCE ALIGNED TEXGRIDS
#WRITTEN BY Michael J. Fox 3/11/2013


#INPUT THE DIRECTORY THAT CONTAINS THE FILES AND TEXTGRIDS YOU WANT TO ANALYZE
directory$ = "C:\Users\user\Desktop\22"
measure_dir$ = "C:\Users\user\Desktop\22\"
max_form = 5
max_freq = 5000
c = 1

#READ THE FILE NAMES FROM THE SPECIFIED DIRECTORY
Create Strings as file list... wavlist 'directory$'/*.wav
Create Strings as file list... gridlist 'directory$'/*.TextGrid
num_strings = Get number of strings


#SET UP OUTPUT FILE
output_file$ = "phonation_output.txt"
header_line$ = "file,vowel_counter,word,phone_p,phone,phone_f,F0,f1_1, f1_2, f1_3, f2_1, f2_2, f2_3, f3_1, f3_2, f3_3,H1_dB,H2_dB,A1_dB,A2_dB,A3_dB,H1H2,H1A1,H1A2,H1A3"


fileappend "'output_file$'" 'header_line$''newline$'


#START THE PROCESS OF OPENING AND TAKING MEASUREMENTS
for file_counter from 1 to num_strings 
	
	#READ SOUND FILE NAME FROM LIST AND THEN OPEN FILE
	select Strings wavlist
	soundname$ = Get string... file_counter
	Open long sound file... 'directory$'/'soundname$'
	soundname$ = left$(soundname$, (length(soundname$) - 4))

	#READ TEXTGRID FILE NAME FROM LIST AND THEN OPEN FILE
	select Strings gridlist
	gridstr_name$ = selected$ ("Strings")
	gridname$ = Get string... file_counter
	Read from file... 'directory$'/'gridname$'
	num_intervals = Get number of intervals... 1

	#ITERATE OVER THE INTERVALS IN THE TEXTGRID AND DECIDE WHICH ONES WE WANT TO MEASURE
	for vowel_counter from 1 to num_intervals
		select TextGrid 'soundname$'
		phone$ = Get label of interval... 1 vowel_counter

		#SEE IF THE INTERVAL LABEL IS A PHONE [SINCE THE FORCE ALIGNER USES ONLY NUMERIC DIGITS (0,1 OR 2?) A THE END, THE COMMAND LOOKS FOR PHONE INTERVALS THAT HAVE THE DIGITS AT THE END)
		 if right$(phone$, 1) == "0" or right$(phone$, 1) == "1" or right$(phone$, 1) == "2" 


			#GET INTERVAL INFORMATION
			onset = Get starting point... 1 vowel_counter
			offset = Get end point... 1 vowel_counter
			phone_p$ = Get label of interval... 1 vowel_counter - 1
			phone_f$ = Get label of interval... 1 vowel_counter + 1

			quart = onset + ((offset-onset)/4)
			mid = onset + ((offset-onset)/2)
			threequart = onset + ((offset-onset)/4)*3

			word_lab = Get interval at time... 2 mid

			word$ = Get label of interval... 2 word_lab
			if phone_p$ = "sp"
				phone_p$ = "#"
			endif
			if phone_f$ = "sp"
				phone_f$ = "#"
			endif
			
			#CREATE THE OBJECTS FOR MEASUREMENT
			select LongSound 'soundname$'
			Extract part... onset offset yes
			To Ltas... 100
			select Sound 'soundname$'
			To Formant (burg)... 0 'max_form' 'max_freq' 0.025 50
			select Sound 'soundname$'
			To Pitch (ac)... 0.0005 97 15 no 0.03 0.45 0.01 0.35 0.14 600
			select Sound 'soundname$'

#MEASUREMENTS FORMANTS
select Formant 'soundname$'

	f1_1 = Get value at time... 1 'quart' Hertz Linear
	f1_2 = Get value at time... 1 'mid' Hertz Linear
        f1_3 = Get value at time... 1 'threequart' Hertz Linear
	f2_1 = Get value at time... 2 'quart' Hertz Linear
        f2_2 = Get value at time... 2 'mid' Hertz Linear
        f2_3 = Get value at time... 2 'threequart' Hertz Linear
	f3_1 = Get value at time... 3 'quart' Hertz Linear
	f3_2 = Get value at time... 3 'mid' Hertz Linear
	f3_3 = Get value at time... 3 'threequart' Hertz Linear


			#MAKE MEASUREMENTS
			select Formant 'soundname$'
			f1 = Get mean... 1 0 0 Hertz
			f2 = Get mean... 2 0 0 Hertz
			f3 = Get mean... 3 0 0 Hertz
			f1_a = f1-75
			f1_b = f1+75
			f2_a = f2-100
			f2_b = f2+100
			f3_a = f3-150
			f3_b = f3+150
		
			select Pitch 'soundname$'
			f0 = Get mean... 0 0 Hertz
			f0$ = Get mean... 0 0 Hertz
			if f0$ = "--undefined--"
				goto skipit
			endif

			h1_a = f0 - 30
			h1_b = f0 + 30
			h2_a = (f0 * 2) - 30
			h2_b = (f0 * 2) + 30


			select Ltas 'soundname$'
			a1 = Get maximum... f1_a f1_b None
			a2 = Get maximum... f2_a f2_b None
			a3 = Get maximum... f3_a f3_b None
			h1 = Get maximum... h1_a h1_b Parabolic
			h2 = Get maximum... h2_a h2_b Parabolic
			h1h2 = h1-h2
			h1a1 = h1-a1
			h1a2 = h1-a2
			h1a3 = h1-a3

			#SAVE VARIABLES TO SPREADSHEET AND CLEAN UP
			fileappend "'output_file$'" 'soundname$','c','word$','phone_p$','phone$','phone_f$','f0','f1_1', 'f1_2', 'f1_3', 'f2_1', 'f2_2', 'f2_3', 'f3_1', 'f3_2', 'f3_3','h1','h2','a1','a2','a3','h1h2','h1a1','h1a2','h1a3''newline$'
			c = c + 1
			label skipit
			plus Ltas 'soundname$'
			plus Formant 'soundname$'
			plus Pitch 'soundname$'
			plus Sound 'soundname$'
			Remove
		endif
	endfor
endfor
select all
Remove