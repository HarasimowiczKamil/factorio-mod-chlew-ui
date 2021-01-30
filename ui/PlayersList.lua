local playerListCache = {}

PlayersList = {
    classname = "ChlewPlayersList"
}

function PlayersList:new (player)
  local o
  if playerListCache[player.index] then
    o = playerListCache[player.index]
  else
    o = {
      player = player,
      frame = nil,
    }
    playerListCache[player.index] = o
  end

  setmetatable(o, self)
  self.__index = self
  return o
end

function PlayersList:getArmor(player)
  if defines.inventory then
    return nil
  end
  for _, count in pairs(player.get_inventory(defines.inventory.character_armor).get_contents()) do
    return _
  end

  return nil
end

function PlayersList:playerElement(listBox, player)
    local userSettings = settings.get_player_settings(self.player.index);
    local showDistance = userSettings["chlew-ui-show-distance"].value
    local showOnlineTime = userSettings["chlew-ui-show-online-time"].value
    local showAfkTime = userSettings["chlew-ui-show-afk-time"].value
    local showGroup = userSettings["chlew-ui-show-group"].value

    local armor = self:getArmor(player)
    local armorIcon = armor and '[item=' .. armor .. ']' or '[entity=character]'
    local avatar = player.ticks_to_respawn ~= nil and Ticks.smartFormat(player.ticks_to_respawn) or armorIcon

    local playerUI = listBox.add{type = "table", column_count = 2}
    playerUI.add{ type = "label", caption=avatar }

    local distance = Position.distance_squared(player.position, self.player.position)
    local color = player.chat_color.r .. ',' .. player.chat_color.g .. ',' .. player.chat_color.b
    local playerDesc = playerUI.add{type = "table", column_count = 1}
    local playerTopDesc = playerDesc.add{ type = "table", column_count = 2}

    playerTopDesc.add{ type = "label", caption= ' [color=' .. color .. '][font=default-bold]' .. player.name .. '[/font][/color]' }
    if distance > 0 and showDistance then
      playerTopDesc.add{ type = "label", caption='([font=technology-slot-level-font]' .. distance .. 'm[/font])' }
    end
    local playerBottomDesc = playerDesc.add{ type = "table", column_count = 2}
    if showGroup then
      playerBottomDesc.add{ type = "label", caption='[font=technology-slot-level-font]' .. player.permission_group.name .. '[/font]' }
    end
    
    if showOnlineTime then
      playerBottomDesc.add{ type = "label", caption='[font=default-small]' .. Ticks.smartFormat(player.online_time) .. '[/font]'}
    end

    if showAfkTime and (player.afk_time > 60 * 60) then
      local afk = ' (afk ' .. Ticks.smartFormat(player.afk_time) .. 'min)'
      playerBottomDesc.add{ type = "label", caption='[font=default-small]' .. afk .. '[/font]'}
    end
    -- splayerBottomDesc.add{ type = "label", caption='[font=technology-slot-level-font]' .. player.health .. ' life[/font]' }
end

function PlayersList:reset()
  if self.frame then
    self.frame.destroy()
  end

  if self.player.gui.left.chlew_ui then
    self.player.gui.left.chlew_ui.destroy()
  end
  self.frame = self.player.gui.left.add{type = "frame", name = "chlew_ui", column_count = 1}
end

function PlayersList:render()
    self:reset()

    local maxPlayers = settings.get_player_settings(self.player.index)["chlew-ui-max-players"].value;
    local listBox = self.frame.add{type = "table", column_count = 1}

    local count = 1
    local players = game.players
    table.sort(players, function (playerA, playerB)
      return Position.distance_squared(playerA.position, self.player.position) < Position.distance_squared(playerB.position, self.player.position)
    end)

    for _, player in pairs(players) do
      if count > 1 then
        listBox.add{ type = "line" }
      end
      if count > maxPlayers then
        break
      end

      self:playerElement(listBox, player)
      count = count + 1
    end
end