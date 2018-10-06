-- Matthew Cormack
-- 03/10/18

-- <<<<<<<<<<<<<<<<
-- Net
-- <<<<<<<<<<<<<<<<
-- From CLIENT
util.AddNetworkString( "MM_Rune_Recognised" )
net.Receive( "MM_Rune_Recognised", function( len, ply )
	local rune = net.ReadString()

	print( "Received Rune.. " .. rune )
	if ( rune and MM_Runes[rune] ) then
		MM_Runes[rune]:Invoke( ply )
	end
end )
