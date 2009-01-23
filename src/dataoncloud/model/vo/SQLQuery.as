package dataoncloud.model.vo
{
	public class SQLQuery
	{
		public var connection:Object;
		public var query:String;
		
		public function SQLQuery(connection:Object,query:String)
		{
			this.connection=connection;
			this.query=query;
		}


	}
}