//-----------------------------------------------------------
// Oberklasse für alles was im Inventar verstaut werden kann
//-----------------------------------------------------------
class TUQ_Item extends Inventory;

var() Material inventoryIconMaterial;
var() sound    inventoryUseSound;
var() bool     inventoryIsCountable;
var() int      inventoryCount;

////////////////////////////////////////////////////////////////////////
// UseItem
//
// Wird aufgerufen, wenn dieser Gegenstand verwendet werden soll
////////////////////////////////////////////////////////////////////////
function UseItem( Pawn Target )
{
    if( inventoryUseSound != none )
        Target.PlaySound(inventoryUseSound, SLOT_Interact);

    self.Destroy();
}

////////////////////////////////////////////////////////////////////////
// AddItem
//
// Wird aufgerufen, wenn der selbe Gegenstand hinzugefügt wird
////////////////////////////////////////////////////////////////////////
function bool AddItem( Pawn Target, TUQ_Item Item )
{
    // Der gleiche Typ?
    if( self.Name != Item.Name )
        return false;
    // Ist es überhaupt zählbar?
    if( inventoryIsCountable == false )
        return false;

    // Die entsprechende Anzahl hinzufügen
    inventoryCount += Item.inventoryCount;

    return true;
}

////////////////////////////////////////////////////////////////////////
// RemoveItem
//
// Wird aufgerufen, wenn der selbe Gegenstand entfernt wird
////////////////////////////////////////////////////////////////////////
function bool RemoveItem( Pawn Target, TUQ_Item Item )
{
    // Der gleiche Typ?
    if( self.Name != Item.Name )
        return false;
    // Ist es überhaupt zählbar?
    if( inventoryIsCountable == false )
        return false;

    // Die entsprechende Anzahl entfernen
    inventoryCount -= Item.inventoryCount;

    return true;
}

////////////////////////////////////////////////////////////////////////
// HandlePickupQuery
//
// Wird aufgerufen, wenn dieser Gegenstand in das Inventar eingefügt werden soll
////////////////////////////////////////////////////////////////////////
function bool HandlePickupQuery( Pickup ThePickUp )
{
    local TUQ_Item NewItem;

  // Zählbar?
    if( inventoryIsCountable == true )
    {
        // Der selbe Typ?
        if( self.Name == ThePickUp.InventoryType.Name )
        {
           // Dann können wir die Anzahl hinzufügen
           ThePickUp.AnnouncePickup( Pawn(Owner) );
           NewItem = Pawn(Owner).Spawn( class, Pawn(Owner),,, rot(0,0,0) );
           AddItem( Pawn(Owner), NewItem );
           return false;
        }
    }

    return Super.HandlePickupQuery( ThePickUp );
}

////////////////////////////////////////////////////////////////////////
// GiveTo
//
// Wird aufgerufen, wenn dieser Gegenstand in das Inventar eingefügt werden soll
////////////////////////////////////////////////////////////////////////
function GiveTo( Pawn Other, optional Pickup ThePickup )
{
    local Inventory Item;

    // Zählbar?
    if( inventoryIsCountable == true )
    {
        // Das ganze Inventory durchsuchen
        for( Item=Other.Inventory; Item!=None; Item=Item.Inventory )
        {
             // Wenn es dieses Item schon im Inventar gibt, dann brauch ich es nicht neu hinzufügen.
             // Anmerkung: AddItem() wurde schon von "HandlePickupQuery" ausgeführt!
             if( self.Name == Item.Name )
                 return;
        }
    }
    super.GiveTo( Other, ThePickUp );
}

////////////////////////////////////////////////////////////////////////
// defaultproperties
//
// Standardwerte
////////////////////////////////////////////////////////////////////////

defaultproperties
{
     inventoryCount=1
}
