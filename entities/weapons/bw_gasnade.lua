AddCSLuaFile()

SWEP.PrintName 				= "Gas grenade"
SWEP.Author 				= "Poli & Q2F2"
SWEP.Instructions 			= "Throw at people to kill them with poison gas"
SWEP.Purpose 				= "Poison"
SWEP.Contact 				= ""

SWEP.Spawnable 				= true
SWEP.Category = "BaseWars"

SWEP.ViewModelFOV 			= 90
SWEP.ViewModelFlip 			= true
SWEP.ViewModel 				= "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel 			= "models/weapons/w_eq_flashbang.mdl"

SWEP.AutoSwitchTo 			= true
SWEP.AutoSwitchFrom 		= false

SWEP.Slot 					= 4
SWEP.SlotPos 				= 2

SWEP.HoldType 				= "grenade"
SWEP.Weight 				= 420
SWEP.DrawCrosshair 			= true
SWEP.Category 				= "BaseWars"
SWEP.DrawAmmo 				= false
SWEP.Base 					= "weapon_base"

SWEP.Primary.Damage     	= 0
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.Ammo 			= "grenade"
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic 		= false

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo 		= "none"


function SWEP:PrimaryAttack()

	if self.Owner:GetAmmoCount("Grenade") == 0 then return end

	self.Weapon:SetNextPrimaryFire(CurTime() + 2.5)
	self.Weapon:SetNextSecondaryFire(CurTime() + 2.5)
	self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)

	if SERVER then

		timer.Simple(0.7, function()

			if self:IsValid() then

				self.Weapon:SendWeaponAnim(ACT_VM_THROW)
				self:LongGas()

				timer.Simple(0.5,function()

					if self:IsValid() then
						self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
					end

				end)

			end

		end)

	end

end

function SWEP:SecondaryAttack()

	if self.Owner:GetAmmoCount("Grenade") == 0 then return end

	self.Weapon:SetNextPrimaryFire(CurTime() + 2.5)
	self.Weapon:SetNextSecondaryFire(CurTime() + 2.5)
	self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)

	if SERVER then

		timer.Simple(0.7, function()

			if self:IsValid() then

				self.Weapon:SendWeaponAnim(ACT_VM_THROW)
				self:ShortGas()

				timer.Simple(0.5,function()

					if self:IsValid() then
						self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
					end

				end)

			end

		end)

	end

end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetHoldType(self.HoldType)

	if SERVER then
		self.Weapon:SetMaterial("models/dav0r/hoverball")
	end

	return true

end

function SWEP:Holster()

	if SERVER then
		self.Weapon:SetMaterial("")
	end

	return true

end

function SWEP:PreDrawViewModel(vm)

	Material("models/dav0r/hoverball"):SetVector("$color2", Vector(0.1, 1, 0.1))

end

function SWEP:PostDrawViewModel(vm)

	Material("models/dav0r/hoverball"):SetVector("$color2", Vector(1, 1, 1))

end

function SWEP:LongGas()

	self.Weapon:TakePrimaryAmmo(1)

	local gasnade = ents.Create("bw_grenade_gas")
		gasnade:SetPos(self.Owner:GetShootPos() + Vector(0, 0, -9))
		gasnade:SetAngles(self.Owner:GetAimVector():Angle())
		gasnade:SetPhysicsAttacker(self.Owner)
		gasnade:SetOwner(self.Owner)
	gasnade:Spawn()
	gasnade.Owner = self.Owner

	gasnade:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() * math.random(3000, 4000) + Vector(0, 0, math.random(100, 150)))
	self.Owner:EmitSound("weapons/ar2/ar2_reload_rotate.wav", 40, 100)

end

function SWEP:ShortGas()

	self.Weapon:TakePrimaryAmmo(1)

	local gasnade = ents.Create("bw_grenade_gas")
		gasnade:SetPos(self.Owner:GetShootPos() + Vector(0, 0, -9))
		gasnade:SetAngles(self.Owner:GetAimVector():Angle())
		gasnade:SetPhysicsAttacker(self.Owner)
		gasnade:SetOwner(self.Owner)
	gasnade:Spawn()
	gasnade.Owner = self.Owner

	gasnade:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() * math.random(500, 1000) + Vector(0, 0, math.random(100, 150)))
	self.Owner:EmitSound("weapons/ar2/ar2_reload_rotate.wav", 40, 100)

end
