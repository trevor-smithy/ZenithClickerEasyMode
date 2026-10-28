local max, min = math.max, math.min
local abs, rnd = math.abs, math.random
local sin, cos = math.sin, math.cos
local sign, lerp = MATH.sign, MATH.lerp
local expApproach, clampInterpolate = MATH.expApproach, MATH.clampInterpolate
local getTime = love.timer.getTime

local GAME = GAME
local M = GAME.mod
local CD = Cards

---@class Card
---@field burn number?
local Card = {}
Card.__index = Card
function Card.new(d)
    local obj = setmetatable({
        initOrder = d.initOrder,
        tempOrder = d.initOrder,
        id = d.id,
        lockfull = d.lockfull,

        lock = STAT.unlockAll and false or true,
        active = false,
        front = true,
        upright = true,
        easy = false,

        x = 0,
        y = 0,
        size = .62,
        
        -- Display-only
        x1 = 0,         -- X anim
        y1 = 0,         -- Y anim
        dy_ms = 0,      -- delta Y for MS anim
        r_3d = 0,       -- 3D rotation
        r_3d_in = 0,    -- 3D rotation (for IN mod)
        r_2d_rev = 0,   -- 2D rotation (for reverse anim)
        r_2d_shake = 0, -- 2D rotation (for shake anim)
        float = 0,      -- mouse floating anim, 0-1

        touchCount = 0,
        burn = false,
        required = false,
        required2 = false,
        inLastCommit = false,
        charge = 0,
        revJumping = false,
        bouncing = false,
        assistPenalty = 5,
    }, Card)
    return obj
end

function Card:mouseOn(x, y)
    return
        abs(x - self.x) <= self.size * (480 / 2) and
        abs(y - self.y) <= self.size * (660 / 2)
end

local completion = GAME.completion
local KBisDown = love.keyboard.isDown
local function tween_deckPress(t) DeckPress = 26 * (1 - t) end
local function task_refreshBGM()
    TASK.yieldT(.1)
    RefreshBGM()
end

---@param card Card
local function fixCard(card)
    local otherCardActivated
    if not card.active and card.required or card.active and not card.required then --if not active and needed, activate. if active and not needed, deactivate. if active and needed, don't do anything. if not active and not needed, don't do anything.
        card.active = not card.active
        otherCardActivated = true
        card.assistPenalty = card.active and min(card.assistPenalty, 1) or 5
    end
    return otherCardActivated
end

