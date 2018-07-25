local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX             				 = nil

local cardOpen 					= false
local playerData 				= {}
local windowavg					= false
local windowavd					= false
local windowarg					= false
local windoward					= false
local window 					= false
local engineOn 					= true
local speedkm 					= 0


-- Servern callback
RegisterNetEvent('jsfour-legitimation:open')
AddEventHandler('jsfour-legitimation:open', function(playerData)
	cardOpen = true
	SendNUIMessage({
		action = "open",
		array = playerData
	})
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

function OpenCivilianActionsMenu()

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
  'default', GetCurrentResourceName(), 'civilian_actions',
  {
    title    = 'Individåtgärder',
    align    = 'top-left',
    elements = {
      {label = 'Fordons Meny', value = 'vehiclemenu'},
      {label = 'ID-Kort', value = 'id_kort'},
      {label = 'Kissa', value = 'pee'},
      {label = 'Bajsa', value = 'poop'},
      {label = 'Av/På ögonbindel', value = 'blindfold'},
    }
  },
    
    function(data, menu)

      if data.current.value == 'id_kort' then
        ESX.UI.Menu.CloseAll()

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'id_card',
          {
            title    = 'Legitimation',
            align    = 'top-left',
            elements = {
              {label = 'Kolla på ditt ID-Kort', value = 'check'},
              {label = 'Visa ditt ID-Kort', value = 'show'}
            }
          },
          function(data, menu)

            if data.current.value == 'check' then
              TriggerServerEvent('jsfour-legitimation:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
              TriggerEvent("pNotify:SendNotification", {text = "Du kollar på ditt eget ID-Kort", type = "info", queue = "personmeny", timeout = 3500, layout = "bottomLeft"})
  				local pP = GetPlayerPed(-1)
            elseif data.current.value == 'show' then
              local player, distance = ESX.Game.GetClosestPlayer()

              if distance ~= -1 and distance <= 3.0 then
                TriggerServerEvent('jsfour-legitimation:open', GetPlayerPed(PlayerId()), GetPlayerServerId(player))
                TriggerEvent("pNotify:SendNotification", {text = "Du visar ditt ID kort till närmsta person", type = "error", queue = "personmeny", timeout = 3500, layout = "bottomLeft"}) -- Testa player, distance
              else
                TriggerEvent("pNotify:SendNotification", {text = "Där är ingen som kan ta emot mitt ID-Kort... 🤦", type = "error", queue = "personmeny", timeout = 5000, layout = "bottomLeft"})
              end
            end
          end,
        function(data, menu)
          menu.close()
          OpenCivilianActionsMenu()
        end
        )
      end

      if data.current.value == 'blindfold' then
        local player, distance = ESX.Game.GetClosestPlayer()

      if distance ~= -1 and distance <= 3.0 then
           ESX.TriggerServerCallback('jsfour-blindfold:itemCheck', function( hasItem )
              TriggerServerEvent('jsfour-blindfold', GetPlayerServerId(player), hasItem)
           end)
      else
           ESX.ShowAdvancedNotification('Individåtgärder', '~b~Ögonbindel', 'Inga människor i närheten', 'CHAR_DEFAULT', 8)
          end
      end

      if data.current.value == 'vehiclemenu' then
        local playerPed = GetPlayerPed(-1)
        if IsPedSittingInAnyVehicle(playerPed) then
            local playerVeh = GetVehiclePedIsIn(playerPed, false)
            local drivingPed = GetPedInVehicleSeat(playerVeh, -1)
            if drivingPed == playerPed then
                OpenVehicleMenu()
            end
        end
      end

      if data.current.value == 'pee' then
          TriggerEvent('pee')
      elseif data.current.value == 'poop' then
          TriggerEvent('poop')
       end

      if data.current.value == 'check' then
            TriggerServerEvent('jsfour-legitimation:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
      elseif data.current.value == 'show' then
           local player, distance = ESX.Game.GetClosestPlayer()

      if distance ~= -1 and distance <= 3.0 then
        TriggerServerEvent('jsfour-legitimation:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
      else
        ESX.ShowAdvancedNotification('Individåtgärder', '', 'Inga människor i närheten', 'CHAR_DEFAULT', 8)
        --ESX.ShowNotification('Ingen i närheten')
      end
    end
    end,
    function(data, menu)
      menu.close()
    end
  )
end

function OpenVehicleMenu()

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'vehicle_actions',
    {
      title    = 'Fordons Meny',
      align    = 'top-left',
      elements = {
        {label = 'Motor',           value = 'engine'},
        {label = 'Dörrar',        value = 'door'},
        {label = 'Fönster',         value = 'window'},
        {label = 'Farthållare',   value = 'cruise_control'},
        {label = 'Byt säte',      value = 'changeseat'},
      }
    },
    function(data, menu)
      if data.current.value == 'engine' then
        local playerPed = GetPlayerPed(-1)
          local playerVeh = GetVehiclePedIsIn(playerPed, false)
        if engineOn == true then
                SetVehicleUndriveable(playerVeh, true)
            SetVehicleEngineOn(playerVeh, false, false, false)
            engineOn = false
            TriggerEvent("pNotify:SendNotification", {text = "Du stängde av motorn", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
        else
          SetVehicleUndriveable(playerVeh, false)
            SetVehicleEngineOn(playerVeh, true, false, false)       
                engineOn = true
            TriggerEvent("pNotify:SendNotification", {text = "Du satte på motorn", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
        end
      end

      if data.current.value == 'changeseat' then
        TriggerEvent("SeatShuffle")
      end

      if data.current.value == 'door' then
        ESX.UI.Menu.CloseAll()

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'door_actions',
          {
            title    = 'Dörrar',
            align    = 'top-left',
            elements = {
              {label = 'Motorhuv',        value = 'hood'},
              {label = 'Backlucka',           value = 'trunk'},
              {label = 'Vänster främre dörr',   value = 'dooravg'},
              {label = 'Främre höger dörr',     value = 'dooravd'},
              {label = 'Backre vänster',      value = 'doorarg'},
              {label = 'Backre höger',      value = 'doorard'}
            }
          },
          function(data, menu)
            if data.current.value == 'hood' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if (IsPedSittingInAnyVehicle(playerPed)) then
                  if GetVehicleDoorAngleRatio(playerVeh, 4) > 0.0 then 
                      SetVehicleDoorShut(playerVeh, 4, false)
                      TriggerEvent("pNotify:SendNotification", {text = "Du stängde motorhuv!", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                   else
                      SetVehicleDoorOpen(playerVeh, 4, false)
                      frontleft = true
                      TriggerEvent("pNotify:SendNotification", {text = "Du öppnade motorhuv!", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                    end
                end
            end
            if data.current.value == 'trunk' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if ( IsPedSittingInAnyVehicle( playerPed ) ) then
                   if GetVehicleDoorAngleRatio(playerVeh, 5) > 0.0 then 
                      SetVehicleDoorShut(playerVeh, 5, false)
                      TriggerEvent("pNotify:SendNotification", {text = "Du stängde backluckan!", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                    else
                      SetVehicleDoorOpen(playerVeh, 5, false)
                      frontleft = true
                      TriggerEvent("pNotify:SendNotification", {text = "Du öppnade backluckan!", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})    
                   end
                end
            end
            if data.current.value == 'dooravg' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if ( IsPedSittingInAnyVehicle( playerPed ) ) then
                   if GetVehicleDoorAngleRatio(playerVeh, 0) > 0.0 then 
                      SetVehicleDoorShut(playerVeh, 0, false)
                      TriggerEvent("pNotify:SendNotification", {text = "Du stängde dörren!", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                    else
                      SetVehicleDoorOpen(playerVeh, 0, false)
                      frontleft = true
                      TriggerEvent("pNotify:SendNotification", {text = "Du öppnade dörren!", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                   end
                end
            end
            if data.current.value == 'dooravd' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if ( IsPedSittingInAnyVehicle( playerPed ) ) then
                   if GetVehicleDoorAngleRatio(playerVeh, 1) > 0.0 then 
                      SetVehicleDoorShut(playerVeh, 1, false)
                      TriggerEvent("pNotify:SendNotification", {text = "Du stängde dörren!", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                    else
                      SetVehicleDoorOpen(playerVeh, 1, false)
                      frontleft = true
                      TriggerEvent("pNotify:SendNotification", {text = "Du öppnade dörren!", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})  
                   end
                end
            end
            if data.current.value == 'doorarg' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if ( IsPedSittingInAnyVehicle( playerPed ) ) then
                   if GetVehicleDoorAngleRatio(playerVeh, 2) > 0.0 then 
                      SetVehicleDoorShut(playerVeh, 2, false)
                      TriggerEvent("pNotify:SendNotification", {text = "Du stängde dörren!", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                    else
                      SetVehicleDoorOpen(playerVeh, 2, false)
                      frontleft = true
                      TriggerEvent("pNotify:SendNotification", {text = "Du öppnade dörren!", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})     
                   end
                end
            end
            if data.current.value == 'doorard' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if ( IsPedSittingInAnyVehicle( playerPed ) ) then
                   if GetVehicleDoorAngleRatio(playerVeh, 3) > 0.0 then 
                      SetVehicleDoorShut(playerVeh, 3, false)
                      TriggerEvent("pNotify:SendNotification", {text = "Du stängde dörren!", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                    else
                      SetVehicleDoorOpen(playerVeh, 3, false)
                      frontleft = true
                      TriggerEvent("pNotify:SendNotification", {text = "Du öppnade dörren!", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                   end
                end
            end
          end,
        function(data, menu)
          menu.close()
          OpenVehicleMenu()
        end
        )
      end
      if data.current.value == 'window' then
        ESX.UI.Menu.CloseAll()

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'window_actions',
          {
            title    = 'Fönster meny',
            align    = 'top-left',
            elements = {
              {label = 'Vänster främre fönster',  value = 'windowavga'},
              {label = 'Höger främre fönster',  value = 'windowavdr'},
              {label = 'Vänster backre dörr',   value = 'windowarga'},
              {label = 'Höger backre dörr',   value = 'windowardr'}
            }
          },
          function(data, menu)
            if data.current.value == 'windowavga' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if windowavg == false then
                      RollDownWindow(playerVeh, 0)
                      windowavg = true
                      TriggerEvent("pNotify:SendNotification", {text = "Du vevade ner fönstret", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                else
                  RollUpWindow(playerVeh, 0)
                      windowavg = false
                  TriggerEvent("pNotify:SendNotification", {text = "Du vevade upp fönstret", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                end
            end
            if data.current.value == 'windowavdr' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if windowavd == false then
                      RollDownWindow(playerVeh, 1)
                      windowavd = true
                  TriggerEvent("pNotify:SendNotification", {text = "Du vevade ner fönstret", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                else
                  RollUpWindow(playerVeh, 1)
                      windowavd = false
                  TriggerEvent("pNotify:SendNotification", {text = "Du vevade upp fönstret", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                end
            end
            if data.current.value == 'windowarga' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if windowarg == false then
                      RollDownWindow(playerVeh, 2)
                      windowarg = true
                  TriggerEvent("pNotify:SendNotification", {text = "Du vevade ner fönstret", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                else
                  RollUpWindow(playerVeh, 2)
                      windowarg = false
                  TriggerEvent("pNotify:SendNotification", {text = "Du vevade upp fönstret", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                end
            end
            if data.current.value == 'windowardr' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                if windoward == false then
                      RollDownWindow(playerVeh, 3)
                      windoward = true
                  TriggerEvent("pNotify:SendNotification", {text = "Du vevade ner fönstret", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                else
                  RollUpWindow(playerVeh, 3)
                      windoward = false
                  TriggerEvent("pNotify:SendNotification", {text = "Du vevade upp fönstret", type = "success", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
                end
            end
          end,
        function(data, menu)
          menu.close()
          OpenVehicleMenu()
        end
        )
      end
      if data.current.value == 'cruise_control' then
        ESX.UI.Menu.CloseAll()

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'cruise_control_actions',
          {
            title    = 'Farthållare',
            align    = 'top-left',
            elements = {
              {label = 'Avaktiverat',   value = 'none'},
              {label = '30Km/h',    value = '30'},
              {label = '55Km/h',    value = '55'},
              {label = '110Km/h',   value = '110'},
            }
          },
          function(data, menu)
            if data.current.value == 'none' then
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                local modelVeh  = GetEntityModel(playerVeh, false)
		local maxSpeed = GetVehicleHandlingFloat(playerVeh,"CHandlingData","fInitialDriveMaxFlatVel")
                SetEntityMaxSpeed(playerVeh, maxSpeed)
                TriggerEvent("pNotify:SendNotification", {text = "Du stängde av farthållaren", type = "error", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
            end
            if data.current.value == '30' then
              local speedkm   = 30
              local speed   = speedkm/3.6
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                SetEntityMaxSpeed(playerVeh, speed)
                TriggerEvent("pNotify:SendNotification", {text = "Du satte farthållaren på 30Km/h", type = "info", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
            end
            if data.current.value == '55' then
              local speedkm   = 55
              local speed   = speedkm/3.6
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                SetEntityMaxSpeed(playerVeh, speed)
                TriggerEvent("pNotify:SendNotification", {text = "Du satte farthållaren på 50Km/h", type = "info", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
            end
            if data.current.value == '110' then
              local speedkm   = 110
              local speed   = speedkm/3.6
              local playerPed = GetPlayerPed(-1)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)
                SetEntityMaxSpeed(playerVeh, speed)
                TriggerEvent("pNotify:SendNotification", {text = "Du satte farthållaren på 100Km/h", type = "info", queue = "vehiclemenu", timeout = 1000, layout = "bottomLeft"})
            end
          end,
        function(data, menu)
          menu.close()
          OpenVehicleMenu()
        end
        )
      end
    end,
  function(data, menu)
    menu.close()
    OpenCivilianActionsMenu()
  end
  )
end

-- Close the ID card
-- Key events
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlPressed(0, 322) or IsControlPressed(0, 177) and cardOpen then
			SendNUIMessage({
				action = "close"
			})
			cardOpen = false
		end
	end
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsControlPressed(0, Keys["F5"]) then
      OpenCivilianActionsMenu()
    end
  end
end)

-- Bälte


local speedBuffer  = {}
local velBuffer    = {}
local beltOn       = false
local wasInCar     = false

IsCar = function(veh)
        local vc = GetVehicleClass(veh)
        return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
        end 

Fwv = function (entity)
        local hr = GetEntityHeading(entity) + 90.0
        if hr < 0.0 then hr = 360.0 + hr end
        hr = hr * 0.0174533
        return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
      end

Citizen.CreateThread(function()
  Citizen.Wait(500)
  while true do
    
    local ped = GetPlayerPed(-1)
    local car = GetVehiclePedIsIn(ped)
    
    if car ~= 0 and (wasInCar or IsCar(car)) then
    
      wasInCar = true
      
      if beltOn then DisableControlAction(0, 75) end

--      if beltOn and IsControlJustReleased(29)
--        TriggerEvent("pNotify:SendNotification", {text = "Du har bälte på dig!", type = "error", queue = "belt", timeout = 1000, layout = "bottomLeft"})
--      end
      
      speedBuffer[2] = speedBuffer[1]
      speedBuffer[1] = GetEntitySpeed(car)
      
      if speedBuffer[2] ~= nil 
         and not beltOn
         and GetEntitySpeedVector(car, true).y > 1.0  
         and speedBuffer[1] > 19.25 
         and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
         
        local co = GetEntityCoords(ped)
        local fw = Fwv(ped)
        SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
        SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
        Citizen.Wait(1)
        SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
      end
        
      velBuffer[2] = velBuffer[1]
      velBuffer[1] = GetEntityVelocity(car)
        
      if IsControlJustReleased(0, 29) then
        beltOn = not beltOn         
        if beltOn then  TriggerEvent("pNotify:SendNotification", {text = "Du tog på dig ditt säkerhetsbälte!", type = "success", queue = "belt", timeout = 1000, layout = "bottomLeft"})
        else TriggerEvent("pNotify:SendNotification", {text = "Du tog av dig ditt säkerhetsbälte!", type = "error", queue = "belt", timeout = 1000, layout = "bottomLeft"}) end
      end
      
    elseif wasInCar then
      wasInCar = false
      beltOn = false
      speedBuffer[1], speedBuffer[2] = 0.0, 0.0
    end
    Citizen.Wait(0)
  end
end)

local disableShuffle = true
function disableSeatShuffle(flag)
  disableShuffle = flag
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsPedInAnyVehicle(GetPlayerPed(-1), false) and disableShuffle then
      if GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) == GetPlayerPed(-1) then
        if GetIsTaskActive(GetPlayerPed(-1), 165) then
          SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
        end
      end
    end
  end
end)

RegisterNetEvent("SeatShuffle")
AddEventHandler("SeatShuffle", function()
  if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
    disableSeatShuffle(false)
    Citizen.Wait(5000)
    disableSeatShuffle(true)
  else
    CancelEvent()
  end
end)

RegisterCommand("shuff", function(source, args, raw) --change command here
    TriggerEvent("SeatShuffle")
end, false)
