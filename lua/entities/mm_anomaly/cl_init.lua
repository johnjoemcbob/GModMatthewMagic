include( "shared.lua" )

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
			self.Vars.Contrast = math.random( 1, 200 )
			self.Vars.Distance = math.random( 1, 50 )
		end
		DrawSharpen(
			mult * self.Vars.Contrast,
			math.abs( mult * self.Vars.Distance )
		)
	end,
	function( self, mult )
		if ( !self.Vars ) then
			self.Vars = {}
		end
		if ( !self.Vars.Sobel ) then
			self.Vars.Sobel = true
			self.Vars.Threshold = math.random( 0.01, 0.5 ) * 500
		end
		local mult = ( 1 - ( mult ) )
		local thresh = math.max( 0.01, mult * self.Vars.Threshold )
		DrawSobel(
			thresh
		)
	end,
	function( self, mult )
		if ( !self.Vars ) then
			self.Vars = {}
		end
		if ( !self.Vars.ToyTown ) then
			self.Vars.ToyTown = true
			self.Vars.Passes = math.random( 50, 100 )
			self.Vars.Height = math.random( 0.2, 1 )
		end
		DrawToyTown(
			mult * self.Vars.Passes,
			mult * self.Vars.Height * ScrH()
		)
	end,
	function( self, mult )
		if ( !self.Vars ) then
			self.Vars = {}
		end
		if ( !self.Vars.ColorModify ) then
			local rgb = math.random( 1, 3 )
			self.Vars.ColorModify = {
				[ "$pp_colour_addr" ]		= math.random( 0, 0.5 ),
				[ "$pp_colour_addg" ]		= math.random( 0, 0.5 ),
				[ "$pp_colour_addb" ]		= math.random( 0, 0.5 ),
				[ "$pp_colour_brightness" ]	= math.random( 0, 0.3 ),
				[ "$pp_colour_contrast" ]	= 1,// math.random( 1, 5 ),
				[ "$pp_colour_colour" ]		= 1,// math.random( 1, 5 ),
				[ "$pp_colour_mulr" ]		= rgb == 1 and math.random( 0, 0.5 ) or 0,
				[ "$pp_colour_mulg" ]		= rgb == 2 and math.random( 0, 0.5 ) or 0,
				[ "$pp_colour_mulb" ]		= rgb == 3 and math.random( 0, 0.5 ) or 0,
			}
			self.Vars.ColorModifyFuncs = {
				[ "$pp_colour_addr" ]		= function( val, mult ) return mult * val end,
				[ "$pp_colour_addg" ]		= function( val, mult ) return mult * val end,
				[ "$pp_colour_addb" ]		= function( val, mult ) return mult * val end,
				[ "$pp_colour_brightness" ]	= function( val, mult ) return val end,
				[ "$pp_colour_contrast" ]	= function( val, mult ) return val end,
				[ "$pp_colour_colour" ]		= function( val, mult ) return mult * val end,
				[ "$pp_colour_mulr" ]		= function( val, mult ) return mult * val end,
				[ "$pp_colour_mulg" ]		= function( val, mult ) return mult * val end,
				[ "$pp_colour_mulb" ]		= function( val, mult ) return mult * val end,
			}
		end
		local tab = table.shallowcopy( self.Vars.ColorModify )
			for k, val in pairs( tab ) do
				tab[k] = self.Vars.ColorModifyFuncs[k]( val, mult )
			end
		DrawColorModify( tab )
	end,
}

function ENT:Initialize()
	local effs = {}
		for eff = 1, math.random( 3, 7 ) do
			table.insert( effs, math.random( 1, #effect ) )
		end
	self.ScreenEffect = function( self, mult )
		-- if ( math.random( 1, 10000 ) ) then
			-- mult = 0
		-- end
		-- print( mult )
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
			if ( mult >= 0 ) then
				print( mult )
				ent:ScreenEffect( mult )
			end
		end
	end
end )