function replaceModel()

txd = engineLoadTXD( "mdl.txd", 2332 )
engineImportTXD(txd, 2332 )

dff = engineLoadDFF( "mdl.dff", 2332 )
engineReplaceModel(dff, 2332, true )

col = engineLoadCOL ( "mdl.col" )
engineReplaceCOL ( col, 2332 )

end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), replaceModel)