Channels = {}
Requests = {}
Accepted = {}

RegisterCallback("radio:joinChannel", function(src, dat)
    local channelId = tonumber(dat.channel)
    if not channelId then
        return {status = "error", message = "No channel provided"}
    end

    local forced = dat.forced == true
    local player = GetPlayer(src)
    local job = GetPlayerJob(player)
    local jobName = job and job.name

    if not forced and IsChannelLocked(channelId, jobName) then
        if not (Accepted[channelId] and Accepted[channelId][src]) then
            if Config.EnableRequesting then
                SendRequest(src, channelId)
                return {status = "error", message = "Request sent to access this channel"}
            end
            return {status = "error", message = "You are not allowed to join this channel"}
        end
    end

    local freq = tostring(channelId)
    Channels[freq] = Channels[freq] or { id = freq, frequency = freq, players = {} }
    Channels[freq].players[tostring(src)] = {
        name = GetPlayerNameBySource(src),
        networkId = NetworkGetNetworkIdFromEntity(GetPlayerPed(src)),
        src = src
    }

    if Config.EnableShowUsers then
        for _, p in pairs(Channels[freq].players) do
            TriggerClientEvent("radio:refreshMembers", p.src, Channels[freq].players)
        end
    end

    return {status = "success", message = "You have joined the channel"}
end)

RegisterCallback("radio:leaveChannel", function(src)
    local channel = FindPlayerRadio(src)
    if not channel then
        return {status = "error", message = "You are not in a channel"}
    end

    local ch = Channels[channel]
    if not ch then
        return {status = "error", message = "Channel not found"}
    end

    ch.players[tostring(src)] = nil

    if Config.EnableShowUsers then
        for _, p in pairs(ch.players) do
            TriggerClientEvent("radio:refreshMembers", p.src, ch.players)
        end
    end

    if table.size(ch.players) == 0 then
        Channels[channel] = nil
    end

    return {status = "success", message = "You have left the channel"}
end)

function FindPlayerRadio(src)
    for k, v in pairs(Channels) do
        if v.players[tostring(src)] then
            return k
        end
    end
    return nil
end

RegisterCallback("radio:getRequests", function(src)
    local player = GetPlayer(src)
    local job = GetPlayerJob(player)
    local jobName = job and job.name
    local grade = 0

    if Utils.Framework == "qb-core" then
        grade = player.PlayerData.job and (player.PlayerData.job.grade and player.PlayerData.job.grade.level or player.PlayerData.job.grade_level) or 0
    elseif Utils.Framework == "es_extended" and job then
        grade = job.grade or 0
    end

    local result = nil
    for chan, reqs in pairs(Requests) do
        for _, entry in ipairs(Config.LockedChannels) do
            print("Checking channel: " .. chan .. " with frequency: " .. entry.frequency)
            print("Job: " .. jobName .. ", Grade: " .. grade .. ", Accepter Grade: " .. entry.accepterGrade)

            if entry.frequency == tonumber(chan) and entry.job == jobName and grade >= entry.accepterGrade then
                Accepted[chan] = Accepted[chan] or {}
                Accepted[chan][src] = true
                result = reqs
                break
            end
        end
        if result then break end
    end

    return result
end)

RegisterCallback("radio:getRandomChannels", function(src)
    local randomChannels = {}
    for freq, ch in pairs(Channels) do
        if math.random(1, 2) == 1 then
            local newCh = { id = ch.id, frequency = ch.frequency, players = {} }
            for k, p in pairs(ch.players) do
                newCh.players[k] = { name = p.name, networkId = p.networkId, src = p.src }
            end
            randomChannels[freq] = newCh
        end
    end
    return randomChannels
end)

-- Economy and inventory callbacks (unchanged)
RegisterCallback("hasItem", function(src, item)
    return HasItem(src, item, 1)
end)

RegisterCallback("hasMoney", function(src, money)
    if HasMoney(src, money) then
        RemoveMoney(src, money)
        return true
    end
    return false
end)

-- Accept/Decline channel requests
RegisterCallback("radio:acceptRequest", function(src, data)
    if not data or not data.channel or not data.identifier then
        return {status = "error", message = "Invalid data"}
    end

    local channelId = tonumber(data.channel)
    local reqs = Requests[channelId]
    if not reqs then
        return {status = "error", message = "No requests for this channel"}
    end

    for i, req in ipairs(reqs) do
        if req.identifier == data.identifier then
            table.remove(reqs, i)
            Accepted[channelId] = Accepted[channelId] or {}
            Accepted[channelId][src] = true
            return {status = "success", message = "Accepted request from " .. req.name}
        end
    end

    return {status = "error", message = "Request not found"}
end)

RegisterCallback("radio:declineRequest", function(src, data)
    if not data or not data.channel or not data.identifier then
        return {status = "error", message = "Invalid data"}
    end

    local channelId = tonumber(data.channel)
    local reqs = Requests[channelId]
    if not reqs then
        return {status = "error", message = "No requests to decline"}
    end

    for i, req in ipairs(reqs) do
        if req.identifier == data.identifier then
            table.remove(reqs, i)
            return {status = "success", message = "Declined request from " .. req.name}
        end
    end

    return {status = "error", message = "Request not found"}
end)

AddEventHandler("playerDropped", function()
    local src = source
    local channel = FindPlayerRadio(src)
    if not channel then return end

    local ch = Channels[channel]
    if not ch then return end

    ch.players[tostring(src)] = nil
    if Config.EnableShowUsers then
        for _, p in pairs(ch.players) do
            TriggerClientEvent("radio:refreshMembers", p.src, ch.players)
        end
    end
end)

-- Improved channel lock check
function IsChannelLocked(channelId, playerJob)
    for _, entry in ipairs(Config.LockedChannels) do
        if entry.frequency == tonumber(channelId) then
            for _, allowedJob in ipairs(entry.jobs or {}) do
                if allowedJob == playerJob then
                    return false
                end
            end
            return true
        end
    end
    return false
end

-- Framework-agnostic player-job resolution
function GetPlayerJob(player)
    if not player then return nil end
    if Utils.Framework == "qb-core" then
        return player.PlayerData.job
    elseif Utils.Framework == "es_extended" then
        return player:getJob()
    end
    return nil
end

-- Add a request if not already sent
function SendRequest(src, channelId)
    local name = GetPlayerNameBySource(src)
    local identifier = GetPlayerIdentifier(src)
    for _, entry in ipairs(Config.LockedChannels) do
        if entry.frequency == tonumber(channelId) then
            Requests[channelId] = Requests[channelId] or {}
            for _, req in ipairs(Requests[channelId]) do
                if req.identifier == identifier then return end
            end
            table.insert(Requests[channelId], { name = name, identifier = identifier })
        end
    end
end

function table.size(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
