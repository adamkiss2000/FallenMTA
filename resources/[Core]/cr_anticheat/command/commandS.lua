local defendedCommand = {
    ["start"] = false,
    ["stop"] = false,
    ["refresh"] = false,
    ["refreshall"] = true,
    ["restart"] = false,
    ["login"] = true,
    ["register"] = true,
    ["stopall"] = true,
    ["aclrequest"] = true,
    ["axec"] = true,
    ["addaccount"] = true,
    ["chgpass"] = true,
    ["delaccount"] = true,
    ["shutdown"] = true,
    ["debugscript"] = false,
    ["logout"] = true,
    ["msg"] = true,
    ["nick"] = true,
    ["cleardebug"] = true,
    ["addaccount"] = true,
    ["delaccount"] = true,
    ["crun"] = true,
    ["srun"] = true,
    ["reloadacl"] = false,
    ["reloadbans"] = true,
    ["authserial"] = true,
    ["sfakelag"] = true,
    ["openports"] = true,
    ["sver"] = true,
    ["loadmodule"] = true,
    ["reloadmodule"] = true,
    ["upgrade"] = false,
    ["unloadmodule"] = true,
    ["nick"] = true,
    ["aexec"] = true,
    ["msg"] = true,
    ["whois"] = true,
    ["ver"] = true,
    ["chgmypass"] = true,
    ["sinfo"] = true,
}

addEventHandler("onPlayerCommand", root,
    function(cmd)
        if defendedCommand[cmd] then
            if not exports['cr_core']:getPlayerDeveloper(source) then
                local playerNick = getPlayerName(source)
                local playerUsername = exports['cr_admin']:getAdminName(source, false)
                local playerIP = getPlayerIP(source)
                local playerSerial = getElementData(source, "mtaserial") or getPlayerSerial(source)
                local time = exports['cr_core']:getTime() .. " "
                exports['cr_logs']:addLog(source, "CommandDefend", cmd, (tonumber(getElementData(source, "acc >> id")) or inspect(source)).." attempted command: "..cmd.." (IP: "..playerIP..", Username: "..playerUsername..", Serial: "..playerSerial)
                outputChatBox(syntax .. "Ez a parancs nem használható!", source, 255, 255, 255, true)
                cancelEvent()
            else
                local playerNick = getPlayerName(source)
                local playerUsername = exports['cr_admin']:getAdminName(source, false)
                local playerIP = getPlayerIP(source)
                local playerSerial = getElementData(source, "mtaserial") or getPlayerSerial(source)
                local time = exports['cr_core']:getTime() .. " "
                exports['cr_logs']:addLog(source, "CommandDefend", cmd .. ">>success", (tonumber(getElementData(source, "acc >> id")) or inspect(source)).." attempted command: "..cmd.." (IP: "..playerIP..", Username: "..playerUsername..", Serial: "..playerSerial)
            end
        end
    end
)
