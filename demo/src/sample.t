#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the fileToProp library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "fileToProp.h"


versionInfo: GameID;
gameMain: GameMainDef
	textString = nil
	loadedList = nil

	newGame() {
		"\ntextString:  <<toString(textString)>>\n ";
		"<.p> ";
		"\nloadedList:  ";
		if(loadedList.ofKind(List)) {
			loadedList.forEach(function(o) {
				"\n\t<<toString(o)>>\n ";
			});
		} else {
			"NOT LIST\n ";
		}
	}
;
+FileToProp 'text.txt' ->(&textString);
+FileToListInt 'list.txt' ->(&loadedList);
