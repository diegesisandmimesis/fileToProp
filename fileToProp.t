#charset "us-ascii"
//
// fileToProp.t
//
//	A simple TADS3 module for loading the contents of a file during
//	preinit and assigning the contents to a property on an object.
//
//
// USAGE
//
//	This will load the contents of a file called "fileName.txt" as
//	as a string, and setting the value of someObject.someProp to be
//	the result.
//
//		someObject: object
//			someProp = nil
//		;
//		+FileToProp 'fileName.txt' ->(&someProp);
//
//	The file path is relative to the default location checked for by
//	the compiler, which by default will be the directory the compiled
//	story file will end up in.
//
//	The file has to be present at preinit but not at runtime (except
//	for debugging builds, where preinit occurs at runtime).
//
//
#include <adv3.h>
#include <en_us.h>

// Module ID for the library
fileToPropModuleID: ModuleID {
        name = 'File To Prop Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

fileToProp: PreinitObject
	execute() {
		_preinitFileToProp();
	}

	_error(msg) { aioSay('\nFileToProp error:  <<msg>>\n '); }

	_fileToString(fname) {
		local buf, fileHandle, line;

		try {
			fileHandle = File.openTextFile(fname, FileAccessRead,
				'utf8');

			buf = new StringBuffer(fileHandle.getFileSize());

			line = fileHandle.readFile();

			while(line != nil) {
				buf.append(line);
				line = fileHandle.readFile();
			}
			fileHandle.closeFile();
		}
		catch(Exception e) {
			_error('<<fname>>:  File load failed:', e);
		}
		finally {
			if(buf != nil)
				return(toString(buf));
			else
				return(nil);
		}
	}

	fileToProperty(obj, prop, fname) {
		local v;

		if((v = _fileToString(fname)) == nil) {
			_error('failed to read file <<fname>>');
			return(nil);
		}
		(obj).(prop) = v;
		return(true);
	}

	_preinitFileToProp() {
		forEachInstance(FileToProp, function(o) {
			o.initializeFileToProp();
		});
	}
;

FileToProp: object
	fname = nil
	prop = nil

	initializeFileToProp() {
		if((fname == nil) || (prop == nil))
			return;
		if(location == nil)
			return;
		fileToProp.fileToProperty(location, prop, fname);
	}
;
