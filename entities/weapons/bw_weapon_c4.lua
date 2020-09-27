AddCSLuaFile()

SWEP.PrintName 				= "C4"
SWEP.Author 				= "Ghosty & Q2F2"
SWEP.Instructions 			= "Blow things up"
SWEP.Purpose 				= "Explodes"

SWEP.Slot					= 5
SWEP.SlotPos				= 3

SWEP.Spawnable				= true
SWEP.Category 				= "BaseWars"

SWEP.ViewModel				= Model("models/weapons/v_c4.mdl")
SWEP.WorldModel				= Model("models/weapons/w_c4.mdl")
SWEP.ViewModelFOV			= 54
SWEP.UseHands				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"


function SWEP:Initialize()

	self:SetHoldType("slam")

end

function SWEP:PrimaryAttack()

	if CLIENT then return end
	if self.Owner:GetNWInt( "InGameC4Planted" ) >= 2 and self.Owner:GetPrestige( "perk", "c4limitperk" ) <= 0 then self.Owner:Notify( "You cannot have more than 2 C4 placed in-game at a time!", BASEWARS_NOTIFICATION_ERROR ) return end
	if self.Owner:GetNWInt( "InGameC4Planted" ) >= BaseWars.Config.Perks["c4limitperk"].Additions and self.Owner:GetPrestige( "perk", "c4limitperk" ) >= 1 then self.Owner:Notify( "You cannot have more than " .. BaseWars.Config.Perks["c4limitperk"]["Additions"] .. " C4 placed in-game at a time!", BASEWARS_NOTIFICATION_ERROR ) return end
	if self.Owner:GetNWInt( "InGameC4Planted" ) == 0 or nil then self.Owner:SetNWInt( "InGameC4Planted", 0 ) end

	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 128,
		filter = self.Owner
	})

	if not tr.Hit then return end

	local ent = tr.Entity

	if not ent:IsPlayer() and not ent:IsNPC() then

		local p = ent
		local ent = ents.Create("bw_explosive_c4")

		local pos = tr.HitPos + tr.HitNormal * 2
		local ang = tr.HitNormal:Angle()

		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 180)

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
		ent:Activate()
		ent.Owner = self.Owner
		ent:Plant(not p:IsWorld() and p)

		self:Remove()

	end

	self:SetNextPrimaryFire(CurTime() + 1)

end

function SWEP:SecondaryAttack()

	if CLIENT then return end
	if self.Owner:GetNWInt( "InGameC4Planted" ) >= 2 and self.Owner:GetPrestige( "perk", "c4limitperk" ) <= 0 then self.Owner:Notify( "You cannot have more than 2 C4 placed in-game at a time!", BASEWARS_NOTIFICATION_ERROR ) return end
	if self.Owner:GetNWInt( "InGameC4Planted" ) >= BaseWars.Config.Perks["c4limitperk"].Additions and self.Owner:GetPrestige( "perk", "c4limitperk" ) >= 1 then self.Owner:Notify( "You cannot have more than " .. BaseWars.Config.Perks["c4limitperk"]["Additions"] .. " C4 placed in-game at a time!", BASEWARS_NOTIFICATION_ERROR ) return end
	if self.Owner:GetNWInt( "InGameC4Planted" ) == 0 or nil then self.Owner:SetNWInt( "InGameC4Planted", 0 ) end

	local ply = self.Owner

	if BaseWars.Config.DisableC4Throwing then return end

	local p = ent
	local ent = ents.Create("bw_explosive_c4")

	ent:SetPos(ply:GetShootPos() + ply:GetAimVector() * 16)
	ent:SetAngles(ply:GetAimVector():Angle())
	ent:Spawn()
	ent:Activate()
	ent.Owner = self.Owner

	local po = ent:GetPhysicsObject()

	if IsValid(po) then
		po:AddVelocity(ply:GetAimVector() * 4000)
	end

	function ent:PhysicsCollide(data)
		if data.HitEntity:IsWorld() then
			local ang = data.HitNormal:Angle()
			ang:RotateAroundAxis(ang:Right(), 90)
			ang:RotateAroundAxis(ang:Up(), 180)
			self:SetAngles(ang)
			self:SetPos(data.HitPos)
			self:Plant()
			self.PhysicsCollide = nil
		else
			local po = self:GetPhysicsObject()
			if IsValid(po) then
				po:AddVelocity(VectorRand() * 2000)
				po:AddAngleVelocity(VectorRand() * 2000)
			end
		end
	end

	self:Remove()

	self.Owner:SetNWInt( "InGameC4Planted", self.Owner:GetNWInt( "InGameC4Planted" ) + 1 )

end
