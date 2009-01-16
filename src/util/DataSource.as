// ActionScript file
package util
{
import flash.utils.IExternalizable;
import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	public class DataSource implements IExternalizable {
	
	public var BimeDesktop:String;
	public var mdp:String;
	public var url:String;
	public var type:String;
	
		public function DataSource(){
		}
	 public function readExternal(input:IDataInput):void {
       	BimeDesktop = input.readObject() as String;
       	mdp = input.readObject() as String;
        url = input.readObject() as String;
        type = input.readObject() as String;
    }
    
    public function writeExternal(output:IDataOutput):void {
        output.writeObject(BimeDesktop);
        output.writeObject(mdp);
        output.writeObject(url);
        output.writeObject(type);
    }

	
	}
}