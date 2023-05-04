package;

@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class AssetPaths 
{
	public static inline var LOC_DATA:String = "assets/data/";
	public static inline var LOC_IMGS:String = "assets/images/";
	public static function getFile(File:String, Location:String = LOC_IMGS, FileType:String = "png"):String
	{
		return Location + File + "." + FileType;
	}
}