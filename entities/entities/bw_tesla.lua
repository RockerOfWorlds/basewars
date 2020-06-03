AddCSLuaFile()

ENT.Base = "bw_base_electronics"
ENT.Type = "anim"

ENT.PrintName = "Tesla Coil"
ENT.Model = "models/props_c17/substation_transformer01d.mdl"
ENT.Material = "models/alyx/emptool_glow"

ENT.PowerRequired = 10
ENT.PowerMin = 9000
ENT.PowerCapacity = 12500
ENT.IsAbleToSetRange = true

ENT.Drain = 1500

ENT.Damage 	= 60
ENT.Radius 	= 300
ENT.Delay	= 10

ENT.Sound = Sound("npc/roller/mine/rmine_explode_shock1.wav")
ENT.Color = Color(100, 100, 255, 255)

ENT.PresetMaxHealth = 2500

ENT.AlwaysRaidable = false

if CLIENT then return end

function ENT:Init()

	self:SetModel(self.Model)
	self:SetMaterial(self.Material)

	if self:GetRadius() >= 1 then

		self.Radius = self:GetRadius()

	else

		self:SetRadius( self.Radius )

	end

	self.Time = CurTime()

end

function ENT:ThinkFunc()

	if self.Time + self.Delay > CurTime() then return end

	local Owner = BaseWars.Ents:ValidOwner(self)
	if not Owner then return end

	if not self:IsPowered(self.PowerMin) then return end

	self.Time = CurTime()

	if self:GetRadius() >= 1 then

		self.Radius = self:GetRadius()

	else

		self:SetRadius( self.Radius )

	end

	local Plys = ents.FindInSphere(self:GetPos(), self.Radius)
	local Pos = self:GetPos()

	for k, v in next, Plys do

		if not BaseWars.Ents:ValidPlayer(v) or not v:Alive() then continue end
		if not Owner:IsEnemy(v) then continue end

		if not self:IsPowered(self.PowerRequired) then return end

		local d = DamageInfo()
			d:SetDamage(self.Damage)
			d:SetDamageType(DMG_SHOCK)
			d:SetAttacker(Owner)

		v:TakeDamageInfo(d)
		v:ApplyDrug("Stun", 20)
		v:ScreenFade(SCREENFADE.IN, self.Color, 0.5, 0)

		local e = EffectData()
			e:SetStart(Pos)
			e:SetOrigin(Pos)
			e:SetScale(1)

		util.Effect("cball_explode", e)

		self:DrainPower(self.Drain)
		self:EmitSound(self.Sound, 100, 70)

	end

end