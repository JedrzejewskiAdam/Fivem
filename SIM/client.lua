ESX = nil
local PlayerData = {}

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

CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) 
			ESX = obj 
		end)
		Citizen.Wait(250)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

local GUI                     = {}
GUI.Time                      = 0
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local currentSkin 			  = nil

simData = function()
	ESX.UI.Menu.CloseAll()
	ESX.TriggerServerCallback('adam_sim:getSims', function(sims)
		local elements = {
		}
		
		if sims ~= nil then
			for k, v in pairs(sims) do
				table.insert(elements, {label = sims[k].phone_number, value = sims[k].phone_number})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'zsim_menu',{
			title    = Config.Manage.Name,
			align    = 'left',
			elements = elements
		}, function(data, menu)	
			if data.current.value then
				local elements2 = {
					{label = Config.Manage.GetSim, value = 'simz'},
				}
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'zsim2_menu',{
					title    = Config.Manage.Name,
					align    = 'left',
					elements = elements2
				}, function(data2, menu2)	
					TriggerServerEvent('adam_sim:check', data.current.value)
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
		 	menu.close()
		end)
	end)
end

OpenSimMenu = function()
	local elements = {
		{label = Config.Items.Sim .. ' - $' .. Config.Item.Cost.Sim , value = 'sim'},
		{label = 'Odzyskaj karty' , value = 'kup'},
		{label = Config.Items.Phone .. ' - $' .. Config.Item.Cost.Phone, value = 'phone'},
	}
		
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_menu',{
		title    = Config.Name,
		align    = 'left',
		elements = elements
	}, function(data, menu)	
		if data.current.value == 'sim' then
			TriggerServerEvent('adam_sim:buy', 'sim')
		end

		if data.current.value == 'kup' then
			ESX.TriggerServerCallback('adam_sim:getSims', function(sims)
				for k, v in pairs(sims) do
					TriggerServerEvent('ad-csim:addSim', sims[k].phone_number)
				end
			end)
		end

		if data.current.value == 'phone' then
			TriggerServerEvent('adam_sim:buy', 'phone')
		end

		if data.current.value == 'msim' then
			simData()
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)	
end

sim = function(data, slot)
    TriggerServerEvent('updatePhone:adam', data.slot)
end

exports.qtarget:AddBoxZone("kartysim", vector3(-1082.4288, -247.1204, 39.0072), 0.8, 0.8, {
	name="kartysim",
	debugPoly=false,
	}, {
		options = {
        {

			action = function ()
				OpenSimMenu()
			end,
            icon = "fas fa-university",
            label = "Kup karte sim",
        },
    },
    distance = 2.5
})
