function replaceModel()

txd = engineLoadTXD( "mdl.txd", 1359 )
engineImportTXD(txd, 1359 )

dff = engineLoadDFF( "mdl.dff", 1359 )
engineReplaceModel(dff, 1359, true )

col = engineLoadCOL ( "mdl.col" )
engineReplaceCOL ( col, 1359 )

end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), replaceModel)