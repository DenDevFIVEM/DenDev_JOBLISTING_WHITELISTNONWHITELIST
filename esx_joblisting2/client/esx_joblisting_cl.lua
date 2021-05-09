local Keys = {
	["ESC"] = 322, ["BACKSPACE"] = 177, ["E"] = 38, ["ENTER"] = 18,	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173
}

local menuIsShowed				  = false
local hasAlreadyEnteredMarker     = false
local lastZone                    = nil
local isInJoblistingMarker 		  = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)


function ShowProfessionMenu()
	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "Surgery",
	{
	  title = "Centro Impiego",
	  align = "top-left",
	  elements = {
		{label = "Bando lavoro", value = "apply"},
		{label = "Scegli lavoro", value = "choose"}
	  }
	},
	function(data, menu)
	  menu.close()
  
	  if data.current.value == "choose" then
		ShowJobListingMenu()
	  elseif data.current.value == "apply" then
		openGui()
	  end
	end,
	function(data, menu)
	  menu.close()
	end)
  end


function ShowJobListingMenu(data)
	ESX.TriggerServerCallback('esx_joblisting:getJobsList', function(data)
		local elements = {}
		for i = 1, #data, 1 do
			table.insert(
				elements,
				{label = data[i].label, value = data[i].value}
			)
		end

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'joblisting',
			{
				title = "Centro Impiego",
				align = "top-left",
				elements = elements
			},
			function(data, menu)
				menu.close()
				TriggerEvent("SniperAK_jobcentrer:animazione")
				Citizen.Wait(7100)
				TriggerServerEvent('esx_joblisting:setJob', data.current.value)
				exports['mythic_notify']:DoHudText('success', _U('new_job'))
			end,
			function(data, menu)
				menu.close()
			end
		)

	end)
end

-- MENU
function openGui()
	SendNUIMessage({openMenu = true})
	Citizen.CreateThread(function()
	  Citizen.Wait(500)
	  SetNuiFocus(true, true)
	end)
end
  
function closeGui()
	SetNuiFocus(false)
	SendNUIMessage({openMenu = false})
end
  
RegisterNUICallback('closeMenu', function(data, cb)
	closeGui()
	cb('ok')
end)
  
RegisterNUICallback('postApplication', function(data, cb)
	
	TriggerServerEvent('esx_joblisting:postApplication', data)
	
	cb('ok')
end)
-- Menu


AddEventHandler('esx_joblisting:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords = GetEntityCoords(GetPlayerPed(-1))
		for i=1, #Config.Zones, 1 do
			if(GetDistanceBetweenCoords(coords, Config.Zones[i].x, Config.Zones[i].y, Config.Zones[i].z, true) < Config.DrawDistance) then
				DrawMarker(20, Config.Zones[i].x, Config.Zones[i].y, Config.Zones[i].z+ 0.7, 0.0, 0.0, 0.0, -180.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 117, 20, 255, false, true, 2, false, false, false, false)
			end
		end
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords      = GetEntityCoords(GetPlayerPed(-1))
		isInJoblistingMarker  = false
		local currentZone = nil
		for i=1, #Config.Zones, 1 do
			if GetDistanceBetweenCoords(coords, Config.Zones[i].x, Config.Zones[i].y, Config.Zones[i].z, true) < 2 then
				isInJoblistingMarker  = true
				SetTextComponentFormat('STRING')
            	AddTextComponentString(_U('access_job_center'))
            	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			end
		end
		if isInJoblistingMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
		end
		if not isInJoblistingMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_joblisting:hasExitedMarker')
		end
	end
end)

-- Create blips
Citizen.CreateThread(function()
	for i=1, #Config.Blips, 1 do
		local blip = AddBlipForCoord(Config.Blips[i].x, Config.Blips[i].y, Config.Blips[i].z)
		SetBlipSprite (blip, 407)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.6)
		SetBlipColour (blip, 1)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Centro Impiego")
		EndTextCommandSetBlipName(blip)
	end
end)

-- Menu Controls
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlJustReleased(0, Keys['E']) and GetLastInputMethod(2) and isInJoblistingMarker and not menuIsShowed then
			ShowProfessionMenu()
		end
	end
end)



RegisterNetEvent('SniperAK_jobcentrer:animazione')
AddEventHandler('SniperAK_jobcentrer:animazione', function(prop_name, prop_name2)
	if not IsAnimated then
		prop_name = prop_name or 'p_amb_clipboard_01'
		prop_name2 = prop_name2 or 'prop_pencil_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.10, 0.02, 0.08, -80.0, 0.0, 0.0, true, true, false, true, 1, true)

			local prop2 = CreateObject(GetHashKey(prop_name2), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 58866)
			AttachEntityToEntity(prop2, playerPed, boneIndex, 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true)

			ESX.Streaming.RequestAnimDict('missheistdockssetup1clipboard@base', function()
				TaskPlayAnim(playerPed, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8, -1, 49, 0, 0, 0, 0)
				exports['mythic_notify']:DoLongHudText('success', "Stai firmando il modulo...")
				Citizen.Wait(7000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
				DeleteObject(prop2)
			end)
		end)

	end
end)