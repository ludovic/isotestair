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

The Original Code is a CRC32 Generator.

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
	
	// For details of CRC32 encoding, see notes in IETF RFC 1952:
	// http://www.ietf.org/rfc/rfc1952.txt
	public class CRC32Generator
	{
		// ------- CRC Table -------
		private static var _crcTable:Array;
		private static var _tableComputed:Boolean = false;
		private static function makeCRCTable():void
		{
			_crcTable = new Array(256);
			var val:uint;
			for (var i:int = 0; i < 256; i++)
			{
				val = i;
				for (var j:int = 0; j < 8; j++)
				{
					if ((val & 1) != 0)
					{
						val = 0xedb88320 ^ (val >>> 1);
					}
					else
					{
						val = val >>> 1;
					}
				}
				_crcTable[i] = val;
			}
			_tableComputed = true;
		}
		
		
		// ------- Constructor -------
		public function CRC32Generator()
		{
			
		}
		
		
		// ------- Public methods -------
		public function generateCRC32(buffer:ByteArray):uint
		{
			if (!_tableComputed)
			{
				makeCRCTable();
			}
			var result:uint = ~0;
			var len:int = buffer.length;
			for (var i:int = 0; i < len; i++)
			{
				result = _crcTable[(result ^ buffer[i]) & 0xff] ^ (result >>> 8);
			}
			result = ~result;
			
			return (result & 0xffffffff);
		}
	}
}