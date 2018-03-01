require("PlayerEffectPlugin")
require("Tweener")

Ahri_PlayerEffectMovePlugin = Class(PlayerEffectPlugin)
 
function Ahri_PlayerEffectMovePlugin:ctor(name)

    self.mSpeed = 10
    self.mDistance = 10
    
    self.mParent = nil
    self.mGo = nil

end 


function Ahri_PlayerEffectMovePlugin:Init(configure)

    if configure == nil then return end

    self.mSpeed = configure.speed
    self.mDistance = configure.distance


end


function Ahri_PlayerEffectMovePlugin:OnBegin()
    
    self:ClearEffectState()

    if self.mGo == nil then

        self.mGo = self.machine.mPlayerCharacter.mFashionWeapon.mWeapon
      
    end
    if self.mParent == nil then
        self.mParent = self.machine.mPlayerCharacter.mFashionBody.mBody.transform:Find(self.machine.mPlayerCharacter.mPlayerInfo.weaponBone)

    end
    self:OnEnd()
    self.mGo.transform:SetParent(nil)
 
    self.mOriginalPosition = self.mParent.position
   
    self.mDestination = self.mOriginalPosition + self.machine.mPlayerCharacter.transform.forward * self.mDistance

    self.mDuration = self.mDistance * 1.0 / self.mSpeed

    if self.mTween == nil then

        self.mTween = Tweener.new()
        self.mTween.method = TweenerMethod.EaseOut
        self.mTween.onFinished = function() 
            self.mGo:SetActive(false)
        end
        self.mTween.onUpdate = function (factor, isFinished)

            self.mGo.transform.position = self.mOriginalPosition * (1-factor) + self.mDestination * factor

        end
    end
    self.mTween:ResetToBeginning()
    self.mTween.duration = self.mDuration
    self.mTween:PlayForward()
end

function Ahri_PlayerEffectMovePlugin:OnExecute()

   
end

function Ahri_PlayerEffectMovePlugin:OnEnd()
    
    if self.mTween then
        self.mTween:Pause()
        --self.mTween:ResetToBeginning()
    end
    
    if self.mGo then
        
        self.mGo:SetActive(true)

        self.mGo.transform:SetParent(self.mParent)
        self.mGo.transform.localPosition = Vector3.zero

    end
   
   
end
--动作状态机退出
function Ahri_PlayerEffectMovePlugin:OnExit()

    self:OnEnd()

    self.mPlayerEffectState.isPlaying = false    

end

function Ahri_PlayerEffectMovePlugin:OnPause()


end


function Ahri_PlayerEffectMovePlugin:OnResume()



end

---因为要控制阿狸的法球，所以要退出其他控制法球的特效状态
function Ahri_PlayerEffectMovePlugin:ClearEffectState()

    local list = {}

    for i,v in ipairs(self.machine.mPlayerCharacter.mEffectMachine.mEffectStateList) do
     
        if  v.mPlayerSkillState.mPlayerSkillType == PlayerSkillType.Attack_1 or
            v.mPlayerSkillState.mPlayerSkillType == PlayerSkillType.Attack_2 or
            v.mPlayerSkillState.mPlayerSkillType == PlayerSkillType.Attack_3 or
            v.mPlayerSkillState.mPlayerSkillType == PlayerSkillType.Skill_1  or
            v.mPlayerSkillState.mPlayerSkillType == PlayerSkillType.Skill_2 then
        
            table.insert( list, v )
        end

    end

    for i,v in ipairs(list) do
        self.machine.mPlayerCharacter.mEffectMachine:Remove(v)
    end

end