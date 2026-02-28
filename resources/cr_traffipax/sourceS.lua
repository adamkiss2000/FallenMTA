local white = "#ffffff"

function RGBToHex(red, green, blue, alpha)
	if ((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255))) then
		return nil
	end

	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function checkWantedVehicle(veh)
    if isElement(client) and isElement(veh) then 
        local wantedVehicles, wantedVehiclesByPlateText = exports.cr_mdc:getWantedVehicles()
        local vehiclePlateText = veh.plateText
        local data = {}

        if wantedVehiclesByPlateText[vehiclePlateText] then 
            for k, v in pairs(wantedVehicles) do 
                if v.vehiclePlateText == vehiclePlateText then 
                    data = {reason = v.reason, vehicleType = v.vehicleType}
                    break
                end
            end

            local zoneName = getZoneName(veh.position)
            local syntax = exports.cr_core:getServerSyntax("MDC", "error")
            local hexColor = exports.cr_core:getServerColor("yellow", true)
            local r, g, b, r2, g2, b2 = getVehicleColor(veh, true)

            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Az egyik ellenörzőponton egy körözött jármű haladt át.")
            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Rendszám: " .. hexColor .. vehiclePlateText .. white .. ", típus: " .. hexColor .. data.vehicleType)
            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Színek: " .. RGBToHex(r, g, b) .. "szín1" .. white .. ", " .. RGBToHex(r2, g2, b2) .. "szín2")
            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Helyszín: " .. hexColor .. zoneName)
            exports.cr_dashboard:sendMessageToFaction(1, syntax .. "Körözés indoka: " .. hexColor .. data.reason)

            triggerClientEvent(getElementsByType("player"), "speedcams.onWantedBlipCreate", client, veh)
        end
    end
end
addEvent("speedcams.checkWantedVehicle", true)
addEventHandler("speedcams.checkWantedVehicle", root, checkWantedVehicle)