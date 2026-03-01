addEventHandler("onPlayerJoin", root,
    function()
        setElementData(source, "loggedIn", false)
    end
)

addEventHandler("onResourceStart", resourceRoot,
    function()
        outputServerLog("[cr_core] Core loaded successfully.")
    end
)