---@param self Card 
---@param auto boolean i.e. was not manually selected
---@param key number? 1 or nil = active/inactive 2 = reverse 3 = easy
---@param friendActivation boolean? If true, do not check for closer card
function Card:setActive(auto, key, friendActivation)
    local eNHBlocksFaults = M.NH == -1 and true or false
    if not auto then
        GAME.spinCheck = false
        GAME.rollCheck = false
    end
    if TASK.getLock('cannotFlip') or GAME.playing and M.NH == 1 and not auto and self.active or (not GAME.playing and GAME.badTime) then
        self:flick()
        SFX.play('no')
        return
    end
    if (M.VL == 1 and not self.active) or (M.NH == -1 and (GAME.playing or (M.VL == 2 and not GAME.playing)) and self.active) then
        if not auto then
            self.charge = self.charge + 1
            SFX.play('clearline', .42)
            if self.charge < 1.2 then
                self:shake()
                SFX.play('combo_' .. rnd(2, 3), .626, 0, Tone(-2))
                return
            end
            SFX.play('combo_4', .626, 0, Tone(0))
            self.charge = 0
        end
    elseif M.VL == 2 then
        local ultimateChallengeMod = GAME.ultimateChallenge and (1 + (M.DP == 0 and ((GAME.startingHealth-GAME.life)/GAME.startingHealth * 2) or ((GAME.startingHealth*2-(GAME.life+GAME.life2))/GAME.startingHealth))) or 1
        self.charge = self.charge + (auto and 3.55 or 1)
        if self.charge < 3.1 then
            SFX.play('clearline', .3)
            self:shake()
            if self.charge < 1.3 then
                SFX.play('combo_1', .626, 0, Tone(0 + (GAME.enightcore and 1 or -6*ultimateChallengeMod+6)))
            elseif self.charge < 2.2 then
                SFX.play('combo_3', .626, 0, Tone(-2 + (GAME.enightcore and 1 or -6*ultimateChallengeMod+6)))
            else
                SFX.play('combo_2', .626, 0, Tone(1 + (GAME.enightcore and 1 or -6*ultimateChallengeMod+6)))
            end
            return
        end
        if not auto then
            SFX.play('clearquad', .3)
            SFX.play('combo_4', .626, 0, Tone(0 + (GAME.enightcore and 1 or -6*ultimateChallengeMod+6)))
        end
        self.charge = 0
    end

    if GAME.currentTask then
        if self.active then
            GAME.incrementPrompt('cancel')
            if not auto then GAME.nixPrompt('keep_no_cancel') end
        else
            GAME.incrementPrompt('activate')
        end
        if not auto then
            if self.id ~= GAME.lastFlip then
                GAME.nixPrompt('flip_single')
            end
            GAME.incrementPrompt('flip_single')
        end
        GAME.incrementPrompt('flip')
    end
    if not auto then
        GAME.lastFlip = self.id
    end
    if not auto and not self.active and GAME.comboStr == 'eASeNH' and GAME.playing then
        GAME.noManualActivate = false
    end
    -- Trevor Smithy
    self.active = not self.active -- the main flip

    if self.active and GAME.height >= 650 and GAME.playing then GAME.achv_postF5ActivatedCards = GAME.achv_postF5ActivatedCards + 1 end
    --Closer Card
    if GAME.ecloseCard and GAME.playing and not (auto or friendActivation) then
        self.active = not self.active
        if not GAME.achv_noManualFlipH then
            GAME.achv_noManualFlipH = GAME.roundHeight
            if GAME.totalQuest >= 3 then SFX.play('btb_break') end
        end
        local leftCard
        local rightCard
        local maxCardDistance = 1 + max((M.EX == 2 and URM and 2 or M.EX == 2 and 1 or M.EX == 1 and 1 or 0) - abs(M.VL) + (GAME.closeCard and 1 or 0),0)
        local otherCardActivated = false
        for i = 1, maxCardDistance do
            if self.tempOrder > i then leftCard = CD[self.tempOrder - i] end
            if leftCard then
                if fixCard(leftCard) then otherCardActivated = true end
            end
            if self.tempOrder < 10-i then rightCard = CD[self.tempOrder + i] end
            if rightCard then
                if fixCard(rightCard) then otherCardActivated = true end
            end
        end
        if not self.active and self.required then --if not active and needed, activate. if active and not needed, deactivate. if active and needed, don't do anything. if not active and not needed, don't do anything.
            self.active = not self.active
            self.assistPenalty = 0
        elseif self.active and not self.required then
            self.active = not self.active
            self.assistPenalty = 5
        elseif self.active and self.required and (self.touchCount == 0 or M.NH == -1 and self.touchCount <= 1) then
            --don't deselect a correct card
            self.assistPenalty = 0
        elseif not otherCardActivated and GAME.questTime > 0.26 then
            self.active = not self.active
            self.assistPenalty = 5
            if not eNHBlocksFaults then
                GAME.fault = true
            end
        end
    end

    local noSpin, revOn, easyOn
    if not GAME.playing then
        -- not in-game, update various global states
        TASK.unlock('cannotStart')
        -- Trevor Smithy
        easyOn = self.active and (key == 3 or KBisDown('lalt', 'ralt') and (not key or key < 4) or key == 6)
        --
        revOn = self.active and (key == 2 or KBisDown('lctrl', 'rctrl') and (not key or key < 4) or key == 5)
        if revOn and completion[self.id] == 0 and not STAT.unlockAll then
            revOn = false
            noSpin = true
            self.active = false
            if STAT.maxFloor >= 10 then
                self:shake()
                SFX.play('no')
                MSG('dark', "Reach F10 with this mod first!")
            end
            return
        end
        local wasRev = M[self.id] == 2
        local wasEasy = M[self.id] == -1
        -- Trevor Smithy
        M[self.id] = self.active and (revOn and 2 or easyOn and -1 or 1) or 0
        -- if revOn then for _, C in ipairs(CD) do if C.active and C ~= self then C:setActive(true) end end end -- Unique rev mod limit
        self.upright = not (self.active and revOn or self.active and easyOn)
        self.easy = self.active and easyOn and not revOn
        --
        if revOn or wasRev then GAME.refreshRev() end
        TASK.removeTask_code(task_refreshBGM)
        TASK.new(task_refreshBGM)
        if wasRev and not revOn then
            self:revCancel()
        end
        -- Trevor Smithy
        if self.id == 'EX' then
            local s = GAME.exTimer
            local e = M.EX ~= 0 and 1 or 0
            TWEEN.new(function(t)
                GAME.exTimer = lerp(s, e, t)
            end):setUnique('expertOn'):setEase('OutQuad'):setDuration(M.EX ~= 0 and .26 or .1):run()
            TABLE.clear(HoldingButtons)
        elseif self.id == 'IN' then
            for _, C in ipairs(CD) do C:flip() end
            noSpin = (M.IN == 1 or M.IN == -1)
        end
        -- Trevor Smithy
        if easyOn or wasEasy then GAME.refreshEasy() end
        if wasEasy and not easyOn then self:easyCancel() end
        if easyOn or revOn or wasEasy or wasRev then GAME.refreshUneasy() end
        --
        SCN.scenes.tower.widgetList.reset:setVisible(not GAME.zenithTraveler)
        GAME.hardMode = M.EX > 0 or GAME.anyRev and not URM
        GAME.refreshPBText()
        GAME.refreshRPC()
    elseif not auto then
        -- in-game manual flip, triggering effects
        self.touchCount = self.touchCount + 1
        GAME.totalFlip = GAME.totalFlip + 1
        if not GAME.achv_noManualFlipH then
            GAME.achv_noManualFlipH = GAME.roundHeight
            if GAME.totalQuest >= 3 then SFX.play('btb_break') end
        end
        if self.touchCount == 1 then
            if (self.required or self.required2) and not GAME.hardMode then
                GAME.addXP(M.VL == 1 and 2 or 1)
            end
            if (self.required or self.required2) then
                -- Trevor Smithy
                GAME.addXP(M.VL == -1 and 2 or 0)
            end
        elseif not GAME.fault and not self.burn and not (eNHBlocksFaults) then
            GAME.fault = true
        end
        if M.DP ~= 0 and not auto and self.id == 'DP' and self.active and not (URM and M.DP == 2) then
            if GAME.swapControl() then
                SFX.play('party_ready', .8)
            end
        end
        if not auto then
            -- Trevor Smithy
            if M.GV ~= 0 and not GAME.gravTimer then
                GAME.gravTimer = GAME.gravDelay
            end
            if M.AS > 0 then
                if self.burn then
                    if URM and M.NH == -1 then GAME.OSPActivated = true end
                    self.burn = false
                    TASK.removeTask_code(GAME.task_cancelAll)
                    local p = TABLE.find(CD, self) or 0
                    local l = { -3, -2, -1, 1, 2, 3 }
                    local coinFlip = rnd(1,2)
                    if M.NH ~= -1 then
                        CD[(p + table.remove(l, rnd(4, 6)) - 1) % #CD + 1]:setActive(true)
                        CD[(p + table.remove(l, rnd(1, 3)) - 1) % #CD + 1]:setActive(true)
                    elseif M.NH == -1 and coinFlip == 1 then
                        CD[(p + table.remove(l, rnd(4, 6)) - 1) % #CD + 1]:setActive(true)
                    elseif M.NH == -1 and coinFlip == 2 then
                        CD[(p + table.remove(l, rnd(1, 3)) - 1) % #CD + 1]:setActive(true)
                    end
                    GAME.achv_escapeBurnt = true
                    if M.AS == 2 then
                        if M.NH ~= -1 then
                            CD[(p + table.remove(l, rnd(3, 4)) - 1) % #CD + 1]:setActive(true)
                            CD[(p + table.remove(l, rnd(1, 2)) - 1) % #CD + 1]:setActive(true)
                        elseif M.NH == -1 and coinFlip == 1 then
                            CD[(p + table.remove(l, rnd(1, 2)) - 1) % #CD + 1]:setActive(true)
                        elseif M.NH == -1 and coinFlip == 2 then
                            CD[(p + table.remove(l, rnd(3, 4)) - 1) % #CD + 1]:setActive(true)
                        end
                        if GAME.floor < 10 and GAME.gigaspeed then GAME.achv_felMagicBurnt = true end
                        if not GAME.OSPActivated then
                            if URM then return GAME.takeDamage(1e99, 'wrong') end
                        else
                            GAME.takeDamage(GAME.fullHealth-(GAME.dmgWrong+0.1), 'wrong') 
                            GAME.fault = true
                            GAME.bonusRecoveryHealth = GAME.bonusRecoveryHealth + 3
                            GAME.dmgTimerMul = GAME.dmgTimerMul + 1
                            GAME.OSPActivated = false
                            for i = 1, #Cards do
                                if Cards[i].burn then
                                    Cards[i].burn = 8/9 + (GAME.floor)/9
                                end
                            end
                            if GAME[GAME.getLifeKey()] > 0.01 then
                                TEXT:add {
                                    text = 'CAREFUL THERE!',
                                    x = 800, y = 265, fontSize = 30, k = 1.5,
                                    style = 'score', duration = 5,
                                    inPoint = .1, outPoint = .26,
                                    color = 'lM',
                                }
                                IssueAchv('cheat_death')
                                GAME.achv_cheatDeathUAS = true
                            end
                        end
                    end
                    SFX.play('wound')
                else
                    if M.NH == -1 then
                        self.burn = (M.AS == 1 and 1.5 + GAME.floor / 4) or (M.AS == 2 and not URM and 3 + GAME.floor / 2) or 1e99
                    else
                        self.burn = M.AS == 1 and 3 + GAME.floor / 2 or 1e99
                    end
                end
            end
        end
    end
    GAME.refreshCurrentCombo()
    GAME.refreshLayout()
    if auto then
        if self.active and revOn then self:revJump() end
        return
    end

    -- Sound and animation
    if self.active then
        local postfix = revOn and '_reverse' or 
        (((easyOn or (GAME.playing and CONF.easyName)) and GAME.smithyMode) or (GAME.playing and GAME.forceSmithyNoises)) and '_easy_voice' 
        or (easyOn or (GAME.playing and CONF.easyName)) and '_easy' or ''
        SFX.play(
            ((GAME.glassCard or GAME.eglassCard) and CONF.classicMode)  and 'harddrop' or 'card_select' .. postfix, 1, 0,
            key and clampInterpolate(-200, -4.2, 200, 4.2, self.y1 - MY) or MATH.rand(-2.6, 2.6)
        )
        local toneName = 'card_tone_' .. ModData.name[self.id]
        local toneVol = GAME.playing and .8 + GAME.floor * .02 - (GAME.gigaspeed and .26 or 0) or 1
        if revOn then
            SFX.play(toneName .. postfix, toneVol, 0, Tone(0))
            if URM then
                TASK.new(function()
                    TASK.yieldT(.2)
                    SFX.play(toneName, toneVol * .8, 0, Tone(7))
                    TASK.yieldT(.2)
                    SFX.play(toneName, toneVol * .6, 0, Tone(7))
                end)
            end
        elseif easyOn or (GAME.playing and (CONF.easyName or GAME.forceSmithyNoises)) then
            if GAME.uneasyMode and easyOn and not GAME.playing then
                TASK.new(function()
                    SFX.play(toneName .. postfix, toneVol, 0, Tone(-3))
                    SFX.play(toneName .. postfix, toneVol, 0, Tone(-0))
                end)
            else
                SFX.play(toneName .. postfix, toneVol, 0, Tone(0))
            end
        else
            SFX.play(toneName, toneVol, 0, Tone(0))
        end
        if revOn then
            self:revJump()
        elseif M.NH < 2 and not noSpin then
            self:spin()
        end
    else
        SFX.play('card_slide_' .. rnd(4))
        SFX.play('floor')
        SFX.play('hold')
    end
end

function Card:flip()
    self.front = not self.front
    local s, e = self.r_3d_in, self.front and 0 or 3.1416
    TWEEN.new(function(t)
        self.r_3d_in = lerp(s, e, t)
    end):setUnique('flip_' .. self.id):setEase('OutQuad'):setDuration((GAME.slowmo and 2.6 or 1) * .26):run()
end

function Card:spin()
    local re = (GAME.playing or self.upright or self.easy) and 0 or 3.1416
    local ease = (M.IN == 1 or M.IN == -1) and 'OutInQuart' or 'OutQuart'
    local rot = (CONF.classicMode and 1 or (math.abs(M.AS) + 1)) * (self.easy and -6.2832 or 6.2832)
    local duration = (GAME.slowmo and 2.6 or 1) * (M.IN == 2 and .62 or .42) * (1 + math.abs(M.AS) * .42)
    if GAME.ultimateChallenge and self.id == 'EX' then
        ease = 'Linear'
        duration = 240/ModifiedBPM()
        TWEEN.new(function(t)
            self.r_2d_rev = t * -6.2832
            end):setUnique('spin_' .. self.id):setEase(ease):setDuration(duration):run()
            :setOnKill(function()
                self.r_2d_rev = re
            end)
    else
        TWEEN.new(function(t)
        self.r_3d = t * rot
        end):setUnique('spin_' .. self.id):setEase(ease):setDuration(duration):run()
            :setOnKill(function()
                self.r_3d = re
            end)
    end
            
end

local bounceEase = { 'linear', 'inCubic' }
function Card:bounce(height, duration)
    if self.revJumping or self.bouncing then return end
    TWEEN.new(function(t)
        self.y1 = self.y + t * (t - 1) * height
    end):setUnique('bounce_' .. self.id):setTag('bounce_' .. self.id):setEase(bounceEase):setDuration((GAME.slowmo and 2.6 or 1) * duration):run()
        :setOnKill(function()
            self.bouncing = false
        end)
    self.bouncing = true
end

function Card:revJump()
    TWEEN.tag_kill('bounce_' .. self.id)
    local h = 326
    if self.id == 'EX' then
        h = h * (URM and 1.626 or 1.26)
    elseif self.id == 'GV' then
        h = h * (URM and .42 or .62)
    end    
    TWEEN.new(function(t)
        t = t * (t - 1) * 4
        self.y1 = self.y + t * h
        self.size = .62 - .355 * t
    end):setUnique('revJump_' .. self.id):setEase(bounceEase):setDuration((GAME.slowmo and 2.6 or 1) * .62 * (h / 355) ^ .5):run()
        :setOnFinish(function()
            self.revJumping = false
            local currentState = M[self.id]
            if currentState == 2 then
                TWEEN.new(tween_deckPress):setUnique('DeckPress'):setEase('OutQuad'):setDuration((GAME.slowmo and 2.6 or 1) * .42):run()
                if self.id ~= 'NH' then
                    for _, C in ipairs(CD) do
                        if C ~= self then
                            local r = rnd()
                            if self.id == 'EX' then
                                r = r * (URM and 12.6 or 2.6)
                            elseif self.id == 'MS' then
                                r = math.max(sign((r - .5)) * abs(r - .5) ^ .3333 / 1.5874 + .5, 0)
                            elseif self.id == 'GV' then
                                r = r * (URM and .126 or .26)
                            end
                            C:bounce(lerp(62, 420, r), lerp(.42, .62, r))
                        end
                    end
                end
                local color = ModData.color[self.id]
                table.insert(ImpactGlow, {
                    r = (color[1] - .26) * .8,
                    g = (color[2] - .26) * .8,
                    b = (color[3] - .26) * .8,
                    x = self.x1,
                    y = self.y1,
                    t = GAME.fallout and 2.6 or 1,
                    tk = 1 / (GAME.slowmo and 2.6 or 1),
                })
                GAME.revDeckSkin = true
                GAME.bgXdir = MATH.coin(-1, 1)
                if not URM then
                    SFX.play('card_reverse_impact', 1, 0, Tone(0))
                else
                    local tone = ModData.ultraImpactTone[self.id]
                    if tone[1] then SFX.play('card_reverse_impact', .626, 0, Tone(tone[1])) end
                    if tone[2] then SFX.play('card_reverse_impact', .8, 0, Tone(tone[2])) end
                    if tone[3] then SFX.play('card_reverse_impact', 1, 0, Tone(tone[3])) end
                    SFX.play('card_tone_' .. ModData.name[self.id] .. '_reverse', .42, 0, Tone(-5))
                end
            else
                SFX.play('spin')
                if currentState == 0 then
                    self:bounce(100, .26)
                else
                    for _, C in ipairs(CD) do
                        if C ~= self then
                            local r = 1 - abs(C.initOrder - self.initOrder) / 8
                            if self.id == 'EX' then r = r * (URM and 12.6 or 2.6) end
                            if self.id == 'MS' then r = r * MATH.rand(.26, 1.26) end
                            if self.id == 'GV' then r = r * (URM and .0626 or .26) end
                            C:bounce(lerp(120, 420, r), lerp(.42, .62, r))
                        end
                    end
                    IssueAchv('smooth_dismount')
                end
            end
        end)
        :setOnKill(function()
            self.revJumping = false
        end)
    self.revJumping = true
    local rot = self.id == 'AS' and 3 * 3.1416 or 3.1416
    local ease = self.id == 'GV' and 'OutQuart' or 'OutBack'
    local s = self.r_2d_rev
    TWEEN.new(function(t)
        self.r_2d_rev = lerp(s, rot, t)
    end):setUnique('spin2D_' .. self.id):setEase(ease):setDuration((GAME.slowmo and 2.6 or 1.06) * .52):run()
end

function Card:revCancel()
    local s = self.r_2d_rev
    TWEEN.new(function(t)
        self.r_2d_rev = lerp(s, 0, t)
    end):setUnique('spin2D_' .. self.id):setEase('OutQuart'):setDuration((GAME.slowmo and 2.6 or 1) * .26):run()
end

function Card:easyCancel()
    local s = self.r_2d_rev
    TWEEN.new(function(t)
        self.r_2d_rev = lerp(s, 0, t)
    end):setUnique('spin2D_' .. self.id):setEase('OutQuart'):setDuration((GAME.slowmo and 2.6 or 1) * .26):run()
end

function Card:shake()
    self.r_2d_shake = MATH.coin(-.26, .26)
    local s, e = self.r_2d_shake, 0
    TWEEN.new(function(t)
        self.r_2d_shake = lerp(s, e, t)
    end):setUnique('shake_' .. self.id):setEase('OutBack'):setDuration((GAME.slowmo and 2.6 or 1) * .2):run()
end

function Card:flick()
    TWEEN.new(function(t)
        self.size = lerp(.56, .62, t)
    end):setUnique('flick_' .. self.id):setEase('OutBack'):setDuration((GAME.slowmo and 2.6 or 1) * .26):run()
end

local activeFrame = GC.newImage('assets/card/outline1.png')
local frame1W, frame1H = activeFrame:getWidth() / 2, activeFrame:getHeight() / 2
local activeFrame2 = GC.newImage('assets/card/outline2.png')
local frame2W, frame2H = activeFrame2:getWidth() / 2, activeFrame2:getHeight() / 2

function Card:update(dt)
    self.x1 = expApproach(self.x1, self.x, dt * 16)
    if not (self.revJumping or self.bouncing) then
        self.y1 = expApproach(self.y1, self.y + self.dy_ms, dt * 16)
    end
    self.float = expApproach(self.float, CD[FloatOnCard] == self and 1 or 0, dt * 12)
    if self.burn then
        self.burn = self.burn - dt
        if self.burn <= 0 then
            self.burn = false
            SFX.play('wound_repel')
        end
    end
    if self.charge > 0 then
        local ultimateChallengeMod = GAME.ultimateChallenge and (1 + (M.DP == 0 and ((GAME.startingHealth-GAME.life)/GAME.startingHealth * 2) or ((GAME.startingHealth*2-(GAME.life+GAME.life2))/GAME.startingHealth))) or 1
        self.charge = math.max(self.charge - dt/(GAME.enightcore and 1 or ultimateChallengeMod), 0)
    end
end

local gc_setCanvas, gc_clear = GC.setCanvas, GC.clear
local gc_push, gc_pop = GC.push, GC.pop
local gc_origin, gc_translate, gc_rotate, gc_scale, gc_shear = GC.origin, GC.translate, GC.rotate, GC.scale, GC.shear
local gc_setColor, gc_setAlpha = GC.setColor, GC.setAlpha
local gc_setShader, gc_setLineWidth = GC.setShader, GC.setLineWidth
local gc_draw, gc_polygon, gc_mDraw = GC.draw, GC.polygon, GC.mDraw
local gc_glowCircle, gc_setBlendMode = GC.glowCircle, GC.setBlendMode

local burnColor = {
    uAS = { 1, .42, .26 },
    AS1 = COLOR.R,
    AS2 = COLOR.lY,
}
local canvasW, canvasH = 600, 800

local meshVertices = {}
for y = 0, 1, .125 do
    for x = 0, 1, .125 do
        table.insert(meshVertices, { x, y })
    end
end
local meshVerticePosTemplate = {}
for i = 1, #meshVertices do
    table.insert(meshVertices[i], 1, 0)
    table.insert(meshVertices[i], 2, 0)
    table.insert(meshVerticePosTemplate, {
        lerp(-canvasW / 2, canvasW / 2, meshVertices[i][3]),
        lerp(-canvasH / 2, canvasH / 2, meshVertices[i][4]),
    })
end

local tempCanvas = GC.newCanvas(canvasW, canvasH)
local tempMesh = GC.newMesh(meshVertices, 'strip', 'dynamic')
do
    local mat = TABLE.newMat(0, 9, 9)
    for y = 1, 9 do for x = 1, 9 do mat[y][x] = (y - 1) * 9 + x end end
    local vMap = {}
    for y = 1, 7, 2 do
        for x = 1, 9 do
            table.insert(vMap, mat[y][x])
            table.insert(vMap, mat[y + 1][x])
        end
        for x = 9, 2, -1 do
            table.insert(vMap, mat[y + 2][x])
            table.insert(vMap, mat[y + 1][x - 1])
        end
    end
    table.insert(vMap, mat[9][1])
    tempMesh:setVertexMap(unpack(vMap))
end
tempMesh:setTexture(tempCanvas)
local function rotate_point_around_axis(x, y, z, ax, ay, az, theta)
    local len = (ax * ax + ay * ay + az * az) ^ .5
    local kx, ky, kz = ax / len, ay / len, az / len
    local cos_t, sin_t = cos(theta), sin(theta)
    local dot = kx * x + ky * y + kz * z

    -- Rodrigues' rotation formula
    return
        x * cos_t + (ky * z - kz * y) * sin_t + kx * dot * (1 - cos_t),
        y * cos_t + (kz * x - kx * z) * sin_t + ky * dot * (1 - cos_t),
        z * cos_t + (kx * y - ky * x) * sin_t + kz * dot * (1 - cos_t)
end

local iconFrame
xpcall(function()
    local suc, res = FILE.safeLoad('customAssets/mod_polygon.luaon', '-luaon')
    if not suc then error("!" .. res) end
    iconFrame = res
    assert(iconFrame, "")
    assert(type(iconFrame) == 'table', "!Invalid mod_polygon data")
    assert(#iconFrame % 2 == 0, "!mod_polygon must have an even number of points")
    assert(#iconFrame <= 52, "!mod_polygon must have at most 26 points")
    for i = 1, #iconFrame do assert(type(iconFrame[i]) == 'number', "!mod_polygon must be a list of numbers") end
    assert(next(iconFrame, #iconFrame) == nil, "!mod_polygon must be a pure array")
end, function(msg)
    if msg:find("!") then LOG('warn', msg:match("!(.*)")) end
    local x, y = 156.5, -245.5
    local r = 65
    iconFrame = {
        x - r, y - r,
        x + 7, y - r,
        x + r, y - 7,
        x + r, y + r,
        x - 12, y + r,
        x - r, y + 12,
    }
end)

function Card:draw()
    local texture = TEXTURE[self.id]
    local _3D = not CONF.classicMode or CONF.rot3D
    local playing = GAME.playing
    local img, img2
    local rot3D = self.r_3d + self.r_3d_in
    local faceUp
    local finalRot = playing and self.r_2d_shake or self.r_2d_rev + self.r_2d_shake
    local finalSize = self == CD[FloatOnCard] and M.EX > 0 and love.mouse.isDown(1, 2) and .9 * self.size or self.size

    if self.lock and self.lockfull then
        img = texture.lock
    else
        if M.IN == 2 then
            img = texture.back
        else
            faceUp = math.floor(rot3D / 3.1416 + .5) % 2 == 0
            img = faceUp and texture.front or texture.back
        end
        if self.lock then
            img2 = texture.lock
        end
    end

    -- Calculating outline color
    local r1, g1, b1, a1
    local r2, g2, b2, a2
    if playing then
        if M.IN < 2 then
            if self.active then
                if self.required or self.required2 then
                    if self.required then
                        r1, g1, b1 = 1, .26, 0
                        if CONF.easyName then
                            if not (self.id == 'EX' and GAME.uneasyMode) then
                                r1, g1, b1 = 0, 1, 0          -- Green
                            else
                                r1, g1, b1 = 0.626, 0, 0      -- Dark Red (for Uneasy)
                            end
                        end
                        a1 = .6 + .4 * self.float
                    end
                    if self.required2 then
                        r2, g2, b2 = .942, .626, .872
                        a2 = .6 + .4 * self.float
                    end
                else
                    r1, g1, b1 = .4 + .1 * sin(GAME.time * 42 - self.x1 * .0026), 0, 0
                    a1 = 1
                end
            else
                if self.required or self.required2 then
                    if self.required then
                        r1, g1, b1 = 1, 1, 1
                        local qt = GAME.questTime
                        if M.IN == 0 then
                            if GAME.hardMode then qt = qt - 1.5 end
                            a1 = clampInterpolate(1, 0, 2, .4, qt) +
                                clampInterpolate(1.2, 0, 2.6, .2, qt) * sin(qt * 26 - self.x1 * .0026)
                        elseif M.IN == 1 then
                            if GAME.hardMode then qt = qt * .626 end
                            a1 = -.1 + .4 * sin(3.1416 + qt * 3)
                        -- Trevor Smithy
                        elseif M.IN == -1 then
                            qt = qt + 1.5
                            a1 = clampInterpolate(1, 0, 2, .4, qt) +
                                clampInterpolate(1.2, 0, 2.6, .2, qt) * sin(qt * 26 - self.x1 * .0026) + 0.2
                        end
                    end
                    if self.required2 then
                        r2, g2, b2 = 1, 1, 1
                        local qt = GAME.questTime
                        if M.IN == 0 then
                            if GAME.hardMode then qt = qt - 1.5 end
                            a2 = clampInterpolate(1, 0, 2, .2, qt)
                        elseif M.IN == 1 then
                            if GAME.hardMode then qt = qt * .626 end
                            a2 = -.1 + .2 * sin(3.1416 + qt * 3)
                        -- Trevor Smithy
                        elseif M.IN == -1 then
                            r2, g2, b2 = .942, .626, .872
                            qt = qt + 1.5
                            a2 = clampInterpolate(1, 0, 2, .2, qt) + 0.2
                        end
                    end
                end
            end
        else
            if self.active then
                r1, g1, b1 = 1, .26, 0
                a1 = .6 + .4 * self.float
            end
        end
    else
        if self.active then
            if self.easy then
                if not (self.id == 'EX' and (GAME.uneasyMode or GAME.ultimateChallenge)) then
                    r1, g1, b1 = 0, 1, 0          -- Green
                else
                    if GAME.uneasyMode then
                        r1, g1, b1 = 0.626, 0, 0  -- Dark Red (for Uneasy)
                    else -- ultimateChallenge
                        r1, g1, b1 = 1, 0.84, 0   -- Gold
                    end
                end
            elseif not self.upright then
                r1, g1, b1 = 0, .5, .7        -- Reversed
            elseif self.id ~= 'DP' then
                r1, g1, b1 = 1, .26, 0        -- Orange
            else
                r1, g1, b1 = .942, .626, .872 -- Pink
            end
            a1 = .6 + .4 * self.float
        end
        if self.required then
            r2, g2, b2 = 1, 0, .26
            a2 = getTime() % .1 < .0626 and 1 - (getTime() - GAME.finishTime) / 4.2
            if a2 and a2 <= 0 then self.required = false end
        end
    end

    -- Calculate 3D mesh
    if _3D then
        local f = 2600 - 20 * CONF.rot3D_focal
        local t1 = CONF.rot3D_tilt * .0042
        local t2 = CONF.rot3D_tilt * 20
        local float = self == CD[FloatOnCard]
        for i = 1, #meshVerticePosTemplate do
            local x, y, z = meshVerticePosTemplate[i][1], meshVerticePosTemplate[i][2], 0

            -- Real 3D rotation
            -- rotate around X
            local tilt = sin(self.r_3d) * t1
            local c, s = cos(tilt), sin(tilt)
            y, z = y * c - z * s, y * s + z * c
            -- rotate around Y
            c, s = cos(rot3D), sin(rot3D)
            x, z = x * c - z * s, x * s + z * c

            if float and t2 > 0 then
                -- float tilting
                local dx, dy = MX - self.x, MY - self.y -- Cursor vector
                -- local dx, dy, dz = MX - self.x, MY - self.y, 0 -- Cursor vector
                local dist = (dx * dx + dy * dy) ^ .5
                if dist > 1 then
                    -- local nx, ny, nz = 0, 0, 1 -- Normal vector
                    x, y, z = rotate_point_around_axis(
                        x, y, z,
                        -dy, dx, 0, -- simplified cross product
                        -- ny * dz - nz * dy,
                        -- nz * dx - nx * dz,
                        -- nx * dy - ny * dx,
                        -dist / t2
                    )
                end
            end

            meshVertices[i][1], meshVertices[i][2] = x / (z / f + 1), y / (z / f + 1)
        end
        tempMesh:setVertices(meshVertices)
    else
        -- 2D approach for performance
        gc_push()
        gc_translate(self.x1, self.y1)
        gc_rotate(finalRot - sin(rot3D) * CONF.rot3D_tilt * .0026)
        if self == CD[FloatOnCard] then
            local dx, dy = (MX - self.x1) / (240 * self.size), (MY - self.y1) / (330 * self.size)
            local d = (abs(dx) - abs(dy)) * .026
            gc_scale(math.min(1, 1 - d), math.min(1, 1 + d))
            local D = -sign(dx * dy) * abs(dx * dy) ^ .626 * CONF.rot3D_tilt * .00042
            gc_shear(D, D)
            gc_scale(1 - abs(D))
        end
        gc_scale(cos(rot3D) * finalSize, finalSize)
    end

    -- Glass Card
    if ((GAME.glassCard or GAME.eglassCard) and CONF.classicMode) and not (GAME.einvisCard) then
        local w, h = 240, 330
        gc_setColor((faceUp and ModData.textColor or ModData.color)[self.id])
        gc_setAlpha((CONF.cardBrightness / 100) ^ 2 * .872)
        GC.mRect('fill', 0, 0, w * 2, h * 2, 26)

        if self.burn then
            if URM and M.AS == 2 then
                gc_setColor(1, .42, .26)
            else
                gc_setColor(GAME.time % .16 < .08 and COLOR.lF or COLOR.Y)
            end
        else
            gc_setColor(1, 1, 1)
        end

        FONT.set(50)
        if faceUp then
            GC.scale(2.6)
            GC.mStr(self.id, 0, -42)
            GC.scale(1 / 2.6)
        else
            GC.scale(2)
            GC.mStr("TETR.IO", 0, -42)
            GC.scale(1 / 2)
        end

        gc_setColor(1, 1, 1, .62)
        gc_setLineWidth(4)
        GC.mRect('line', 0, 0, w * 2 - 3, h * 2 - 3, 26)

        -- Outline (draw)
        if a1 then
            gc_setLineWidth(52)
            gc_setColor(r1, g1, b1, a1)
            GC.mRect('line', 0, 0, w * 2 + 52, h * 2 + 52, 52)
        end
        if a2 then
            gc_setLineWidth(26)
            gc_setColor(r2, g2, b2, a2)
            GC.mRect('line', 0, 0, w * 2 + 26, h * 2 + 26, 39)
        end
    else
        -- Hint layer
        if (a1 or a2) and not ((GAME.glassCard or GAME.eglassCard) and not CONF.classicMode) and not GAME.einvisCard then
            if _3D then
                gc_push('all')
                gc_setCanvas(tempCanvas)
                gc_clear()
                gc_origin()
                gc_translate(canvasW / 2, canvasH / 2)
                gc_setBlendMode('alpha', 'premultiplied')
            end

            if a1 then
                gc_setColor(r1, g1, b1, a1)
                gc_draw(activeFrame, -frame1W, -frame1H)
            end
            if a2 then
                gc_setColor(r2, g2, b2, a2)
                gc_draw(activeFrame2, -frame2W, -frame2H)
            end

            if _3D then
                gc_pop()
                gc_draw(tempMesh, self.x1, self.y1, finalRot, finalSize)
            end
        end

        -- Card layer
        if _3D then
            gc_push('all')
            gc_setCanvas(tempCanvas)
            gc_clear()
            gc_origin()
            gc_translate(canvasW / 2, canvasH / 2)
        end

        -- Card
        if not GAME.invisCard and not ((GAME.glassCard or GAME.eglassCard) and CONF.classicMode) then
            if self.burn then
                if URM and M.AS == 2 then
                    gc_setColor(burnColor.uAS)
                else
                    gc_setColor(
                        GAME.time % .16 < .08 and
                        (faceUp and COLOR.LF or COLOR.lF) or
                        (faceUp and COLOR.lY or COLOR.Y)
                    )
                end
            else
                local b = CONF.cardBrightness / 100
                gc_setColor(b, b, b)
            end
            if GAME.einvisCard then
                local b = CONF.cardBrightness / 100
                gc_setColor(b,b,b,(CONF.cardBrightness / 100) ^ 2 * 0.26 + (CONF.classicMode and 0 or 0.4))
            end
            gc_draw(img, -img:getWidth() / 2, -img:getHeight() / 2)
            if img2 then
                gc_draw(img2, -img2:getWidth() / 2, -img2:getHeight() / 2)
            end
        elseif not GAME.invisCard and ((GAME.glassCard or GAME.eglassCard) and CONF.classicMode) then
            local w, h = 240, 330
            gc_setColor((faceUp and ModData.textColor or ModData.color)[self.id])
            gc_setAlpha((CONF.cardBrightness / 100) ^ 2 * .26)
            GC.mRect('fill', 0, 0, w * 2, h * 2, 26)

            if self.burn then
                if URM and M.AS == 2 then
                    gc_setColor(1, .42, .26)
                else
                    gc_setColor(GAME.time % .16 < .08 and COLOR.lF or COLOR.Y)
                end
            else
                gc_setColor(1, 1, 1)
            end

            FONT.set(50)
            if faceUp then
                GC.scale(2.6)
                GC.mStr(self.id, 0, -42)
                GC.scale(1 / 2.6)
            else
                GC.scale(2)
                GC.mStr("TETR.IO", 0, -42)
                GC.scale(1 / 2)
            end
        end

        -- Outline (draw)
        if CONF.oldTransparentCard then
            if GAME.einvisCard then
                gc_setLineWidth(20)
                local temp = M.IN == 1 and 2 or M.IN == 2 and not URM and 3 or M.IN == 2 and URM and 4 or 1
                if self.required then 
                    gc_setColor(ModData.textColor[self.id]) 
                    if M.IN > 0 then
                        gc_setAlpha(1.26/temp + sin(love.timer.getTime() * 5.2/temp)/temp)
                    end
                    if CONF.oldHitbox and MOBILE then
                        gc_circle('fill', 0, 0, 40)
                    end
                else
                    gc_setColor(1,1,1)
                    gc_setAlpha(0.26/temp)
                end
                GC.mRect('line', 0, 0, 240 * 2 + 10, 330 * 2 + 10, 10)
            end
            if a1 then
                gc_setColor(r1, g1, b1, a1)
                gc_draw(activeFrame, 0, 0, 0, sign(self.kx), 1, frame1W, frame1H)
            end
            if a2 then
                gc_setColor(r2, g2, b2, a2)
                gc_draw(activeFrame2, 0, 0, 0, sign(self.kx), 1, frame2W, frame2H)
            end
        else
            if GAME.einvisCard then
                local ultimateChallengeMod = GAME.ultimateChallenge and (1 + (M.DP == 0 and ((GAME.startingHealth-GAME.life)/GAME.startingHealth * 2) or ((GAME.startingHealth*2-(GAME.life+GAME.life2))/GAME.startingHealth))) or 1
                local temp = M.IN == 1 and 2 or M.IN == 2 and not URM and 3 or M.IN == 2 and URM and 4 or 1
                local width = 40
                local hand = TABLE.sort(GAME.getHand(false))
                local stackQuest = GAME.questStack[1] and TABLE.sort(GAME.questStack[1].combo)
                local q1 = GAME.quests[1] and TABLE.sort(GAME.quests[1].combo)
                local q2 = M.DP ~= 0 and GAME.quests[2] and TABLE.sort(GAME.quests[2].combo)
                local q3 = M.DP == -1 and GAME.quests[3] and TABLE.sort(GAME.quests[3].combo)
                if self.required then 
                    gc_setColor(ModData.textColor[self.id]) 
                    if not self.active then
                        gc_setAlpha((1.26 * ultimateChallengeMod)/temp + sin(love.timer.getTime() * 5.2/temp)/temp)
                        width = (9-temp)*5
                    end
                    if self.active and GAME.playing then
                        if (stackQuest and TABLE.equal(hand, stackQuest)) or (not stackQuest and q1 and TABLE.equal(hand, q1)) then
                            gc_setColor(0.26,1,0)
                        else
                            gc_setColor(1,1,0)
                        end
                        gc_setAlpha(min(1, 2/temp))
                        width = (9-temp)*5
                    end
                    if CONF.oldHitbox and MOBILE then
                        GC.circle('fill', 0, 0, 40)
                    end
                    gc_setLineWidth(width)
                    GC.mRect('line', 0, 0, 240 * 2 + width/2, 330 * 2 + width/2, width)
                elseif not self.required and self.active and GAME.playing and not ((q2 and TABLE.equal(hand, q2)) or (q3 and TABLE.equal(hand, q3))) then               
                    gc_setColor(1,0,0)
                    gc_setAlpha(min(1, 2/temp))
                    width = (9-temp)*5
                    gc_setLineWidth(width)
                    GC.mRect('line', 0, 0, 240 * 2 + width/2, 330 * 2 + width/2, width)
                end
                if self.required2 then
                    gc_setColor(1, 0.62, 0.9) 
                    if not self.active then
                        gc_setAlpha(1.26/temp + sin(love.timer.getTime() * 5.2/temp)/(2*temp))
                    end
                    if self.active and GAME.playing then
                        if (q2 and TABLE.equal(hand, q2)) or (M.DP == -1 and GAME[GAME.getLifeKey(true)] > 0 and M.NH < 2 and q3 and q1 and TABLE.equal(hand, q3) and TABLE.equal(hand, q1)) then
                            gc_setColor(0.13,1,0)
                        else
                            gc_setColor(1,1,0)
                        end
                        gc_setAlpha(min(1, 3/temp))
                    elseif GAME.playing and (M.DP == -1 and GAME[GAME.getLifeKey(true)] > 0 and M.NH < 2 and q3 and q1 and TABLE.equal(hand, q3) and TABLE.equal(hand, q1)) then
                        gc_setColor(0.13,1,0)
                    end
                    gc_setLineWidth(width/2)
                    GC.mRect('line', 0, 0, 240 * 2 - width-2, 330 * 2 - width-2, width/2-2)
                end
                if q3 and TABLE.find(q3, self.id) and self.active and GAME.playing then
                    if (q3 and TABLE.equal(hand, q3)) then
                        gc_setColor(0, 1, 0)
                    else
                        gc_setColor(1, 1, 0)
                    end
                    gc_setAlpha(min(1, 2/temp))
                    gc_setLineWidth(width/2)
                    GC.mRect('line', 0, 0, 240 * 2 - width*2-4, 330 * 2 - width*2-4, width/2-4)
                end
            end
            if a1 and not (GAME.einvisCard and GAME.playing) and (M.IN == -1 or not (GAME.glassCard and not CONF.classicMode)) then
                gc_setColor(r1, g1, b1, a1)
                gc_draw(activeFrame, 0, 0, 0, 1, 1, frame1W, frame1H)
            end
            if a2 and not (GAME.einvisCard and GAME.playing) and (M.IN == -1 or not (GAME.glassCard and not CONF.classicMode)) then
                gc_setColor(r2, g2, b2, a2)
                gc_draw(activeFrame2, 0, 0, 0, 1, 1, frame2W, frame2H)
            end
        end
    end

    -- Rev Throb
    if not playing and not self.upright and GAME.revDeckSkin and faceUp and not ((GAME.glassCard or GAME.eglassCard) and CONF.classicMode) then
        gc_setColor(1, 1, 1, ThrobAlpha.card)
        gc_setShader(SHADER.throb)
        gc_draw(img, -img:getWidth() / 2, -img:getHeight() / 2)
        gc_setShader()
    end

    -- Star
    if not playing and completion[self.id] > 0 then
        img = TEXTURE[self.active and (self.id == 'DP' and STAT.clicker and 'star2' or 'star1') or 'star0']
        local t = (self.upright or self.easy) and self.float or 1
        local glowAlpha = (FloatOnCard == self.initOrder or not self.upright) and 1 or .62
        local x = lerp(155, 0, t)
        local y = lerp(-370, -330, t)
        local cr = lerp(60, 180, t)
        local revMastery = completion[self.id] == 2
        local ang = -t * 6.2832
        -- Base star
        if self.upright or self.easy then
            gc_setColor(.26, .26, .26, glowAlpha)
            gc_setBlendMode('add')
            gc_glowCircle(1, x, y, cr)
            if revMastery then gc_glowCircle(1, -x, -y, cr) end
            gc_setBlendMode('alpha')
            gc_setColor(1, 1, 1)
            gc_mDraw(img, x, y, ang, lerp(.16, .42, t))
            if revMastery then gc_mDraw(img, -x, -y, ang, lerp(.16, .42, t)) end
        else
            gc_setColor(.6, .1, .1, glowAlpha)
            gc_setBlendMode('add')
            gc_glowCircle(1, x, y, cr)
            if revMastery then gc_glowCircle(1, -x, -y, cr) end
            gc_setBlendMode('alpha')
            gc_setColor(1, .62 + .1 * sin(getTime() * 42), .26)
            gc_mDraw(img, x, y, ang, lerp(.16, .42, t))
            if revMastery then gc_mDraw(img, -x, -y, ang, lerp(.16, .42, t)) end
        end
        -- Float star
        if not self.active then
            if revMastery then
                gc_setColor(.5, .5, .5, t)
                gc_setBlendMode('add')
                gc_glowCircle(1, -x, -y, cr)
                gc_setBlendMode('alpha')
            end
            gc_setColor(1, 1, 1, t)
            local star1 = TEXTURE[self.id == 'DP' and STAT.clicker and 'star2' or 'star1']
            gc_mDraw(star1, x, y, ang, lerp(.16, .42, t))
            if revMastery then gc_mDraw(star1, -x, -y, ang, lerp(.16, .42, t)) end
        end
    end

    -- Icon cover
    if faceUp then
        gc_setColor((((GAME.glassCard or GAME.eglassCard) and CONF.classicMode) and ModData.color or ModData.textColor)[self.id])
        local active = playing and self.inLastCommit or not playing and self.active
        if M.EX <= 0 then
            if active then
                gc_setLineWidth(6)
                gc_polygon('line', iconFrame)
                gc_setAlpha(.62)
                gc_polygon('fill', iconFrame)
            else
                gc_setLineWidth(4)
                gc_polygon('line', iconFrame)
            end
        elseif active then
            gc_setAlpha(.62)
            gc_polygon('fill', iconFrame)
        end
    end

    gc_pop()
    if _3D then
        gc_draw(tempMesh, self.x1, self.y1, finalRot, finalSize)
    end
end

return Card
