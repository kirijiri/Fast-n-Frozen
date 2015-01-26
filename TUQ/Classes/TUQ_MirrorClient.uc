//------------------------------------------------------------------------------
// Der CameraTextureClient für den Rückspiegel
// Eine Art Controller für eine ScriptedTexture
// wichtig: bNoDelete = False, damit es zur Laufzeit erstellt werden kann
//
// Author: RM
//------------------------------------------------------------------------------
class TUQ_MirrorClient extends CameraTextureClient;

//
//	RenderTexture
//
simulated event RenderTexture(ScriptedTexture Tex)
{
	//log("----------> Render Event!");
    if(CameraActor != None)
		Tex.DrawPortal(0,0,Tex.USize,Tex.VSize,CameraActor,CameraActor.Location,CameraActor.Rotation,FOV);
}

DefaultProperties
{
    bNoDelete=false
    bAlwaysRelevant=True
}
