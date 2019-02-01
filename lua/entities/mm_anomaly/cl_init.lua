include( "shared.lua" )

function ENT:Initialize()
	local effect = {
		function( self, mult )
			if ( !self.Vars ) then
				self.Vars = {}
			end
			if ( !self.Vars.Bloom ) then
				self.Vars.Bloom = true
				self.Vars.Darken = math.random( 0, 0.4 )
				self.Vars.Multiply = math.random( 1, 5 )
				self.Vars.SizeX = math.random( 0, 50 )
				self.Vars.SizeY = math.random( 0, 50 )
				self.Vars.Passes = math.random( 0, 30 )
				self.Vars.ColourMult = math.random( 3, 20 )
				self.Vars.RedMult = math.random( 0.5, 1 )
				self.Vars.GreenMult = math.random( 0.5, 1 )
				self.Vars.BlueMult = math.random( 0.5, 1 )
			end
			DrawBloom(
				mult * self.Vars.Darken,
				mult * self.Vars.Multiply,
				mult * self.Vars.SizeX,
				mult * self.Vars.SizeY,
				mult * self.Vars.Passes,
				mult * self.Vars.ColourMult,
				mult * self.Vars.RedMult,
				mult * self.Vars.GreenMult,
				mult * self.Vars.BlueMult
			)
		end,
		function( self, mult )
			if ( !self.Vars ) then
				self.Vars = {}
			end
			if ( !self.Vars.Sharpen ) then
				self.Vars.Sharpen = true
				self.Vars.Contrast = math.random( 1, 20 )
				self.Vars.Distance = math.random( -5, 5 )
			end
			DrawSharpen(
				mult * self.Vars.Contrast,
				mult * self.Vars.Distance
			)
		end,
		function( self, mult )
			if ( !self.Vars ) then
				self.Vars = {}
			end
			if ( !self.Vars.Sobel ) then
				self.Vars.Sobel = true
				self.Vars.Threshold = math.random( 0.01, 0.5 ) * 100
			end
			DrawSobel(
				math.max( 0.01, mult * self.Vars.Threshold )
			)
		end,
		function( self, mult )
			if ( !self.Vars ) then
				self.Vars = {}
			end
			if ( !self.Vars.ToyTown ) then
				self.Vars.ToyTown = true
				self.Vars.Passes = math.random( 1, 100 )
				self.Vars.Height = math.random( 0, 1 )
			end
			DrawToyTown(
				mult * self.Vars.Passes,
				mult * self.Vars.Height
			)
		end,
		function( self, mult )
			if ( !self.Vars ) then
				self.Vars = {}
			end
			if ( !self.Vars.ColorModify ) then
				self.Vars.ColorModify = {
					[ "$pp_colour_addr" ] = math.random( 0, 1 ),
					[ "$pp_colour_addg" ] =  math.random( 0, 1 ),
					[ "$pp_colour_addb" ] =  math.random( 0, 1 ),
					[ "$pp_colour_brightness" ] = math.random( 0, 1 ),
					[ "$pp_colour_contrast" ] = math.random( 0, 1 ),
					[ "$pp_colour_colour" ] = math.random( 0, 5 ),
					[ "$pp_colour_mulr" ] = math.random( 0, 5 ),
					[ "$pp_colour_mulg" ] = math.random( 0, 5 ),
					[ "$pp_colour_mulb" ] = math.random( 0, 5 )
				}
			end
			local tab = table.shallowcopy( self.Vars.ColorModify )
				for k, v in pairs( tab ) do
					tab[k] = mult * v
				end
			DrawColorModify( tab )
		end,
	}
	local effs = {}
		for eff = 1, math.random( 3, 7 ) do
			table.insert( effs, math.random( 1, #effect ) )
		end
	self.ScreenEffect = function( self, mult )
		-- if ( math.random( 1, 10000 ) ) then
			-- mult = 0
		-- end
		print( mult )
		for k, eff in pairs( effs ) do
			effect[eff]( self, mult )
		end
	end
end

hook.Add( "RenderScreenspaceEffects", "MM_RenderScreenspaceEffects_Anomaly", function()
	for k, ent in pairs( ents.FindInSphere( LocalPlayer():GetPos(), 1000 ) ) do
		if ( ent:GetClass() == "mm_anomaly" ) then
			local dist = LocalPlayer():GetPos():Distance( ent:GetPos() )
			local mult = ( 1 - ( dist / ent.Range ) )
			ent:ScreenEffect( mult )
		end
	end
end )