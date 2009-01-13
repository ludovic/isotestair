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
	import flash.utils.ByteArray;
	
	public class GZIPFile
	{
		// ------- Private vars -------
		private var _gzipFileName:String;
		private var _compressedData:ByteArray;
		private var _headerFileName:String;
		private var _headerComment:String;
		private var _fileModificationTime:Date;
		private var _originalFileSize:uint;
		
		
		// ------- Constructor -------
		public function GZIPFile(compressedData:ByteArray, 
									originalFileSize:uint, 
									fileModificationTime:Date, 
									gzipFileName:String="", 
									headerFileName:String=null,
									headerComment:String=null)
		{
			_compressedData = compressedData;
			_originalFileSize = originalFileSize;
			_fileModificationTime = fileModificationTime;
			_gzipFileName = gzipFileName;
			_headerFileName = headerFileName;
			_headerComment = headerComment;
		}
		
		
		// ------- Public properties -------
		public function get gzipFileName():String
		{
			return _gzipFileName;
		}
		
		
		public function get headerFileName():String
		{
			return _headerFileName;
		}
		
		
		public function get headerComment():String
		{
			return _headerComment;
		}
		
		
		public function get fileModificationTime():Date
		{
			return _fileModificationTime;
		}
		
		
		public function get originalFileSize():uint
		{
			return _originalFileSize;
		}
		
		
		// ------- Public methods -------
		/**
		 * Retrieves a copy of the compressed data bytes extracted from the GZIP file.
		 * Modifications to the result ByteArray, including uncompressing, do not
		 * alter the result of future calls to this method.
		 * 
		 * @returns	A copy of the compressed data bytes contained in the ByteArray.
		 * 			Call the <code>ByteArray.inflate()</code> method on the result
		 * 			for the uncompressed data.
		 * 
		 * @see flash.data.ByteArray#inflate()
		 */
		public function getCompressedData():ByteArray
		{
			var result:ByteArray = new ByteArray();
			_compressedData.position = 0;
			_compressedData.readBytes(result, 0, _compressedData.length);
			return result;
		}
	}
}