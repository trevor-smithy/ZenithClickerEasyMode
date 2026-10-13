---@type Zenitha.Scene
local scene = {}

local initialized = false
local t1, t2

function scene.load()
    t1, t2 = .26, .42
    love.keyboard.setKeyRepeat(false)
    TEXTS.load:set(SCN.args[1] and "Welcome Back." or "JOINING ROOM...")
end

scene.keyDown = TRUE

function scene.update(dt)
    dt = math.min(dt, 1 / 26)
    if TASK.lock('init') then
    elseif t1 > 0 then
        t1 = t1 - dt
        if t1 <= 0 then
            if SCN.args[1] then
                GAME.bgH, GAME.height = 0, 0
                GAME.prevPB = -2600
                GAME.finishTera = false
                for i = #GAME.koAnim, 1, -1 do
                    local k = GAME.koAnim[i]
                    k.a, k.timer = -1, -1
                end
                for k in next, GAME.completion do
                    GAME.completion[k] = 0
                    GAME.mod[k] = 0
                    if Cards[k].active then
                        Cards[k]:setActive(true)
                    end
                end
                for i = 1, #PieceData - 1 do
                    GAME[PieceData[i].id] = false
                end
                InitProfile()
                LoadSave()
                URM = false
                GAME.pieceEffectID = 0
                GAME.floor = 0
                STAT.srActive = SCN.args[1] == 'reset'
                Initialize(true)
                GAME.clearResultStat()
                collectgarbage()
            end
            if not initialized then
                BGM.setMaxSources(42)
                BGM.load(FILE.isSafe('data/bgm.lua') and FILE.safeLoad('data/bgm.lua', '-luaon') or {})
                SFX.load('assets/sfx.ogg', FILE.isSafe('data/sfx.lua') and FILE.safeLoad('data/sfx.lua', '-luaon') or {})
                for i = 1, 9 do
                    SFX.load('garbagewindup_'..i, 'assets/windup_'..i..'.ogg')
                end
                SFX.load('assets/card_tone_easy.ogg', 
                    {
                        card_tone_expert_easy = { 0, 1.12 },
                        card_tone_nohold_easy = { 1.12, 1.13 },
                        card_tone_messy_easy = { 2.24, 1.13 },
                        card_tone_gravity_easy = { 3.37, 1.12 },
                        card_tone_volatile_easy = { 4.49, 1.13 },
                        card_tone_doublehole_easy = { 5.62, 1.12 },
                        card_tone_invisible_easy = { 6.74, 1.13 },
                        card_tone_allspin_easy = { 7.87, 1.13 },
                        card_tone_duo_easy = { 9, 1 },
                    }
                )
                SFX.load('assets/card_tone_easy_voice.ogg', 
                    {
                        card_tone_expert_easy_voice = { 0, 0.85 },
                        card_tone_nohold_easy_voice = { 0.85, 0.65 },
                        card_tone_messy_easy_voice = { 1.5, 0.75 },
                        card_tone_gravity_easy_voice = { 2.25, 0.75 },
                        card_tone_volatile_easy_voice = { 3, 0.75 },
                        card_tone_doublehole_easy_voice = { 3.75, 0.75 },
                        card_tone_invisible_easy_voice = { 4.5, 0.75 },
                        card_tone_allspin_easy_voice = { 5.25, 0.75 },
                        card_tone_duo_easy_voice = { 6, 0.63 },
                    }
                )
                TASK.new(Daemon_Slow)
                TASK.new(Daemon_Fast)
                TASK.new(function()
                    TASK.yieldT(2.6)
                    CurlRequest('checkUpdate')
                end)
                TEXTS.load:set("GETTING READY TO SPECTATE...")

                ---@diagnostic disable-next-line
                local _, _, _, _ = TEXTURE.panel.glass_a, TEXTURE.panel.glass_b, TEXTURE.panel.throb_a, TEXTURE.panel.throb_b
                for i = 2, 9 do TEXTURE.towerBG[i]:setWrap('mirroredrepeat', 'mirroredrepeat') end
                TEXTURE.towerBG[1]:setWrap('mirroredrepeat', 'clampzero')
                TEXTURE.towerBG[10]:setWrap('mirroredrepeat', 'clampzero')
                _, _ = TEXTURE.moon, TEXTURE.stars
                initialized = true
            end
        end
    elseif t2 > 0 then
        t2 = t2 - dt
        if t2 <= 0 then
            PlayBGM('f0')
            SCN.swapTo('tower')
        end
    end
end

function scene.draw()
    GC.setColor(.2, .2, .2)
    GC.strokeDraw('full', 5, TEXTS.load, 800, 500, 0, 1.6, 2, TEXTS.load:getWidth() / 2, TEXTS.load:getHeight() / 2)
    GC.setColor(.4, .4, .4)
    GC.strokeDraw('full', 3, TEXTS.load, 800, 500, 0, 1.6, 2, TEXTS.load:getWidth() / 2, TEXTS.load:getHeight() / 2)
    GC.setColor(.6, .6, .6)
    GC.strokeDraw('full', 1, TEXTS.load, 800, 500, 0, 1.6, 2, TEXTS.load:getWidth() / 2, TEXTS.load:getHeight() / 2)
    GC.setColor(.9, .9, .9)
    GC.mDraw(TEXTS.load, 800, 500, 0, 1.6, 2)
end

return scene
