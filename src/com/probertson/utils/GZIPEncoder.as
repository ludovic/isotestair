/*
For the latest version of this code, visit:
http://probertson.com/projects/gzipencoder/

***** BEGIN LICENSE BLOCK *****
Version: MPL 1.1

The contents of this file are subject to the Mozilla Public License Version 
1.1 (the "License"); you may not use this file except in compliance with 
the License. You may obtain a copy of the License at 
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
for the specific language governing rights and limitations under the
License.

The Original Code is a GZIP format encoder.

The Initial Developer of the Original Code is
H. Paul Robertson.
Portions created by the Initial Developer are Copyright (C) 2007
the Initial Developer. All Rights Reserved.

Contributor(s):

***** END LICENSE BLOCK *****
*/

package com.probertson.utils
{
	import flash.errors.IllegalOperationError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	
	public class GZIPEncoder
	{
	
		/**
		 * Writes a GZIP compressed file format file to a file stream.
		 * 
		 * <p>This particular method takes a "least effort" approach, meaning any optional
		 * metadata fields are not included in the GZIP file that's written to disk.</p>
		 * 
		 * @param src	The source data to compress and embed in the GZIP file. The source
		 * 				can be a file on the filesystem (a File instance), in which case the contents of the
		 * 				file are read, compressed, and output to the file stream. Alternatively, the source can be a 
		 * 				ByteArray instance, in which case the ByteArray's contents are compressed and output to the
		 * 				file stream.
		 * 
		 * @param output	The File location to which the compressed GZIP format file should be written. 
		 * 					The user should have permission to write to the file location. If the location
		 * 					specifies a file name, that file name will be used. If the output location is 
		 * 					a directory, a new file will be created with the name "[src file name].gz". If src
		 * 					is a ByteArray, and output only specifies a directory, the output file will
		 * 					be created with the name "output.gz".
		 * 
		 * @throws ArgumentError	If the <code>src</code> argument is not a File or ByteArray instance; if
		 * 							the <code>src</code> argument refers to a directory or a non-existent file;  or if
		 * 							either argument is null.
		 */
		public function compressToFile(src:Object, output:File):void
		{
			if (src == null || output == null)
			{
				throw new ArgumentError("src and outStream cannot be null.");
			}
			
			var srcBytes:ByteArray;
			var target:File = new File(output.nativePath);
			
			var fileTime:Date;
			
			if (src is File)
			{
				var srcFile:File = src as File;
				if (!srcFile.exists || srcFile.isDirectory)
				{
					throw new ArgumentError("If src is a File instance, it must specify the location of an existing file (not a directory).");
				}
				
				var srcStream:FileStream = new FileStream();
				srcStream.open(srcFile, FileMode.READ);
				srcBytes = new ByteArray();
				srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
				srcStream.close();
				
				if (target.isDirectory)
				{
					target = target.resolvePath(srcFile.name + ".gz");
				}
				
				fileTime = srcFile.modificationDate;
			}
			else if (src is ByteArray)
			{
				srcBytes = src as ByteArray;
				
				if (target.isDirectory)
				{
					target = target.resolvePath("output.gz");
				}
				
				fileTime = new Date();
			}
			else
			{
				throw new ArgumentError("src must be a File instance or a ByteArray instance");
			}
			
			var outStream:FileStream = new FileStream();
			outStream.open(target, FileMode.WRITE);
			
			// For details of gzip format, see IETF RFC 1952:
			// http://www.ietf.org/rfc/rfc1952
			
			// gzip is little-endian
			outStream.endian = Endian.LITTLE_ENDIAN;
			
			// 1 byte ID1 -- should be 31/0x1f
			var id1:uint = 31;
			outStream.writeByte(id1);
			
			// 1 byte ID2 -- should be 139/0x8b
			var id2:uint = 139;
			outStream.writeByte(id2);
			
			// 1 byte CM -- should be 8 for DEFLATE
			var cm:uint = 8;
			outStream.writeByte(cm);
			
			// 1 byte FLaGs
			var flags:int = parseInt("00000000", 2);
			outStream.writeByte(flags);
			
			// 4 bytes MTIME (Modification Time in Unix epoch format; 0 means no time stamp is available)
			var mtime:uint = fileTime.time;
			outStream.writeUnsignedInt(mtime);
			
			// 1 byte XFL (flags used by specific compression methods)
			var xfl:uint = parseInt("00000100", 2);
			outStream.writeByte(xfl);
			// 1 byte OS
			var os:uint;
			if (Capabilities.os.indexOf("Windows") >= 0)
			{
				os = 11; // NTFS -- WinXP, Win2000, WinNT
			}
			else if (Capabilities.os == "MacOS")
			{
				os = 3; // Unix
			}
			outStream.writeByte(os);
			
			// calculate crc32 and filesize before compressing data
			var crc32Gen:CRC32Generator = new CRC32Generator();
			var crc32:uint = crc32Gen.generateCRC32(srcBytes);
			
			var isize:uint = srcBytes.length % Math.pow(2, 32);
			
	 		// Actual compressed data (up to end - 8 bytes)
			srcBytes.compress(CompressionAlgorithm.DEFLATE);
			outStream.writeBytes(srcBytes, 0, srcBytes.length);
			
			// 4 bytes CRC32
	 		outStream.writeUnsignedInt(crc32);
	 		
			// 4 bytes ISIZE (input size -- size of the original input data modulo 2^32)
			outStream.writeUnsignedInt(isize);
			outStream.close();
		}
		
		
		/**
		 * Uncompresses a GZIP-compressed-format file to another file location.
		 * 
		 * @param src	The filesystem location of the GZIP format file to uncompress.
		 * 
		 * @param output	The filesystem location where the uncompressed file should be saved.
		 * 					If <code>output</code> specifies a file name, that file name will be used
		 * 					for the new file, regardless of the original file name. If the argument 
		 * 					specifies a directory, the uncompressed file will be saved in that directory. In
		 * 					that case, if the GZIP file includes file name information, the new file will
		 * 					be saved with the original file name; if no file name is present, the new file
		 * 					will be saved with the name of the source GZIP file, minus the ".gz" or ".gzip"
		 * 					extension.
		 * 
		 * @throws ArgumentError	If <code>src</code> or <code>output</code> argument is null; 
		 * 							if <code>src</code> is a directory rather than a file; or
		 * 							if <code>src</code> points to a file location that doesn't exist.
		 */
		public function uncompressToFile(src:File, output:File):void
		{
			if (output == null)
			{
				throw new ArgumentError("output cannot be null");
			}
			
			// throws errors if src is invalid
			var gzipData:GZIPFile = parseGZIPFile(src);
		    var outFile:File = new File(output.nativePath);
			if (outFile.isDirectory)
			{
				var fileName:String;
				if (gzipData.headerFileName != null)
				{
					fileName = gzipData.headerFileName;
				}
				else if (gzipData.gzipFileName.lastIndexOf(".gz") == gzipData.gzipFileName.length - 3)
				{
					fileName = gzipData.gzipFileName.substr(0, gzipData.gzipFileName.length - 3);
				}
				else if (gzipData.gzipFileName.lastIndexOf(".gzip") == gzipData.gzipFileName.length - 5)
				{
					fileName = gzipData.gzipFileName.substr(0, gzipData.gzipFileName.length - 5);
				}
				else
				{
					fileName = gzipData.gzipFileName;
				}
				
				outFile = outFile.resolvePath(fileName);
			}
			
			var data:ByteArray = gzipData.getCompressedData();
			try
			{
				data.uncompress(CompressionAlgorithm.DEFLATE);
			}
			catch (error:Error)
			{
				throw new IllegalOperationError("The specified file is not a GZIP file format file.");
			}
			var outStream:FileStream = new FileStream();
			outStream.open(outFile, FileMode.WRITE);
			outStream.writeBytes(data,0,data.length);
			outStream.close();
		}
		
		
		/**
		 * Uncompresses a GZIP-compressed-format file to a ByteArray object.
		 * 
		 * @param src	The location of the source file to uncompress. This file must
		 * 				be a file that is compressed using the GZIP file format.
		 * 
		 * @returns		A ByteArray containing the uncompressed bytes that were
		 * 				compressed and encoded in the source file.
		 * 
		 * @throws ArgumentError	If the <code>src</code> argument is null; refers
		 * 							to a directory; or refers to a file that doesn't
		 * 							exist.
		 * 
		 * @throws IllegalOperationError If the specified file is not a GZIP-format file.
		 */
		public function uncompressToByteArray(src:File):ByteArray
		{
			// throws errors if src isn't valid
			var gzipData:GZIPFile = parseGZIPFile(src);
			var data:ByteArray = gzipData.getCompressedData();
			
			try
			{
				data.uncompress(CompressionAlgorithm.DEFLATE);
			}
			catch (error:Error)
			{
				throw new IllegalOperationError("The specified file is not a GZIP file format file.");
			}
			return data;
		}
		
		
		/**
		 * Parses a GZIP-format file into an object with properties representing the important
		 * characteristics of the GZIP file (the header and footer metadata, as well as the 
		 * actual compressed data).
		 * 
		 * @param src	The filesystem location of the GZIP file to parse.
		 * 
		 * @returns		An object containing the information from the source GZIP file.
		 * 
		 * @throws ArgumentError	If the <code>src</code> argument is null; refers
		 * 							to a directory; or refers to a file that doesn't
		 * 							exist.
		 * 
		 * @throws IllegalOperationError If the specified file is not a GZIP-format file.
		 */
		public function parseGZIPFile(src:File):GZIPFile
		{
			// throws errors if src isn't valid
			checkSrcFile(src);
			
			var srcFile:File = new File(src.nativePath);
			
			var srcStream:FileStream = new FileStream();
			srcStream.open(srcFile, FileMode.READ);
			var srcBytes:ByteArray = new ByteArray();
			srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
			srcStream.close();

			// For details of gzip format, see IETF RFC 1952:
			// http://www.ietf.org/rfc/rfc1952
			
			// gzip is little-endian
			srcBytes.endian = Endian.LITTLE_ENDIAN;
			
			// 1 byte ID1 -- should be 31/0x1f or else throw an error
			var id1:uint = srcBytes.readUnsignedByte();
			if (id1 != 0x1f)
			{
				throw new IllegalOperationError("The specified file is not a GZIP file format file.");
			}
			
			// 1 byte ID2 -- should be 139/0x8b or else throw an error
			var id2:uint = srcBytes.readUnsignedByte();
			if (id2 != 0x8b)
			{
				throw new IllegalOperationError("The specified file is not a GZIP file format file.");
			}

			// 1 byte CM -- should be 8 for DEFLATE or else throw an error
			var cm:uint = srcBytes.readUnsignedByte();
			if (cm != 8)
			{
				throw new IllegalOperationError("The specified file is not a GZIP file format file.");
			}
			
			// 1 byte FLaGs
			var flags:int = srcBytes.readByte();
			
			// ftext: the file is probably ASCII text
			var hasFtext:Boolean = ((flags >> 7) & 1) == 1;
			
			// fhcrc: a CRC16 for the gzip header is present
			var hasFhcrc:Boolean = ((flags >> 6) & 1) == 1;
			
			// fextra: option extra fields are present
			var hasFextra:Boolean = ((flags >> 5) & 1) == 1;
			
			// fname: an original file name is present, terminated by a zero byte
			var hasFname:Boolean = ((flags >> 4) & 1) == 1;
			
			// fcomment: a zero-terminated file comment (intended for human consumption) is present
			var hasFcomment:Boolean = ((flags >> 3) & 1) == 1;
			
			// must throw an error if any of the remaining bits are non-zero
			var flagsError:Boolean = false;
			flagsError = ((flags >> 2) & 1 == 1) ? true : flagsError;
			flagsError = ((flags >> 1) & 1 == 1) ? true : flagsError;
			flagsError = (flags & 1 == 1) ? true : flagsError;
			if (flagsError)
			{
				throw new IllegalOperationError("The specified file is not a GZIP file format file.");
			}
			
			// 4 bytes MTIME (Modification Time in Unix epoch format; 0 means no time stamp is available)
			var mtime:uint = srcBytes.readUnsignedInt();
			
			// 1 byte XFL (flags used by specific compression methods)
			var xfl:uint = srcBytes.readUnsignedByte();
			
			// 1 byte OS
			var os:uint = srcBytes.readUnsignedByte();
			
			// (if FLG.EXTRA is set) 2 bytes XLEN, XLEN bytes of extra field
			if (hasFextra)
			{
				var extra:String = srcBytes.readUTF();
			}
			
			// (if FLG.FNAME is set) original filename, terminated by 0
			var fname:String = null;
	 		if (hasFname)
			{
				var fnameBytes:ByteArray = new ByteArray();
				while (srcBytes.readUnsignedByte() != 0)
				{
					// move position back by 1 to make up for the readUnsignedByte() in the conditional
					srcBytes.position -= 1;
					fnameBytes.writeByte(srcBytes.readByte());
				}
				fnameBytes.position = 0;
				fname = fnameBytes.readUTFBytes(fnameBytes.length);
			}
			
			// (if FLG.FCOMMENT is set) file comment, zero terminated
			var fcomment:String;
	 		if (hasFcomment)
			{
				var fcommentBytes:ByteArray = new ByteArray();
				while (srcBytes.readUnsignedByte() != 0)
				{
					// move position back by 1 to make up for the readUnsignedByte() in the conditional
					srcBytes.position -= 1;
					fcommentBytes.writeByte(srcBytes.readByte());
				}
				fcommentBytes.position = 0;
				fcomment = fcommentBytes.readUTFBytes(fcommentBytes.length);
			}
			
			// (if FLG.FHCRC is set) 2 bytes CRC16
	 		if (hasFhcrc)
			{
				var fhcrc:int = srcBytes.readUnsignedShort();
			}
			
			// Actual compressed data (up to end - 8 bytes)
			var dataSize:int = (srcBytes.length - srcBytes.position) - 8;
			var data:ByteArray = new ByteArray();
			srcBytes.readBytes(data, 0, dataSize);
			
			// 4 bytes CRC32
			var crc32:uint = srcBytes.readUnsignedInt();
			
			// 4 bytes ISIZE (input size -- size of the original input data modulo 2^32)
			var isize:uint = srcBytes.readUnsignedInt();
			
			return new GZIPFile(data, isize, new Date(mtime), src.name, fname, fcomment);
		}
		
		
		// ------- Private functions -------
		private function checkSrcFile(src:File):void
		{
			if (src == null)
			{
				throw new ArgumentError("src cannot be null");
			}
			
			if (src.isDirectory)
			{
				throw new ArgumentError("src must refer to the location of a file, not a directory");
			}
			
			if (!src.exists)
			{
				throw new ArgumentError("src refers to a file that doesn't exist");
			}
		}
	}
}