addEventHandler("onResourceStart", resourceRoot,
    function()
        local jobPed = Ped(21, 2415.7917480469, 2548.0444335938, 21.875, 180)
        jobPed:setData("ped.name", "Tobias Ingram")
        jobPed:setData("ped.type", "Munkáltató")
        jobPed:setData("job >> ped", true)
        jobPed:setData("char >> noDamage", true)
        jobPed:setFrozen(true)
    end
)