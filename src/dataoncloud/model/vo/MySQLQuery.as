package dataoncloud.model.vo
{
	public class MySQLQuery
	{
		public var connection:Object;
		public var query:String;
		
		public function MySQLQuery(connection:Object,query:String)
		{
			this.connection=connection;
			this.query=query;
		}


	}
}