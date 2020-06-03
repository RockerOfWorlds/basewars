AddCSLuaFile()

ENT.Base = "bw_base_explosive"
ENT.PrintName = "C4 Explosive"

ENT.Model = "models/weapons/w_c4_planted.mdl"

ENT.ExplodeTime = 40
ENT.ExplodeRadius = 400
ENT.DefuseTicks = 400
ENT.DefuseTime = 5
ENT.ShowTimer = true
ENT.OnlyPlantWorld = true
ENT.UsePlant = true

function ENT:OnDefuse()

	self.Owner:SetNWInt( "InGameC4Planted", self.Owner:GetNWInt( "InGameC4Planted" ) - 1 )

end