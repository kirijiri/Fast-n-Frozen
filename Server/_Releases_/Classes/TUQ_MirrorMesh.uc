//------------------------------------------------------------------------------
// Das Mesh für den Rückspiegel
// Hier kann man bequem die DefaultProperties setzen
//
// Author: RM
//------------------------------------------------------------------------------
class TUQ_MirrorMesh extends Actor;

defaultproperties
{
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'TUQMirrorMesh.Screen.Mirror'
    bHidden=True
    bAcceptsProjectors=False
    bAlwaysRelevant=True
    RemoteRole=ROLE_None
    Skins[0]=Material'Engine.DefaultTexture'
    bUnlit=True
    bHardAttach=True
    bStatic=false
    bNoDelete=false
    DrawScale=1
}

