local BS2_AIRCRAFT_SMOKE_PTFX = nil
local BS2_SIMPLE_INTERIOR_HANGAR_AIRCRAFT_SMOKE_DEPLOYED = false

CreateThread( function ()
	RequestNamedPtfxAsset( "scr_ar_planes" )
	while not HasNamedPtfxAssetLoaded( "scr_ar_planes" ) do
		Wait( 1 )
	end

	while true do
		local playerPed = PlayerPedId()

		local vehicleEntity = GetVehiclePedIsIn( playerPed, false )
		local vehicleModel = GetEntityModel( vehicleEntity )

		if IsControlJustReleased( 0, 22 ) then
			local isFound = table.hasvalue( Shared.Whitelist, vehicleModel )
			if not isFound then return end

			local isSmokeActive = IS_LOCAL_PLAYER_AIRCRAFT_SMOKE_ACTIVE()
			if isSmokeActive then
				CLEANUP_PLANE_FX_SMOKE( BS2_AIRCRAFT_SMOKE_PTFX )
			else
				FIRE_SMOKE_FX( vehicleEntity )
			end
		end

		Wait( 0 )
	end
end )

function IS_LOCAL_PLAYER_AIRCRAFT_SMOKE_ACTIVE()
	return BS2_SIMPLE_INTERIOR_HANGAR_AIRCRAFT_SMOKE_DEPLOYED
end

function SET_PLAYER_AIRCRAFT_SMOKE_ACTIVE( bActive )
	BS2_SIMPLE_INTERIOR_HANGAR_AIRCRAFT_SMOKE_DEPLOYED = bActive
end

function FIRE_SMOKE_FX( vehicleEntity )
	local smokePlaneActive = IS_LOCAL_PLAYER_AIRCRAFT_SMOKE_ACTIVE()
	if smokePlaneActive then
		return
	end

	local vehicleModel = GetEntityModel( vehicleEntity )

	local isSmokePtfx = DoesParticleFxLoopedExist( BS2_AIRCRAFT_SMOKE_PTFX )
	if isSmokePtfx then
		StopParticleFxLooped( BS2_AIRCRAFT_SMOKE_PTFX, false )
		RemoveParticleFx( BS2_AIRCRAFT_SMOKE_PTFX, false )
	end

	local smokeColorRed, smokeColorGreen, smokeColorBlue = GetVehicleTyreSmokeColor( vehicleEntity )

	local smokeOffsets = Shared.Offsets[vehicleModel]
	local smokeScale = Shared.Scale[vehicleModel] or 1.0

	UseParticleFxAssetNextCall( "scr_ar_planes" )

	BS2_AIRCRAFT_SMOKE_PTFX = StartNetworkedParticleFxLoopedOnEntityBone( "scr_ar_trail_smoke", vehicleEntity, smokeOffsets.x, smokeOffsets.y, smokeOffsets.z, 0.0, 0.0, 0.0, -1, smokeScale, false, false, false )

	SetParticleFxLoopedColour( BS2_AIRCRAFT_SMOKE_PTFX, smokeColorRed / 255, smokeColorGreen / 255, smokeColorBlue / 255, false )
	SetParticleFxLoopedScale( BS2_AIRCRAFT_SMOKE_PTFX, smokeScale )

	SET_PLAYER_AIRCRAFT_SMOKE_ACTIVE( true )
end

function CLEANUP_PLANE_FX_SMOKE( smokeptfx )
	SET_PLAYER_AIRCRAFT_SMOKE_ACTIVE( false )

	StopParticleFxLooped( BS2_AIRCRAFT_SMOKE_PTFX, false )
	RemoveParticleFx( BS2_AIRCRAFT_SMOKE_PTFX, false )
end