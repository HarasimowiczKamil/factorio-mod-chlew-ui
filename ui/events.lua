Events = {
    classname = "ChlewEvents",
    playerList = nil,
}

function Events.on_configuration_changed(event)
  game.write_file('mod.log', 'configuration change\n', true)
end

function Events.debug()
    CustomEvents.debug()
  end

function Events.on_player_created(event)
    for _, player in pairs(game.players) do
      local playerList = PlayersList:new(player)
      playerList:render()
    end
end

function Events.on_tick(event)
    if event.tick % 60 == 0 then
        Debug:debug('[Events] OnTick', event)
        for _, player in pairs(game.players) do
          local playerList = PlayersList:new(player)
          playerList:render()
        end
    end
end

function Events:init()
  script.on_configuration_changed(self.on_configuration_changed)
  script.on_init(self.on_configuration_changed)
  script.on_load(self.on_load)
  
  script.on_event(defines.events.on_player_created, self.on_player_created)
  script.on_event(defines.events.on_tick, self.on_tick)
end