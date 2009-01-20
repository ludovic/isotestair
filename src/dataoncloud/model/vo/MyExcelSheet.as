package dataoncloud.model.vo
{
	public class MyExcelSheet
	{
		public var path:String;
		public var sheetName:String;
		
		public function MyExcelSheet(path:String,sheetName:String)
		{
			this.path=path;
			this.sheetName=sheetName;
		}

	}
}