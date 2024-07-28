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
//	a string, and setting the value of someObject.someProp to be
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
// SUBCLASSES
//
//	The base FileToProp class treats the file contents as a string.
//
//	FileToString is a subclass of FileToProp that does the same thing,
//	and is included in case you want to be explicit about the data type.
//
//	FileToListInt treats the file contents as a comma-separated array of
//	integers.  The file format should be something like:
//
//		1, 2, 3
//
//	...or, equivalently...
//
//		1,
//		2,
//		3
//
//	In general whitespace will be ignored.
//
//	FileToListString is similar, but creates an array of strings.
//
//	FileToListInt and FileToListString don't do anything special to
//	validate data, so it's up to you to make sure the files are
//	properly formatted.
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


// Singleton preinit object that handles polling all the FileToProp
// instances.
fileToProp: PreinitObject
	execute() {
		_preinitFileToProp();
	}

	// Ping each FileToProp instance.
	_preinitFileToProp() {
		forEachInstance(FileToProp, function(o) {
			o.initializeFileToProp();
		});
	}

	getFileHandle(fname) {
		return(File.openTextFile(FileName.fromUniversal(fname),
			FileAccessRead, 'utf8'));
	}

	// Load the given file and return a string containing the contents.
	fileToString(fname) {
		local buf, fileHandle, line;

		try {
			fileHandle = getFileHandle(fname);

			buf = new StringBuffer(fileHandle.getFileSize());

			line = fileHandle.readFile();

			while(line != nil) {
				buf.append(line);
				line = fileHandle.readFile();
			}

			fileHandle.closeFile();
		}

		catch(Exception e) {
			"<<fname>>:  File load failed: ";
			if(e) {
				"\t";
				e.displayException();
			} else {
				"MISSING EXCEPTION";
			}
			"\n ";
		}

		finally {
			if(buf != nil)
				return(toString(buf));
			else
				return(nil);
		}
	}
;

// Object defining the file to load and the property to assign the contents
// to.
FileToProp: object
	fname = nil		// file name
	prop = nil		// object property

	initializeFileToProp() {
		local buf;

		// Make sure we have a filename and a property to use.
		if((fname == nil) || (prop == nil))
			return;

		// Make sure we're declared "inside" another object, so
		// we an object to set the property on.
		if(location == nil)
			return;

		// Try to load the contents.  The contents of buf
		// will be a string or nil.
		if((buf = fileToProp.fileToString(fname)) == nil)
			return;

		// Set the property.
		setProperty(buf);
	}

	// By default we just assign the value to the property, which
	// will leave the property a string.
	setProperty(v) { (location).(prop) = v; }
;

// When we're explicitly using FileToString we take the additional
// step of stripping out newlines.
FileToString: FileToProp
	setProperty(v) {
		v = v.split(R'<newline>+').join(' ');
		(location).(prop) = toString(v);
	}
;

// FileToProp subclass that treats the file contents as an array of integers.
FileToListInt: FileToProp
	setProperty(data) {
		local l, v;

		l = data.split(',');
		v = new Vector(l.length);
		l.forEach(function(o) { v.append(toInteger(o)); });
		(location).(prop) = v.toList();
	}
;

// As above, but treat the file contents as an array of strings.
FileToListString: FileToProp
	setProperty(data) {
		local l, v;

		l = data.split(',');
		v = new Vector(l.length);
		l.forEach(function(o) { v.append(toString(o)); });
		(location).(prop) = v.toList();
	}
;

FileToDString: FileToProp
	setProperty(data) {
		location.setMethod(prop, new method() { "<<data>>"; });
	}
;
