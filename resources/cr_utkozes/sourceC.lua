local utkozve = false

function handleVehicleDamage(attacker, weapon, loss, x, y, z, tire)
	if not getElementData(localPlayer, "player.seatBelt") then
		if not weapon then
			if not utkozve then
				if loss > 5 then
					if getVehicleSpeed() > sebesseg then
						a = math.random(1,2)
						if a == 1 then
							triggerServerEvent("utkozve", localPlayer, localPlayer)
							utkozve = true
							setTimer(function()
								utkozve = false
							end, 1000, 1)
							return
						end
					end
					if getVehicleSpeed() > 50 then
						if getVehicleSpeed() < sebesseg then
							if not utkozve then
								a = math.random(1,4)
								if a == 1 or a == 2 or a == 3 then
									fadeCamera(false, 0.2, 0, 0, 0)
									utkozve = true
									exports.cr_chat:createDoInPosition(localPlayer, "Nagy sebességgel nekiment a falnak, ezért eszméletét vesztette.")
									setTimer(function()
										fadeCamera(true)
										utkozve = false
									end, 3000, 1)
									return
								end
							end
						end
					end
				end
			end
		end
	end
end
addEventHandler("onClientVehicleDamage", root, handleVehicleDamage)

function getVehicleSpeed()
    if isPedInVehicle(getLocalPlayer()) then
	    local theVehicle = getPedOccupiedVehicle (getLocalPlayer())
        local vx, vy, vz = getElementVelocity (theVehicle)
        return math.sqrt(vx^2 + vy^2 + vz^2) * 165
    end
    return 0
end