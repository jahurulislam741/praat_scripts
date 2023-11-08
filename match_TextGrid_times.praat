# Walk through a directory of sound and textGrid
# file pairs.  clone the time domain from the tg to
# the matching sound file.
# Fixes a problem where
# concatenating sounds and textfiles results in
# later intervals or points being misaligned
#
# tg and snd files are assumed named in the form:
# FileName.snd and FileName.TextGrid

# kbmcgowan@stanford.edu - 7-10-14

if praatVersion < 5379
     printline This script requires Praat v5.3.79 or newer.  Please update your version ('praatVersion$')
     exit
endif

form What files are we working on?
    sentence Directory input_dir
    word SoundExtension wav
    word tgExtension TextGrid
    boolean BackupOriginal 1
    comment Leave Sounds and TextGrids in objects window?
    boolean Leave 0
endform

count = 0

# get a list of all tg files in the given Directory
listID = Create Strings as file list: "files", directory$ + "/*." + tgExtension$

nFiles = Get number of strings
writeInfoLine: nFiles, " TextGrid files in ", directory$

# step through the list of files
for i to nFiles
    selectObject: listID
    fileName$ = Get string: i
    file$ = fileName$ - ".'tgExtension$'"

    snd$ = directory$ + "/" + file$ + "." + soundExtension$
    grid$ = directory$ + "/" + file$ + "." + tgExtension$

    sndID = Read from file: snd$
    Shift times to: "start time", 0

    if fileReadable ( grid$ )
        # open the textgrid file if it exists and is readable
        tgID = Read from file: grid$
        Shift times to: "start time", 0

        td = Get end time
        plusObject: sndID
        Clone time domain

        selectObject: sndID
        newID = Extract part: 0, td, "rectangular", 1, "no"
        Save as WAV file: snd$ 
        removeObject: newID
        count = count + 1

	if backupOriginal
	    selectObject: sndID
	    Save as WAV file:  directory$ + "/" + file$ + "-original.wav"
	endif

	if leave = 0
	    removeObject: sndID
	    removeObject: tgID
	endif
    else
        appendInfoLine: "Error! expected tg does not exist: ", grid$
    endif
endfor

removeObject: listID

appendInfoLine: "Done!  ", count, " sound files have been modified to match their TextGrids"