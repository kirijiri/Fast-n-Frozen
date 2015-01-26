//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TUQ_AnimMesh_CheckPoint extends TUQ_AnimActor;

DefaultProperties
{
    Mesh=SkeletalMesh'TUQCheckPoint.Checkpoint'

    Skins[0] = Material'TUQCheckpoint.shader.shader'

    AnimName="Checkpoint"

    Physics=PHYS_Flying
}
