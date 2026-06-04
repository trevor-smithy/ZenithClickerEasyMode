---@type Zenitha.Scene
local scene = {}


-- 1. Video & Audio
-- 2. Utils
-- 3. Album
-- 4. ZCEM
local page = 1
local maxPage = 4
local uidList = {} ---@type ({uid: string, modTime?: string} | false)[]

local anonUser
local resetall_cnt, resetall_anim, lastClear

local clr = {
    D = { COLOR.HEX '191E31FF' },
    L = { COLOR.HEX '4D67A6FF' },
    T = { COLOR.HEX '6F82ACFF' },
    LT = { COLOR.HEX 'B0CCEBFF' },
    cbFill = { COLOR.HEX '0B0E17FF' },
    cbFrame = { COLOR.HEX '6A82A7FF' },
}
local colorRev = false
local bindBuffer
local playingBgmTitle = 'Philosophyz'
local playingBgmLength = 2202.8
local playingBgmLengthStr = '22:02.8'
local songList = {
    f0 = "Dr Ocelot - Watchful Eye",
    f1 = "Dr Ocelot - Divine Registration",
    f2 = "Dr Ocelot - Zenith Hotel",
    f3 = "Dr Ocelot - Empty Prayers",
    f4 = "Dr Ocelot - Crowd Control",
    f5 = "Dr Ocelot - Phantom Memories",
    f6 = "Dr Ocelot - Echo",
    f7 = "Dr Ocelot - Cryptic Chemistry",
    f8 = "Dr Ocelot - Chrono Flux",
    f9 = "Dr Ocelot - Broken Record",
    f10 = "petrtech - Deified Validation",
    tera = "Dr Ocelot - Schnellfeuer BULLET",

    f0r = "Dr Ocelot - Awaiting Judgement",
    f1r = "Dr Ocelot - Desecrated Ruins",
    f2r = "Dr Ocelot - The Age of Vanity",
    f3r = "Dr Ocelot - A Rigged Game",
    f4r = "Dr Ocelot - Spectacles of Violence",
    f5r = "Dr Ocelot - The Past Repeats",
    f6r = "Dr Ocelot - Damning Evidence",
    f7r = "Dr Ocelot - Cryptic Heresy",
    f8r = "Dr Ocelot - Futile Ambition",
    f9r = "Dr Ocelot - Mere Sacrifices",
    f10r = "petrtech - Pseudo-Apotheosis",
    terar = "Dr Ocelot - Kugelhagel OVERDRIVE",

    terae = "Trevor Smithy - Schnellfeuer BULLET Vocal Cover",
    teral = "Trevor Smithy - Schnellfeuer BULLET Lyric Cover",
    terael = "Trevor Smithy - Schnellfeuer BULLET Vocal & Lyric Cover",
    fomg = "Ronezkj15 - Strained Endurance",
    f0_EX = "Dr Ocelot - Watchful Eye (EX)",
    f0r_EX = "Dr Ocelot - Awaiting Judgement (EX)",
    f1_EX = "Dr Ocelot - Infernal Registration",
    f1r_EX = "Dr Ocelot - Desecrated Ruins (EX)",
}
local bgmColors = {
    f1 = { COLOR.HEX 'E46A24' },
    f2 = { COLOR.HEX 'F1CC80' },
    f3 = { COLOR.HEX '804200' },
    f4 = { COLOR.HEX '8E1D1D' },
    f5 = { COLOR.HEX 'B8C1C1' },
    f6 = { COLOR.HEX 'EAA380' },
    f7 = { COLOR.HEX '70B5E1' },
    f8 = { COLOR.HEX 'F16A77' },
    f9 = { COLOR.HEX '3DA878' },
    f10 = { COLOR.HEX 'AD80F5' },
    f1r = { COLOR.HEX 'E46A24' },
    f2r = { COLOR.HEX 'F1CC80' },
    f3r = { COLOR.HEX '804200' },
    f4r = { COLOR.HEX '8E1D1D' },
    f5r = { COLOR.HEX 'B8C1C1' },
    f6r = { COLOR.HEX 'EAA380' },
    f7r = { COLOR.HEX '70B5E1' },
    f8r = { COLOR.HEX 'F16A77' },
    f9r = { COLOR.HEX '3DA878' },
    f10r = { COLOR.HEX 'AD80F5' },

    f0 = { COLOR.HEX '8C2B15' },
    f0r = { COLOR.HEX '8C2B15' },
    tera = { COLOR.HEX 'C0C0C0' },
    terar = { COLOR.HEX 'C0C0C0' },
    terae = { COLOR.HEX 'C0C0C0' },
    teral = { COLOR.HEX 'C0C0C0' },
    terael = { COLOR.HEX 'C0C0C0' },
    fomg = { COLOR.HEX '00437A' },
}
local bgmHeight = {
    [0] = Floors[0].top,
    Floors[0].top,
    Floors[1].top,
    Floors[2].top,
    Floors[3].top,
    Floors[4].top,
    Floors[5].top,
    Floors[6].top,
    Floors[7].top,
    Floors[8].top,
    Floors[9].top + 10,
    Floors[9].top + 26, -- special
}

-- ZCEM Trevor Smithy
local ZCEMclr = {
    D = COLOR.DG,
    L = { .15, .75, .15 },
    T = { COLOR.HEX '6FAC82FF' },
    LT = { COLOR.HEX 'B0EBCCFF' },
    cbFill = { COLOR.HEX '0B0E17FF' },
    cbFrame = { COLOR.HEX '6A82A7FF' },
}
local bpmMode = false
local comboTimer = 0
local combo = 0
local leftx, rightx, leftbx, rightbx = 40, 500, 220, 685
-- Panel size
local w, h = 900, 830
local baseX, baseY = 800 - w / 2, 500 - h / 2 + 10

local descriptionIndex = 0
local descriptionTable = {
    [0] = "Press to cycle through options' descriptions.",
    "GAME PLAY: Press to switch to the ALBUM. Also switches to BPM mode.",
    "SPEED: Press to switch to BPM. Shows timer speed, affected by Z/eS/eI.",
    "Promotion Gauge: A colored indicator of maximum XP if surge is broken.", 
    "Stacker Mode: Commit NOTHING to add to the stack, clear for big burst!",
    "Old Transparent Card: Old version of eO. Worse with DP, but no ZP nerf.",
    "Old Hitbox: Hitboxes are based on center of cards instead of visible area.",
    "Use Easy Names: Mods use their Easy variants in-game, even with rDH!",
    "Imperial Units: Feet and Miles used instead of Meters. No records allowed!"
}
local pieceDescriptionTable = {
    [0] = "Press to cycle through options' descriptions.",
    "eZ: Passive climb speed x2, Gravity Timer x2, normal damage/fatigue timer.",
    "eS: Damage, fatigue, gravity timers and XP loss x0.75, normal climb speed.",
    "eJ: Attack x0.5, passive climb speed x8 (x4.8 with rEX or uEX)",
    "eL: XP lock increased by 5 seconds, XP leak speed x0.375",
    "eT: 20% UI element opacity, stuck in Floor 1 (easier quests, timers, etc.)",
    "eO: 26% card opacity, adds a colored outline if card is required.",
    "eI: Assist Mode, stronger the closer cards are (excluding Close Card).",
    "Ultra Reverse: Upgrades Reversed mods to Ultra Reversed, or Easy to Uneasy."
}
local startHour = os.date('%H')
local startMin = os.date('%M')
local startSec = os.date('%S')

local function refreshWidgets()
    for _, W in next, scene.widgetList do 
        W:setVisible() 
        local tabs = {'back', 'conf', 'utils', 'album', 'zcem'}
        local zcem = {'gameplay', 'bpm', 'promotion', 'imperial', 'oldTransparentCard', 'oldHitbox', 'easyName', 'stacker', 'pieces', 'ez', 'es', 'ej', 'el', 'et', 'eo', 'ei', 'urm', 'clear', 'help2'}
        if not TABLE.find(tabs, W.name) and TABLE.find(zcem, W.name) then
            if GAME.ecloseCard then
                if W.x < 700 then
                    if W.type == "checkBox" then
                        W.x = baseX + leftx + 20
                    elseif W.type == "button" then
                        W.x = baseX + leftbx + 20
                    else
                        W.x = baseX + 20 + 20
                    end
                else
                    if W.type == "checkBox" then
                        W.x = baseX + rightx - 20
                    elseif W.type == "button" then
                        W.x = baseX + rightbx - 20
                    end
                end
                W:resetPos()
            else
                if W.x < 700 then
                    if W.type == "checkBox" then
                        W.x = baseX + leftx
                    elseif W.type == "button" then
                        W.x = baseX + leftbx
                    else
                        W.x = baseX + 20
                    end
                else
                    if W.type == "checkBox" then
                        W.x = baseX + rightx
                    elseif W.type == "button" then
                        W.x = baseX + rightbx
                    end
                end
                W:resetPos()
            end
            if GAME.eglassCard and TABLE.find(zcem, W.name) then
                if W.name and #W.name > 2 and W.type ~= "button" and W.type ~= "hint" and W.name ~= "urm" then
                    W.textColor = COLOR.L
                end
            else
                if W.name and #W.name > 2 and W.type ~= "button" and W.type ~= "hint" and W.name ~= "urm" and TABLE.find(zcem, W.name) then
                    W.textColor = page == 4 and ZCEMclr.T or clr.T
                end
            end
        end
    end
    if SongNamePlaying == 'teral' or SongNamePlaying == 'terael' then
        scene.widgetList.loops:setVisible(false)
    end
end

local function timePast(t1, t2)
    if not t1 then return "unknown" end
    local diff = math.abs(t2 - t1)
    local unit
    if diff < 60 then
        return "just now"
    elseif diff < 3600 then
        diff = math.floor(diff / 60)
        unit = 'm'
    elseif diff < 86400 then
        diff = math.floor(diff / 3600)
        unit = 'h'
    elseif diff < 2592000 then
        diff = math.floor(diff / 86400)
        unit = 'd'
    elseif diff < 31536000 then
        diff = math.floor(diff / 2592000)
        unit = 'mo'
    else
        diff = math.floor(diff / 31536000)
        unit = 'y'
    end
    return diff .. unit .. (t2 > t1 and " ago" or " from future")
end
local function refreshUID()
    anonUser = STAT.uid:sub(1, 5) == 'ANON-'
    TABLE.clear(uidList)
    uidList[0] = { uid = "Active Profile:   " .. STAT.uid, modTime = "just now" }
    for i = 1, 3 do
        if FILE.exist('save' .. i) then
            local dat = FILE.load('save' .. i .. "/stat.luaon")
            uidList[i] = { uid = dat.uid, modTime = timePast(dat.modTime, os.time()) }
        else
            uidList[i] = false
        end
    end
end

local sp = { f0 = 1, f1 = 1, f0r = 1, f1r = 1 }
local function refreshSongInfo()
    if sp[SongNamePlaying] then
        playingBgmTitle = songList[SongNamePlaying .. (GAME.mod.EX > 0 and '_EX' or '')]
    else
        playingBgmTitle = songList[SongNamePlaying] or "Rewrite"
    end
    playingBgmLength = BGM.getDuration()
    playingBgmLengthStr = STRING.time_simp(playingBgmLength)
    GAME.refreshRPC()
end

-- ZCEM Trevor Smithy
local function anyPieceActive()
    return GAME.nightcore or GAME.enightcore or GAME.slowmo or GAME.eslowmo or GAME.glassCard or GAME.eglassCard or GAME.fastLeak or GAME.efastLeak or GAME.invisUI or GAME.einvisUI or GAME.invisCard or GAME.einvisCard or GAME.closeCard or GAME.ecloseCard
end

local function countPiecesActive()
    return (GAME.nightcore and 1 or 0) + (GAME.enightcore and 1 or 0) + (GAME.slowmo and 1 or 0) + (GAME.eslowmo and 1 or 0) + (GAME.glassCard and 1 or 0) + (GAME.eglassCard and 1 or 0) + (GAME.fastLeak and 1 or 0) + (GAME.efastLeak and 1 or 0) + (GAME.invisUI and 1 or 0) + (GAME.einvisUI and 1 or 0) + (GAME.invisCard and 1 or 0) + (GAME.einvisCard and 1 or 0) + (GAME.closeCard and 1 or 0) + (GAME.ecloseCard and 1 or 0)
end

function scene.load()
    MSG.clear()
    bindBuffer = nil
    resetall_cnt, resetall_anim, lastClear = 0, 0, false
    SetMouseVisible(true)
    if GAME.anyRev ~= colorRev then
        colorRev = GAME.anyRev
        for _, C in next, clr do
            C[1], C[3] = C[3], C[1]
        end
        for _, C in next, ZCEMclr do
            C[1], C[3] = C[3], C[1]
        end
    end
    TASK.unlock('changeName')
    TASK.unlock('changeAboutme')
    TASK.unlock('export')
    TASK.unlock('import')
    TASK.unlock('rebind_control')
    TASK.unlock('just_saved')
    if STAT.stacker and STAT.promotion then
        MSG("achv_badTime", "WARNING: PROMOTION and STACKER are MUTUALLY EXCLUSIVE!\nDISABLE ONE NOW OR IT WILL BE DONE AUTOMATICALLY!")
        SFX.play('hyperalert')
    end
    refreshWidgets()
    GAME.refreshCurrentCombo()
    refreshSongInfo()
    refreshUID()
end

function scene.unload()
    GAME.refreshCurrentCombo()
end

local bindHint = {
    "CARD-1",
    "CARD-2",
    "CARD-3",
    "CARD-4",
    "CARD-5",
    "CARD-6",
    "CARD-7",
    "CARD-8",
    "CARD-9",
    "CARD-1 (2nd)",
    "CARD-2 (2nd)",
    "CARD-3 (2nd)",
    "CARD-4 (2nd)",
    "CARD-5 (2nd)",
    "CARD-6 (2nd)",
    "CARD-7 (2nd)",
    "CARD-8 (2nd)",
    "CARD-9 (2nd)",
    "COMMIT",
    "RESET",
    "LEFTCLK",
    "RIGHTCLK",
}

local KBisDown = love.keyboard.isDown
local function isLegalKey(key)
    if key:find('ctrl') or key:find('alt') or key == 'f1' or key == 'f2' or key == 'tab' or key == '`' then
        SFX.play('finessefault', .626)
        return false
    elseif key:match('^f%d%d?$') then
        return false
    else
        return true
    end
end
function scene.keyDown(key, isRep)
    if isRep then return true end
    if bindBuffer then
        if key == 'escape' then
            bindBuffer = nil
            MSG('dark', "Keybinding cancelled")
            SFX.play('staffwarning')
        elseif isLegalKey(key) then
            if TABLE.find(bindBuffer, key) then
                MSG('dark', "Keybinding should not repeat!", 1)
                SFX.play('finessefault')
            else
                table.insert(bindBuffer, key)
                if #bindBuffer >= 22 then
                    CONF.keybind = bindBuffer
                    bindBuffer = nil
                    SaveStat()
                    MSG('dark', "Keybinding updated.")
                    SFX.play('social_notify_major')
                else
                    SFX.play('irs')
                end
            end
        end
    else
        if key == 'escape' or key == 'f1' then
            SaveConf()
            SFX.play('menuclick')
            SCN.back('none')
            GAME.refreshCurrentCombo()
        elseif MATH.between(tonumber(key) or 0, 1, maxPage) then
            local p = tonumber(key)
            if p and p ~= page then
                page = p
                SFX.play('menuclick')
                refreshWidgets()
            end
        elseif page == 3 then
            if key == 'left' then
                TASK.removeTask_code(Task_MusicEnd)
                BGM.set('all', 'seek', math.max(BGM.tell() - (KBisDown('lctrl', 'rctrl') and 26 or 5), 0))
            elseif key == 'right' then
                TASK.removeTask_code(Task_MusicEnd)
                BGM.set('all', 'seek', math.min(BGM.tell() + (KBisDown('lctrl', 'rctrl') and 26 or 5), BGM.getDuration()))
            elseif key == 'home' then
                TASK.removeTask_code(Task_MusicEnd)
                BGM.set('all', 'seek', 0)
            elseif key == 'end' then
                TASK.new(Task_MusicEnd, true)
            elseif key == 'space' then
                BgmLooping, BgmNeedSkip = false, false
            end
            return true
        end
    end
    ZENITHA._cursor.active = true
    return true
end

scene.resize = refreshWidgets

local gc = love.graphics
local gc_replaceTransform = gc.replaceTransform
local gc_draw, gc_setColor, gc_rectangle = gc.draw, gc.setColor, gc.rectangle
local gc_print, gc_printf = gc.print, gc.printf
local gc_ucs_move, gc_ucs_back = GC.ucs_move, GC.ucs_back
local gc_setAlpha, gc_mRect, gc_mStr = GC.setAlpha, GC.mRect, GC.mStr
local gc_line, gc_circle, gc_rotate, gc_setLineWidth = gc.line, gc.circle, gc.rotate, gc.setLineWidth
local sin, cos = math.sin, math.cos

local function drawSliderComponents(y, title, t1, t2, value)
    gc_ucs_move(0, y)
    gc_setColor(0, 0, 0, .26)
    gc_mRect('fill', w / 2, 0, w - 40, 65, 5)
    gc_mRect('fill', w - 90, 0, 123, 48, 3)
    FONT.set(30)
    gc_setColor(clr.T)
    gc_print(title, 40, -20, 0, .85, 1)
    gc_setAlpha(.42)
    gc_print(t1, 326, 5, 0, .5)
    gc_printf(t2, w - 355, 5, 355, 'right', 0, .5)
    gc_setColor(clr.T)
    gc_mStr(value, w - 100, -20)
    gc_setColor(clr.L)
    gc_print("%", w - 60, -20, 0, .85, 1)
    gc_ucs_back()
end

local playing
function scene.update(dt)
    if SongNamePlaying ~= playing then
        refreshSongInfo()
        refreshWidgets()
        playing = SongNamePlaying
    end
    if page == 3 and (BgmPlaying == 'tera' or BgmPlaying == 'terar' or BgmPlaying == 'terae' or BgmPlaying == 'teral' or BgmPlaying == 'terael') then
        GAME.height = GAME.height + dt * (BgmPlaying == 'tera' and 20 or BgmPlaying == 'terae' and 78 or BgmPlaying == 'teral' and 7 or BgmPlaying == 'terael' and 26 or 42) * (GAME.height >= 1650 and .2 or 1)
        if GAME.height >= 1726 and (BgmPlaying ~= 'terae' or BgmPlaying == 'terael') or GAME.height >= 6200 then GAME.bgH, GAME.height = -30, -30 end
        dt = dt * 2.6
    end
    GAME.bgH = MATH.expApproach(GAME.bgH, GAME.height, dt * 1.6)
    StarPS:moveTo(0, -GAME.bgH * 2 * BgScale)
    StarPS:update(dt)
    if not TASK.getLock('reset_all') then resetall_cnt = 0 end
    resetall_anim = MATH.expApproach(resetall_anim, resetall_cnt / 16, dt * 12)
    comboTimer = comboTimer - dt
    if comboTimer <= 0 then
        combo = 0
    end
end

function scene.draw()
    DrawBG(CONF.bgBrightness)

    local t = love.timer.getTime()
    local playTime = 0
    local beatLen = 0
    local beatBar = 0
    if bpmMode then
        playTime = BGM.tell()
        beatLen = 60 / BgmData[BgmPlaying].bpm
        beatBar = BgmData[BgmPlaying].bar
    end

    -- ClockEffect
    local gravityMod = {[-1] = -6, [0] = 1, 1, 2, 3}
    local gv = GAME.mod.GV + (GAME.mod.GV == 2 and URM and 1 or 0)
    local clockMod = 9.57
    if GAME.enightcore or GAME.eslowmo then
        gc_replaceTransform(SCR.xOy_m)
        gc_rotate(-1.5708)
        gc_setLineWidth(42)
        local a = love.timer.getTime()
        -- goal is for all hands to complete a revolution at *gravityMod* rate
        local h = a*gravityMod[gv]/(3600*clockMod) + startHour/6 * 3.1416
        local m = a*gravityMod[gv]/(60*clockMod) + startMin/30 * 3.1416
        local s = a*gravityMod[gv]/clockMod + startSec/30 * 3.1416
        local o = a*gravityMod[gv]*(184/4)/clockMod -- 184 rotations per minute
        local x = a*gravityMod[gv]*(240/4)/clockMod -- 240 rotations per minute
        if GAME.enightcore then
            gc_setColor(1, 1, 1, GAME.playing and .1 or .26)
            gc_circle('line', 0, 0, 620)
            gc_setColor(1, 1, 1, GAME.playing and .26 or .42)
            gc_setLineWidth(26)
            gc_line(0, 0, 120 * cos(h), 120 * sin(h))
            gc_setLineWidth(16)
            gc_line(0, 0, 260 * cos(m), 260 * sin(m))
            gc_setLineWidth(10)
            gc_line(0, 0, 420 * cos(s), 420 * sin(s))
            gc_line(0, 0, 520 * cos(o), 520 * sin(o))
            gc_line(0, 0, 600 * cos(x), 600 * sin(x))
        else
            gc_setColor(1, 1, 1, GAME.playing and .1 or .26)
            gc_circle('line', 0, 0, 620)
            gc_setColor(1, 1, 1, GAME.playing and .26 or .42)
            gc_setLineWidth(26)
            gc_line(0, 0, 120 * cos(h), 120 * sin(h))
            gc_setLineWidth(16)
            gc_line(0, 0, 260 * cos(m), 260 * sin(m))
            gc_setLineWidth(10)
            gc_line(0, 0, 420 * cos(s), 420 * sin(s))
        end
    end

    -- Panel
    gc_replaceTransform(SCR.xOy)
    gc.translate(baseX, baseY)
    if bpmMode and (page == 3 or page == 4) then
        local dy = MATH.clamp(6 * math.sin(playTime / beatLen * 3.1416), -2.6, 2.6)
        gc.translate(0, dy)
        SCN.curScroll = -dy
    end
    gc_setColor(page == 4 and ZCEMclr.D or clr.D)
    if GAME.eglassCard then
        local speedMod = ((GAME.enightcore or GAME.nightcore) and 2 or 1) * (GAME.eslowmo and 0.75 or 1) * (GAME.slowmo and 0.5 or 1)
        gc_setColor(bgmColors[BgmPlaying] or clr.LT)
        if BgmPlaying == 'tera' or BgmPlaying == 'terar' or BgmPlaying == 'terae' or BgmPlaying == 'teral' or BgmPlaying == 'terael' then
            gc_setColor(COLOR.rainbow_dark(2.6 * t * speedMod))
        end
    end
    gc_setAlpha(GAME.einvisCard and 0.626 or 1)
    gc_rectangle('fill', 0, 0, w, h)
    gc_setColor(0, 0, 0, .26)
    gc_rectangle('fill', 3, 3, w - 6, h - 6)
    gc_setColor(1, 1, 1, .1)
    gc_rectangle('fill', 0, 0, w, 3)
    gc_setColor(1, 1, 1, .04)
    gc_rectangle('fill', 0, 3, 3, h + 3)

    if GAME.efastLeak then
        gc_setAlpha(1)
        gc_replaceTransform(SCR.origin)
        gc_setColor(0, .42, 1, (GAME.mod.EX > 0 and .62 or .42))
        gc_draw(TEXTURE.transition, 0, 0, 0, .42 / 128 * SCR.w, SCR.h)
        gc_draw(TEXTURE.transition, SCR.w, 0, 0, -.42 / 128 * SCR.w, SCR.h)
        gc_replaceTransform(SCR.xOy)
        gc.translate(baseX, baseY)
    end

    if page == 1 then
        -- Sliders
        drawSliderComponents(120, "EFFECT VOLUME", "QUIET (F3)", "LOUD (F3)", CONF.sfx)
        drawSliderComponents(200, "MUSIC VOLUME", "QUIET (F4)", "LOUD (F4)", CONF.bgm)
        drawSliderComponents(430, "CARD  BRIGHTNESS", "DARK (F5)", "BRIGHT (F6)", CONF.cardBrightness)
        drawSliderComponents(510, "BG  BRIGHTNESS", "DARK (F7)", "BRIGHT (F8)", CONF.bgBrightness)

        -- Keybind
        if bindBuffer then
            FONT.set(30)
            gc_print("Press key for...", 600, 670, 0, .872)
            gc_print(bindHint[#bindBuffer + 1], 600, 700, 0, .872)
        end
    elseif page == 2 then
        if resetall_anim > .1 then
            local t2 = MATH.iLerp(.1, 1, resetall_anim)
            gc_setColor(1, 1, 1, t2 * .42)
            GC.mDraw(TEXTURE.warning, w / 2, h / 2, 0, MATH.lerp(1, 2.6, t2) ^ 2.6)
            GC.setLineWidth(2)
            gc_setColor(1, t % .16 < .08 and 0 or 1, 0, resetall_anim * 2)
            gc_mRect('line', 450, 420, 520, 140, 20)
        end
        gc_setColor((anonUser and -t or TASK.getLock('just_saved') or 0) % .5, 0, 0, .26)
        gc_mRect('fill', 450, 420, 520, 140, 20)
        gc_setColor(1, t % .16 < .08 and .2 + resetall_anim * .6 or .2, .2, resetall_anim ^ .26 * .26)
        gc_mRect('fill', 450, 420, 520 * resetall_anim, 140, 20)
        gc_setColor(1, 1, 1, .1)
        FONT.set(50)
        gc_print("0", 200, 345)
        FONT.set(30)
        gc_setColor(clr.LT)
        gc_mStr(uidList[0].uid, 450, 360)
        for i = 1, 3 do
            local y = 220 + 330 + (i - 1) * 90
            gc_setColor(1, 1, 1, .1)
            FONT.set(50)
            gc_print(i, 30, y - 45)
            FONT.set(30)
            gc_setColor(0, 0, 0, .26)
            gc_mRect('fill', 450, y, 860, 80, 20)
            gc_setColor(clr.L)
            if uidList[i] then
                gc_mStr(uidList[i].modTime, 140, y - 20 + 15)
                gc_setColor(clr.LT)
                gc_mStr(uidList[i].uid, 140, y - 20 - 15)
            else
                gc_mStr("[empty]", 140, y - 20)
            end
        end
    elseif page == 3 then
        -- Music player
        local len = 800

        local playTime = BGM.tell()
        local beatLen = 60 / BgmData[BgmPlaying].bpm
        local beatBar = BgmData[BgmPlaying].bar

        gc_ucs_move(50, 120)

        -- Time
        FONT.set(30)
        gc_setColor(clr.T)
        gc_print(STRING.time_simp(playTime), 0, 49, 0, .626)
        gc_print(playingBgmLengthStr, len - 45, 49, 0, .626)

        -- Repeat marks
        local data = BgmData[BgmPlaying]
        if BgmLooping then
            if data.loop[1] == 0 then
                gc_print('D.C.', len * data.loop[2] / playingBgmLength, 35, 0, .3)
            else
                gc_print('S', len * data.loop[1] / playingBgmLength, 35, 0, .3)
                gc_print('D.S.', len * data.loop[2] / playingBgmLength, 35, 0, .3)
            end
        end

        -- Progress bar
        gc_setColor(clr.L)
        gc_rectangle('fill', 0, 46, len, 4)
        if BgmPlaying == 'tera' or BgmPlaying == 'terar' or BgmPlaying == 'terae' or BgmPlaying == 'teral' or BgmPlaying == 'terael' then
            gc_setColor(COLOR.rainbow_light(2.6 * t))
            if BgmPlaying == 'teral' or BgmPlaying == 'terael' then
                GAME.showLyric(Lyric.terael, 0, 245, BgmPlaying == 'teral' and 0.1 or 0)
            end
        else
            gc_setColor(bgmColors[SongNamePlaying])
        end
        gc_rectangle('fill', 0, 46, len * playTime / playingBgmLength, 4)

        -- Ambient Glow
        gc.push('transform')
        gc_replaceTransform(SCR.origin)
        if BgmPlaying == 'tera' or BgmPlaying == 'terar' then
            gc_setAlpha(.42)
        else
            gc_setAlpha(.2 + .06 * math.sin(playTime / beatLen * 1.5708))
        end
        gc_draw(TEXTURE.transition, 0, 0, 0, .42 / 128 * SCR.w, SCR.h)
        gc_draw(TEXTURE.transition, SCR.w, 0, 0, -.42 / 128 * SCR.w, SCR.h)
        gc.pop()

        -- Title
        gc_setAlpha(1)
        gc_mStr(playingBgmTitle, len / 2, 0)
        if not (BgmPlaying == 'tera' or BgmPlaying == 'terar') then
            gc_setColor(1, 1, 1, .35 - .26 * math.sin(playTime / (beatBar * beatLen) * 3.1416))
        end
        gc_mStr(playingBgmTitle, len / 2, 0)
        gc_setColor(clr.LT)
        gc_setAlpha(.26)
        gc_printf(data.meta, len / 2, 56, 2 * len, 'center', 0, .42, .42, len)

        -- Skip marks
        if BgmNeedSkip then
            local alpha = .26 + .62 * (-2.6 * t % 1)
            gc_setColor(COLOR.C)
            gc_setAlpha(alpha)
            gc_mRect('fill', len * BgmNeedSkip[1] / playingBgmLength, 48, 2, 9)
            gc_setColor(COLOR.O)
            gc_setAlpha(alpha)
            gc_mRect('fill', len * BgmNeedSkip[2] / playingBgmLength, 48, 2, 9)
        end
        gc_ucs_back()
    end

    -- Top bar & title
    gc_replaceTransform(SCR.xOy_u)
    gc_setColor(page == 4 and ZCEMclr.D or clr.D)
    gc_setAlpha(GAME.einvisUI and 0.626 or 1)
    gc_rectangle('fill', -1300, 0, 2600, 70)
    gc_setColor(page == 4 and ZCEMclr.L or clr.L)
    gc_setAlpha(GAME.einvisUI and 0.262 or .626)
    gc_rectangle('fill', -1300, 70, 2600, 3)
    gc_replaceTransform(SCR.xOy_ul)
    gc_setColor(page == 4 and ZCEMclr.L or clr.L)
    gc_setAlpha(GAME.einvisUI and 0.626 or 1)
    FONT.set(50)
    if GAME.anyRev then
        gc_print(page == 4 and "ZCEM SETTINGS" or "CONFIG", 15, 68, 0, 1, -1)
    else
        gc_print(page == 4 and "ZCEM SETTINGS" or "CONFIG", 15, 0)
    end

    -- Bottom bar & text
    gc_replaceTransform(SCR.xOy_d)
    gc_setColor(page == 4 and ZCEMclr.D or clr.D)
    gc_setAlpha(GAME.einvisUI and 0.626 or 1)
    gc_rectangle('fill', -1300, 0, 2600, -50)
    gc_setColor(page == 4 and ZCEMclr.L or clr.L)
    gc_setAlpha(GAME.einvisUI and 0.262 or .626)
    gc_rectangle('fill', -1300, -50, 2600, -3)
    gc_replaceTransform(SCR.xOy_dl)
    gc_setColor(page == 4 and ZCEMclr.L or clr.L)
    gc_setAlpha(GAME.einvisUI and 0.626 or 1)
    FONT.set(30)
    gc_print("TWEAK YOUR SETTINGS FOR A BETTER " .. (page == 4 and "MODDED" or "CLICKING") .. " EXPERIENCE", 15, -45, 0, .85, 1)
end

function scene.overDraw()
    -- BPM/Speed Indicator
    local data = BgmData[BgmPlaying]
    local bpm = data.bpm
    local speedMod = 1
    if GAME.nightcore then 
        bpm = bpm * 2
        speedMod = speedMod * 2.6
    end
    if GAME.enightcore then 
        bpm = bpm * 2
    end
    if GAME.slowmo then 
        bpm = bpm / 2
    end
    if GAME.eslowmo then
        bpm = bpm * 0.70711
        speedMod = speedMod * 0.75
    end
    if GAME.ecloseCard then
        speedMod = speedMod * 2
    end
    if GAME.mod.GV == -1 then
        bpm = bpm * 0.70711
    elseif GAME.mod.GV == 1 then
        bpm = bpm * 1.05946
    elseif GAME.mod.GV == 2 then
        if not URM then
            bpm = bpm * 1.12246
        else
            bpm = bpm * 1.18921
        end
    end
    local M = GAME.mod
    if (M.EX == -1 and URM and M.NH < 2 and M.MS < 2 and M.GV < 2 and M.VL < 2 and M.DH < 2 and M.IN < 2 and M.AS < 2 and M.DP < 2) then
        bpm = bpm * 1.01455
    end
    local playTime = 0
    local beatLen = 0
    local dy = 0
    local t = love.timer.getTime()
    if bpmMode and (page == 4 or page == 3) then
        playTime = BGM.tell()
        beatLen = 60 / BgmData[BgmPlaying].bpm
        dy = MATH.clamp(6 * math.sin(playTime / beatLen * 3.1416), -2.6, 2.6)
    end
    if page == 4 then
        if bpmMode then
            local bpmString = "BPM: "..tostring(MATH.floor(bpm*100)/100)
            gc_setColor(BgmPlaying ~= 'f0' and bgmColors[BgmPlaying] or ZCEMclr.LT)
            if BgmPlaying == 'tera' or BgmPlaying == 'terar' or BgmPlaying == 'terae' or BgmPlaying == 'teral' or BgmPlaying == 'terael' then
                gc_setColor(COLOR.rainbow_light(2.6 * t * bpm/240))
            end
            gc_setAlpha(1)
            FONT.set(65)
            gc_print(bpmString, 835 - (GAME.ecloseCard and 20 or 0), 110 + dy)
        else
            local speedString = "SPEED: "..tostring(MATH.floor(speedMod*100)/100) .. "x"
            gc_setColor(BgmPlaying ~= 'f0' and bgmColors[BgmPlaying] or ZCEMclr.LT)
            if BgmPlaying == 'tera' or BgmPlaying == 'terar' or BgmPlaying == 'terae' or BgmPlaying == 'teral' or BgmPlaying == 'terael' then
                gc_setColor(COLOR.rainbow_light(2.6 * t * bpm/240))
            end
            gc_setAlpha(1)
            FONT.set(65)
            gc_print(speedString, 835 - (GAME.ecloseCard and 20 or 0), 110 + dy)
        end
        if countPiecesActive() > 1 then
            gc_setColor(COLOR.R)
            gc_setAlpha(1)
            FONT.set(50)
            gc_print("MULTIPLE PIECES!!!", 770 - (GAME.ecloseCard and 20 or 0), baseY + 338 + dy)
            GAME.refreshCurrentCombo()
        else
            GAME.multiplePiecesActive = false
            GAME.refreshCurrentCombo()
        end
    end
    if URM then
        gc_replaceTransform(SCR.origin)
        gc_setColor(.42, 0, 0, .35)
        gc_draw(TEXTURE.pixel, 0, 0, 0, SCR.w, SCR.h)
        gc_setColor(0, 0, 0, GAME.mod.EX == 2 and .62 or .42)
        gc_draw(TEXTURE.darkCorner, 0, 0, 0, SCR.w / 128, SCR.h / 128)
    end
end

local pageVisFunc = {}
for p = 1, maxPage do pageVisFunc[p] = function() return page == p end end

-- Page 1
local videoY = baseY + 360
local page1 = {
    -- Audio
    WIDGET.new { -- title
        type = 'text', alignX = 'left',
        text = "AUDIO",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 50,
    },
    WIDGET.new { -- sfx
        type = 'slider',
        x = baseX + 240 + 85, y = baseY + 110, w = 400,
        axis = { 0, 100, 10 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return CONF.sfx end,
        code = function(value)
            CONF.sfx = value
            ApplySettings()
        end,
        sound_drag = 'rotate',
    },
    WIDGET.new { -- bgm
        type = 'slider',
        x = baseX + 240 + 85, y = baseY + 190, w = 400,
        axis = { 0, 100, 10 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return CONF.bgm end,
        code = function(value)
            CONF.bgm = value
            ApplySettings()
        end,
        sound_drag = 'rotate',
    },
    WIDGET.new { -- mute
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "MUTE ON UNFOCUS",
        x = baseX + 55, y = baseY + 280,
        disp = function() return CONF.autoMute end,
        code = function() CONF.autoMute = not CONF.autoMute end,
    },
    -- Video
    WIDGET.new { -- title
        type = 'text', alignX = 'left',
        text = "VIDEO",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = videoY + 0,
    },
    WIDGET.new { -- card brightness
        type = 'slider',
        x = baseX + 240 + 85, y = videoY + 60, w = 400,
        axis = { 80, 100, 5 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return CONF.cardBrightness end,
        code = function(value) CONF.cardBrightness = value end,
        sound_drag = 'rotate',
    },
    WIDGET.new { -- bg brightness
        type = 'slider',
        x = baseX + 240 + 85, y = videoY + 140, w = 400,
        axis = { 30, 80, 10 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return CONF.bgBrightness end,
        code = function(value) CONF.bgBrightness = value end,
        sound_drag = 'rotate',
    },
    WIDGET.new { -- fancy
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "FANCY BACKGROUND  (F9)",
        x = baseX + 55, y = videoY + 230,
        disp = function() return CONF.bg end,
        code = WIDGET.c_pressKey 'f9',
    },
    WIDGET.new { -- star
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "STAR FORCE  (F10)",
        x = baseX + 55, y = videoY + 300,
        disp = function() return not CONF.syscursor end,
        code = WIDGET.c_pressKey 'f10',
    },
    WIDGET.new { -- fullscreen
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "FULLSCREEN  (F11)",
        x = baseX + 55, y = videoY + 370,
        disp = function() return CONF.fullscreen end,
        code = WIDGET.c_pressKey 'f11',
    },
    -- Keybind
    WIDGET.new {
        type = 'button',
        x = baseX + 730, y = baseY + 770, w = 260, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "REBIND  KEY",
        onClick = function()
            if bindBuffer then
                bindBuffer = {}
                SFX.play('b2bcharge_danger', .8)
            else
                -- MSG.clear()
                if TASK.lock('rebind_control', 12) then
                    SFX.play('notify')
                    MSG('dark', {
                            "Current Keybinding:\n" ..
                            table.concat(TABLE.sub(CONF.keybind, 1, 9), ', ') .. "\n" ..
                            table.concat(TABLE.sub(CONF.keybind, 10, 18), ', ') .. "\n" ..
                            "Commit: " .. CONF.keybind[19] .. "\n" ..
                            "Reset: " .. CONF.keybind[20] .. "\n" ..
                            "Click L/R: " .. CONF.keybind[21] .. ", " .. CONF.keybind[22] .. "\n",
                            COLOR.F, "PRESS AGAIN TO REBIND\n",
                            COLOR.LD, "(F1-F12 ` Tab Ctrl Alt are not allowed)"
                        },
                        12
                    )
                else
                    TASK.unlock('rebind_control')
                    bindBuffer = {}
                    SFX.play('b2bcharge_danger', .8)
                end
            end
        end,
    },
}

-- Page 2
local profY = baseY + 220
local page2 = {
    -- Account
    WIDGET.new { -- title
        type = 'text', alignX = 'left',
        text = "ACCOUNT",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 50,
    },
    WIDGET.new {
        name = 'changeName', type = 'button',
        x = baseX + 230, y = baseY + 130, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "CHANGE  USERNAME",
        onClick = function()
            -- MSG.clear()
            local newName = CLIPBOARD.get()
            if #newName == 0 then
                MSG('dark', "No data in clipboard")
                return
            end
            newName = newName:trim()
            if TASK.lock('changeName', 2.6) then
                SFX.play('notify')
                MSG('dark', "Change your name to clipboard text? ('" .. newName .. "')\nPress again to confirm", 2.6)
                return
            end
            TASK.unlock('changeName')
            newName = newName:upper()
            if #newName < 3 or #newName > 16 or newName:find('[^A-Z0-9_%-]') then
                MSG('dark', "New name must be 3-16 characters long and contain the following: A-Z, 0-9, -, _")
                SFX.play('staffwarning')
                return
            end
            if newName == STAT.uid then
                MSG('dark', "New name is the same as the old one.")
                SFX.play('staffwarning')
                return
            end
            if newName:match('^ANON[-_]') then
                MSG('dark', "You can’t enter ANON as your new name.")
                SFX.play('staffwarning')
                return
            end
            STAT.uid = newName
            SaveStat()
            SFX.play('supporter')
            MSG('dark', "Your name was changed to " .. STAT.uid)
            if SCN.cur == 'stat' then RefreshProfile() end
            refreshUID()
            IssueAchv('identity')
        end,
    },
    WIDGET.new {
        name = 'changeAboutme', type = 'button',
        x = baseX + 640, y = baseY + 130, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "CHANGE  ABOUT ME",
        onClick = function()
            -- MSG.clear()
            local newText = CLIPBOARD.get()
            if #newText == 0 then
                MSG('dark', "No data in clipboard")
                return
            end
            newText = newText:trim()
            if TASK.lock('changeAboutme', 2.6) then
                SFX.play('notify')
                MSG('dark', "Change your about me text to clipboard text?\nPress again to confirm", 2.6)
                return
            end
            TASK.unlock('changeAboutme')
            repeat
                if type(newText) ~= 'string' then
                    MSG('dark', "No data in clipboard")
                    break
                end
                if #newText < 1 or #newText > 260 or newText:find('[^\32-\126]') then
                    MSG('dark', "Text must be 1-260 characters long and contain visible ASCII characters")
                    break
                end
                if newText == STAT.aboutme then
                    MSG('dark', "New text is the same as the old one")
                    break
                end
                STAT.aboutme = newText
                SaveStat()
                SFX.play('supporter')
                MSG('dark', "Your About Me text has been updated.")
                if SCN.cur == 'stat' then RefreshProfile() end
                IssueAchv('identity')
                return
            until true
            SFX.play('staffwarning')
        end,
    },
    -- Profile
    WIDGET.new { -- title
        type = 'text', alignX = 'left',
        text = "PROFILE",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = profY + 0,
    },
    WIDGET.new {
        name = 'export', type = 'button',
        x = baseX + 230, y = profY + 80, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "EXPORT  PROGRESS",
        onClick = function()
            -- MSG.clear()
            if TestMode then
                SFX.play('staffwarning')
                MSG('dark', "You are not a good person.")
                return
            end
            if TASK.lock('export', 2.6) then
                SFX.play('notify')
                MSG('dark', "Export your progress to clipboard?\nPress again to confirm", 2.6)
                return
            end
            TASK.unlock('export')
            CLIPBOARD.set(STRING.packTable(STAT) .. ',' .. STRING.packTable(BEST) .. ',' .. STRING.packTable(ACHV))
            MSG('dark', "Progress exported!")
            SFX.play('social_notify_minor')
        end,
    },
    WIDGET.new {
        name = 'import', type = 'button',
        x = baseX + 640, y = profY + 80, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "IMPORT  PROGRESS",
        onClick = function()
            -- MSG.clear()
            local data = CLIPBOARD.get():filterASCII():trim()
            local anyPieceActive = GAME.nightcore or GAME.enightcore or GAME.slowmo or GAME.eslowmo or GAME.glassCard or GAME.eglassCard or GAME.fastLeak or GAME.efastLeak or GAME.invisUI or GAME.einvisUI or GAME.invisCard or GAME.einvisCard or GAME.closeCard or GAME.ecloseCard
            if #data <= 26 then
                if data == '' then
                    MSG('dark', "No data in clipboard")
                elseif data == 'cmd' then
                    SFX.play('cutin_superlobby', 1, 0, Tone(-2))
                    SCN.go('_console')
                elseif data == 'old_hitbox' then
                    CONF.oldHitbox = not CONF.oldHitbox
                    MSG('dark', "Force old hitbox: " .. (CONF.oldHitbox and "ON" or "OFF"))
                    SFX.play(CONF.oldHitbox and 'social_online' or 'social_offline')
                    TEXTS.version:set(SYSTEM .. (CONF.oldHitbox and " T" or " V") .. (require 'version'.verStr))
                elseif data == 'true_ending' then
                    SFX.play('warp')
                    SCN.go('ending', 'warp')
                elseif data == 'test' then
                    TestMode = true
                    SFX.play('maintenance')
                elseif data == 'dev' then
                    MSG('dark', OverDevProgressText)
                elseif data == 'repo' then
                    SFX.play('menuconfirm')
                    love.system.openURL("https://github.com/MrZ626/ZenithClicker")
                elseif data == 'UseAltName' then
                    UseAltName()
                    SFX.play('social_dm')
                elseif data == 'UseEasyName' or data == 'UseEasName' then
                    STAT.easyName = not STAT.easyName
                    SFX.play('social_dm')
                    MSG('dark', "Easy Names In-Game: " .. (STAT.easyName and "ON" or "OFF"))
                elseif data == 'imperial' or data == 'feet' then
                    STAT.imperial = not STAT.imperial
                    SFX.play('social_dm')
                    MSG('dark', "Imperial Units: " .. (STAT.imperial and "ON" or "OFF"))
                elseif data == 'promotion' then
                    STAT.promotion = not STAT.promotion
                    SFX.play('social_dm')
                    MSG('dark', "Rank Promotion Gauge: " .. (STAT.promotion and "ON" or "OFF"))
                elseif data == 'old_transparent_card' or data == 'oldTransparentCard' or data == 'oldtransparentcard' or data == 'oldeO' then
                    STAT.oldTransparentCard = not STAT.oldTransparentCard
                    SFX.play('social_dm')
                    MSG('dark', "Transparent Card: " .. (STAT.oldTransparentCard and "V1.0/1.1" or "V1.2+"))
                elseif data == 'eZ' or data == 'ez' then
                    if not GAME.enightcore and anyPieceActive then 
                        SFX.play('damage_alert')
                        MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                        GAME.multiplePiecesActive = true
                    else
                        SFX.play('social_dm')
                    end
                    GAME.enightcore = not GAME.enightcore
                    MSG('dark', "eZ: " .. (GAME.enightcore and "ON" or "OFF"))
                    GAME.refreshLayout()
                    RefreshBGM()
                    GAME.refreshCurrentCombo()
                elseif data == 'eS' or data == 'es' then
                    if not GAME.eslowmo and anyPieceActive then 
                        SFX.play('damage_alert')
                        MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                        GAME.multiplePiecesActive = true
                    else
                        SFX.play('social_dm')
                    end
                    GAME.eslowmo = not GAME.eslowmo
                    MSG('dark', "eS: " .. (GAME.eslowmo and "ON" or "OFF"))
                    GAME.refreshLayout()
                    RefreshBGM()
                    GAME.refreshCurrentCombo()
                elseif data == 'eJ' or data == 'ej' then
                    if not GAME.eglassCard and anyPieceActive then 
                        SFX.play('damage_alert')
                        MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                        GAME.multiplePiecesActive = true
                    else
                        SFX.play('social_dm')
                    end
                    GAME.eglassCard = not GAME.eglassCard
                    MSG('dark', "eJ: " .. (GAME.eglassCard and "ON" or "OFF"))
                    GAME.refreshLayout()
                    GAME.refreshCurrentCombo()
                elseif data == 'eL' or data == 'el' then
                    if not GAME.efastLeak and anyPieceActive then 
                        SFX.play('damage_alert')
                        MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                        GAME.multiplePiecesActive = true
                    else
                        SFX.play('social_dm')
                    end
                    GAME.efastLeak = not GAME.efastLeak
                    MSG('dark', "eL: " .. (GAME.efastLeak and "ON" or "OFF"))
                    GAME.refreshLayout()
                    GAME.refreshCurrentCombo()
                elseif data == 'eT' or data == 'et' then
                    if not GAME.einvisUI and anyPieceActive then 
                        SFX.play('damage_alert')
                        MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                        GAME.multiplePiecesActive = true
                    else
                        SFX.play('social_dm')
                    end
                    GAME.einvisUI = not GAME.einvisUI
                    MSG('dark', "eT: " .. (GAME.einvisUI and "ON" or "OFF"))
                    GAME.refreshLayout()
                    GAME.refreshCurrentCombo()
                elseif data == 'eO' or data == 'eo' then
                    if not GAME.einvisCard and anyPieceActive then 
                        SFX.play('damage_alert')
                        MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                        GAME.multiplePiecesActive = true
                    else
                        SFX.play('social_dm')
                    end
                    GAME.einvisCard = not GAME.einvisCard
                    MSG('dark', "eO: " .. (GAME.einvisCard and "ON" or "OFF"))
                    GAME.refreshLayout()
                    GAME.refreshCurrentCombo()
                elseif data == 'eI' or data == 'ei' then
                    if not GAME.ecloseCard and anyPieceActive then 
                        SFX.play('damage_alert')
                        MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                        GAME.multiplePiecesActive = true
                    else
                        SFX.play('social_dm')
                    end
                    GAME.ecloseCard = not GAME.ecloseCard
                    MSG('dark', "eI: " .. (GAME.ecloseCard and "ON" or "OFF"))
                    GAME.refreshLayout()
                    GAME.refreshCurrentCombo()
                elseif data == 'lyrics' then
                    STAT.lyrics = not STAT.lyrics
                    SFX.play(STAT.lyrics and 'social_online' or 'social_offline')
                    MSG('dark', "In-Game Lyrics: " .. (STAT.lyrics and "Enabled" or " Disabled"))
                elseif data == 'resubmit' then
                    if DAILYCMD then
                        ASYNC.runCmd('submitDaily', DAILYCMD)
                        MSG('info', "Re-submitting Daily Challenge score...")
                        SFX.play('social_invite')
                    else
                        MSG('warn', "No buffered Daily Challenge score")
                        SFX.play('failure', 1, 0, Tone(0))
                    end
                else
                    local msg = "Invalid code '" .. data .. "' in clipboard."
                    if MATH.roll(.26) then
                        msg = msg .. "\n" .. TABLE.getRandom {
                            "Try 'cmd'",
                            "Try 'cooldown'",
                            "Try 'old_hitbox'",
                            "Try 'test'",
                            "Try 'dev'",
                            "Try 'repo'",
                            MATH.coin("Try 'mp'", "Try 'music'"),
                            "Try 'f" .. STAT.maxFloor .. "'",
                            "Try 'UseEasyName'",
                            "Try 'imperial'",
                            "Try 'promotion'",
                            STAT.clicker and "Try 'true_ending'" or nil,
                        }
                    end
                    MSG('dark', msg)
                    SFX.play('staffwarning')
                    return
                end
                LOG('info', "Secret: " .. data)
                return
            end
            if TASK.lock('import', 4.2) then
                SFX.play('notify')
                MSG('dark',
                    "Import data from clipboard text?\nThe version must match; all progress you made so far will be permanently lost!\nPress again to confirm",
                    4.2)
                return
            end
            TASK.unlock('import')
            local d3 = STRING.split(data, ',')
            local suc1, res1 = pcall(STRING.unpackTable, d3[1])
            local suc2, res2 = pcall(STRING.unpackTable, d3[2])
            local suc3, res3
            if d3[3] then
                suc3, res3 = pcall(STRING.unpackTable, d3[3])
            else
                suc3, res3 = true, {}
            end
            if not suc1 or not suc2 or not suc3 then
                MSG('dark', "Invalid data format")
                SFX.play('staffwarning')
                return
            elseif res1.version > STAT.version then
                MSG('error', "Cannot import data from future versions\nPlease update your game first!")
                SFX.play('staffwarning')
                return
            elseif res1.mod and res1.mod ~= 'vanilla' and res1.mod ~= 'easyMode' then
                local modText = "Cannot import data from a different modded version"
                if res1.mod == "A Fool's Mod" then modText = "The Creator thinks you're foolish for trying to use that here"
                elseif res1.mod == "evilvile" then modText = "The Creator wants nothing to do with something that evil"
                elseif res1.mod == "shimmer" then modText = "The Creator asks you to keep your sparkling water away from his creation"
                elseif res1.mod == "unabstracted" then modText = "The Creator prefers his work abstract"
                elseif res1.mod == "finalmixbeg" then modText = "The Creator rejects your chakras and magics" end
                MSG('dark', modText)
                SFX.play('staffwarning')
                return
            end
            TABLE.update(STAT, res1)
            STAT.mod = 'easyMode'
            BEST, ACHV = res2, res3
            setmetatable(BEST.highScore, Metatable.best_highscore)
            GAME.refreshLockState()
            setmetatable(BEST.speedrun, Metatable.best_speedrun)
            if STAT.system ~= SYSTEM then
                STAT.system = SYSTEM
                IssueAchv('zenith_relocation')
            end
            Initialize(true)
            if TestMode or GAME.multiplePiecesActive then
                MSG('dark', "Progress imported, but won't be saved.")
            else
                MSG('dark', "Progress imported!")
            end
            SFX.play('social_notify_major')
        end,
    },
    WIDGET.new {
        name = 'resetall', type = 'button',
        x = baseX + 450, y = profY + 220, w = 260, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "RESET ALL",
        onClick = function()
            if not (uidList[1] or uidList[2] or uidList[3]) then
                SFX.play('staffwarning')
                MSG('dark', "You must have at least 1 backup before resetting all progress!")
                return
            end
            local instaReset = anonUser or TASK.getLock('just_saved')
            if TASK.lock('reset_all', 2.6) then
                resetall_cnt = 0
                lastClear = false
                SFX.play('hyperalert')
                if instaReset then
                    MSG('warn', "Reset all progress? Press again to confirm.", 2.6)
                else
                    MSG('info', "Reset all progress? Spam to confirm.", 2.6)
                end
                return
            end
            if not instaReset and not TASK.forceLock('reset_all', 1) and resetall_cnt < 16 then
                resetall_cnt = resetall_cnt + 1
                local spin = MATH.roll(.26)
                local clear = spin and 's' .. math.random(2) or 'c' .. math.random(2, 4)
                SFX.play(spin and 'clearspin' or clear == 'c4' and 'clearquad' or 'clearline')
                SFX.play('combo_' .. resetall_cnt .. ((clear == 's2' or clear == 'c4') and '_power' or ''))
                if GAME.mod.AS == 1 then
                    if clear == lastClear then
                        for _ = 1, 2 do SFX.play('wound') end
                        resetall_cnt = math.max(resetall_cnt - 2, 0)
                    elseif MATH.roll(.26) then
                        SFX.play('wound_repel')
                    end
                elseif GAME.mod.AS == 2 then
                    if clear == lastClear then
                        for _ = 1, 3 do SFX.play('wound') end
                        TASK.unlock('reset_all')
                        SaveConf()
                        SCN.back('none')
                    end
                end
                lastClear = clear
                return
            end
            FILE.delete('stat.luaon')
            FILE.delete('achv.luaon')
            FILE.delete('best.luaon')
            TASK.unlock('reset_all')
            if not instaReset then SFX.play('combo_16_power') end
            SFX.play('clearquad')
            SFX.play('inject')
            SFX.play('thunder' .. math.random(6))
            MSG.clear()
            SCN._pop()
            SCN.swapTo('joining', 'fade', true)
        end,
    },
}
local function saveSlot(i)
    if TestMode then
        SFX.play('staffwarning')
        MSG('dark', "You are not a good person.")
        return
    end
    if uidList[i] and STAT.uid ~= uidList[i].uid then
        SFX.play('staffwarning')
        MSG('dark', "For safety, you can only update a backup with same username", 4.2)
        return
    end
    TASK.unlock('save_slot' .. i)
    TASK.lock('just_saved', 10)
    SaveStat()
    FILE.createDirectory('save' .. i)
    FILE.copy('stat.luaon', 'save' .. i .. '/stat.luaon')
    FILE.copy('achv.luaon', 'save' .. i .. '/achv.luaon')
    FILE.copy('best.luaon', 'save' .. i .. '/best.luaon')
    uidList[i] = { uid = STAT.uid, modTime = "just now" }
    SFX.play('allclear')
    MSG('check', "Progress backed up to slot " .. i .. "!", 2.6)
    WIDGET._reset()
end
local function loadSlot(i)
    if TASK.lock('load_slot' .. i, 2.6) then
        SFX.play('hyperalert')
        MSG('warn', "Load from slot " .. i .. "? Current save will be overwritten. Press again to confirm.", 4.2)
        return
    end
    TASK.unlock('load_slot' .. i)
    FILE.copy('save' .. i .. '/stat.luaon', 'stat.luaon')
    FILE.copy('save' .. i .. '/achv.luaon', 'achv.luaon')
    FILE.copy('save' .. i .. '/best.luaon', 'best.luaon')
    SFX.play('levelup'); SFX.play('levelup')
    SCN._pop()
    SCN.swapTo('joining', 'fade', true)
end
local function clearSlot(i)
    if TASK.lock('clear_slot' .. i, 2.6) then
        SFX.play('hyperalert')
        MSG('warn', "Clear slot " .. i .. "? This action cannot be undone. Press again to confirm.", 4.2)
        return
    end
    TASK.unlock('clear_slot' .. i)
    TASK.unlock('just_saved')
    FILE.delete('save' .. i)
    uidList[i] = false
    SFX.play('clearquad')
    SFX.play('inject')
    SFX.play('thunder' .. math.random(6))
    MSG.clear()
    WIDGET._reset()
end
local slBtnTextColor = { 0, 0, 0, .62 }
for i = 1, 3 do
    local y = profY + 330 + (i - 1) * 90
    TABLE.append(page2, {
        WIDGET.new {
            name = 'save' .. i, type = 'button',
            x = baseX + 355, y = y, w = 160, h = 50,
            fontSize = 30, color = 'lG', textColor = slBtnTextColor, text = "BACKUP",
            onClick = function() saveSlot(i) end,
        },
        WIDGET.new {
            name = 'load' .. i, type = 'button',
            x = baseX + 555, y = y, w = 160, h = 50,
            fontSize = 30, color = 'lY', textColor = slBtnTextColor, text = "LOAD",
            onClick = function() loadSlot(i) end,
            visibleFunc = function() return page == 2 and uidList[i] end,
        },
        WIDGET.new {
            name = 'clear' .. i, type = 'button',
            x = baseX + 755, y = y, w = 160, h = 50,
            fontSize = 30, color = 'lR', textColor = slBtnTextColor, text = "CLEAR",
            onClick = function() clearSlot(i) end,
            visibleFunc = function() return page == 2 and uidList[i] end,
        },
    })
end

-- Page 3
local albumY = baseY + 250
local page3 = {
    -- Album
    WIDGET.new { -- title
        type = 'text', alignX = 'left',
        text = "ALBUM",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 50,
    },
    WIDGET.new { -- -30s
        type = 'button',
        x = baseX + 130, y = albumY, w = 150, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "-30s",
        onClick = function()
            TASK.removeTask_code(Task_MusicEnd)
            BGM.set('all', 'seek', math.max(BGM.tell() - 30, 0))
        end,
    },
    WIDGET.new { -- -5s
        type = 'button',
        x = baseX + 330, y = albumY, w = 150, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "-5s",
        onClick = function()
            TASK.removeTask_code(Task_MusicEnd)
            BGM.set('all', 'seek', math.max(BGM.tell() - 5, 0))
        end,
    },
    WIDGET.new { -- +5s
        type = 'button',
        x = baseX + 540, y = albumY, w = 150, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "+5s",
        onClick = function()
            TASK.removeTask_code(Task_MusicEnd)
            BGM.set('all', 'seek', math.min(BGM.tell() + 5, BGM.getDuration()))
        end,
    },
    WIDGET.new { -- +30s
        type = 'button',
        x = baseX + 740, y = albumY, w = 150, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "+30s",
        onClick = function()
            TASK.removeTask_code(Task_MusicEnd)
            BGM.set('all', 'seek', math.min(BGM.tell() + 30, BGM.getDuration()))
        end,
    },
    WIDGET.new { -- no loop
        name = 'loops', type = 'button',
        x = baseX + 450, y = albumY + 80, w = 200, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "NO LOOPS",
        onClick = function()
            BgmLooping, BgmNeedSkip = false, false
        end,
    },
}
local function albumBtn(param)
    table.insert(page3, WIDGET.new(TABLE.update({
        type = 'button',
        w = 65,
        fontSize = 30,
        textColor = 'D',
    }, param)))
end
for i = 0, 10 do
    albumBtn {
        x = baseX + 75 + 75 * i, y = baseY + 450,
        color = bgmColors['f' .. i],
        text = "" .. i,
        onClick = function()
            GAME.height = bgmHeight[i]
            PlayBGM('f' .. i)
        end,
        visibleFunc = function()
            return page == 3 and STAT.maxFloor >= i
        end,
    }
    albumBtn {
        x = baseX + 75 + 75 * i, y = baseY + 530,
        color = bgmColors['f' .. i .. 'r'],
        text = "R" .. i,
        onClick = function()
            GAME.height = (bgmHeight[i] + bgmHeight[i + 1]) / 2
            PlayBGM('f' .. i .. 'r')
        end,
        visibleFunc = function() return page == 3 and STAT.maxFloor >= 10 and TABLE.findAll(GAME.completion, 2) end,
    }
end
albumBtn {
    x = baseX + 450 - 200, y = baseY + 670, w = 150, h = 60,
    color = bgmColors.tera,
    text = "TERA",
    onClick = function()
        PlayBGM('tera')
    end,
    visibleFunc = function() return page == 3 and ACHV.blazing_speed end,
}
albumBtn {
    x = baseX + 450, y = baseY + 670, w = 150, h = 60,
    color = bgmColors.fomg,
    fontSize = 50,
    text = "FΩ",
    onClick = function()
        GAME.height = 6200
        PlayBGM('fomg')
    end,
    visibleFunc = function() return page == 3 and STAT.maxHeight >= 6200 end,
}
albumBtn {
    x = baseX + 450 + 200, y = baseY + 670, w = 150, h = 60,
    color = bgmColors.terar,
    text = "TERAR",
    onClick = function()
        PlayBGM('terar')
    end,
    visibleFunc = function() return page == 3 and ACHV.blazing_speed and BEST.highScore.rEX >= Floors[9].top end,
}
albumBtn {
    x = baseX + 450 - 200, y = baseY + 750, w = 150, h = 60,
    color = bgmColors.tera,
    text = "TERAL",
    onClick = function()
        PlayBGM('teral')
        refreshSongInfo()
    end,
    visibleFunc = function() return page == 3 and ACHV.uneasy end,
}
albumBtn {
    x = baseX + 450, y = baseY + 750, w = 150, h = 60,
    color = bgmColors.tera,
    text = "TERAEL",
    onClick = function()
        PlayBGM('terael')
        refreshSongInfo()
    end,
    visibleFunc = function() return page == 3 and ACHV.uneasy and ACHV.programmer_gamer and ACHV.programmer_gamer >= 1650 end,
}
albumBtn {
    x = baseX + 450 + 200, y = baseY + 750, w = 150, h = 60,
    color = bgmColors.tera,
    text = "TERAE",
    onClick = function()
        PlayBGM('terae')
        refreshSongInfo()
    end,
    visibleFunc = function() return page == 3 and ACHV.programmer_gamer and ACHV.programmer_gamer >= 1650 end,
}

-- Page 4
local page4 = {
    WIDGET.new { -- Game Play
        name = 'gameplay', type = 'button', 
        x = baseX + 220, y = baseY + 60, w = 410, h = 70,
        color = ZCEMclr.T,
        sound_hover = 'menutap',
        fontSize = 50, text = "GAME PLAY", textColor = ZCEMclr.LT,
        onClick = function()
            bpmMode = true
            refreshWidgets()
            IssueAchv('music_man')
            love.keypressed('3')
        end,
    },
    -- BPM button is shared with MP options
    WIDGET.new { -- Promotion
        name = 'promotion', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = ZCEMclr.T, text = "PROMOTION GAUGE",
        x = baseX + 40, y = baseY + 60 + 80,
        disp = function() return STAT.promotion end,
        code = function()
            local multiple = GAME.multiplePiecesActive
            MSG.clear()
            STAT.promotion = not STAT.promotion
            MSG('dark', "Rank Promotion Gauge: " .. (STAT.promotion and "ON" or "OFF"))
            if STAT.stacker and STAT.promotion then
                STAT.stacker = false
                MSG('dark', "STACKER and PROMOTION GAUGE are MUTUALLY EXCLUSIVE!")
                SFX.play('no')
            else
                SFX.play('social_dm')
            end
            GAME.multiplePiecesActive = false
            SaveStat()
            if multiple then GAME.multiplePiecesActive = true end
        end,
    },
    WIDGET.new { -- Imperial
        name = 'imperial', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = ZCEMclr.T, text = "IMPERIAL UNITS",
        x = baseX + 500, y = baseY + 60 + 240,
        disp = function() return STAT.imperial end,
        code = function()
            local multiple = GAME.multiplePiecesActive
            MSG.clear()
            STAT.imperial = not STAT.imperial
            SFX.play('social_dm')
            MSG('dark', "Imperial Units: " .. (STAT.imperial and "ON" or "OFF"))
            GAME.multiplePiecesActive = false
            SaveStat()
            if multiple then GAME.multiplePiecesActive = true end
        end,
    },
    WIDGET.new { -- Old Transparent Card
        name = 'oldTransparentCard', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = ZCEMclr.T, text = "OLD TRANSPARENT CARD",
        x = baseX + 40, y = baseY + 60 + 160,
        disp = function() return STAT.oldTransparentCard end,
        code = function()
            local multiple = GAME.multiplePiecesActive
            MSG.clear()
            STAT.oldTransparentCard = not STAT.oldTransparentCard
            SFX.play('social_dm')
            MSG('dark', "Transparent Card: " .. (STAT.oldTransparentCard and "V1.0/1.1" or "V1.2+"))
            GAME.multiplePiecesActive = false
            SaveStat()
            if multiple then GAME.multiplePiecesActive = true end
        end,
    },
    WIDGET.new { -- Old Hitbox
        name = 'oldHitbox', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = ZCEMclr.T, text = "OLD HITBOX",
        x = baseX + 500, y = baseY + 60 + 160,
        disp = function() return STAT.oldHitbox end,
        code = function()
            local multiple = GAME.multiplePiecesActive
            MSG.clear()
            STAT.oldHitbox = not STAT.oldHitbox
            MSG('dark', "Force old hitbox: " .. (STAT.oldHitbox and "ON" or "OFF"))
            SFX.play(STAT.oldHitbox and 'social_online' or 'social_offline')
            GAME.multiplePiecesActive = false
            SaveStat()
            if multiple then GAME.multiplePiecesActive = true end
        end,
    },
    WIDGET.new { -- Use Easy Names
        name = 'easyName', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = ZCEMclr.T, text = "USE EASY NAMES",
        x = baseX + 40, y = baseY + 60 + 240,
        disp = function() return STAT.easyName end,
        code = function()
            local multiple = GAME.multiplePiecesActive
            MSG.clear()
            STAT.easyName = not STAT.easyName
            SFX.play('social_dm')
            MSG('dark', "Easy Names In-Game: " .. (STAT.easyName and "ON" or "OFF"))
            GAME.multiplePiecesActive = false
            SaveStat()
            if multiple then GAME.multiplePiecesActive = true end
        end,
    },
    WIDGET.new { -- Stacker
        name = 'stacker', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = ZCEMclr.T, text = "STACKER MODE",
        x = baseX + 500, y = baseY + 60 + 80,
        disp = function() return STAT.stacker end,
        code = function()
            local multiple = GAME.multiplePiecesActive
            MSG.clear()
            STAT.stacker = not STAT.stacker
            MSG('dark', "Stacker Mode: " .. (STAT.stacker and "ON" or "OFF"))
            if STAT.stacker and STAT.promotion then
                STAT.promotion = false
                SFX.play('no')
                MSG('dark', "STACKER and PROMOTION GAUGE are MUTUALLY EXCLUSIVE!")
            else
                SFX.play('social_dm')
            end
            GAME.multiplePiecesActive = false
            SaveStat()
            if multiple then GAME.multiplePiecesActive = true end
        end,
    },
    WIDGET.new { -- BPM/Speed Button
        name = 'bpm', type = 'button', 
        x = baseX + 685, y = baseY + 60, w = 410, h = 70,
        color = ZCEMclr.T,
        sound_hover = 'menutap',
        fontSize = 50, text = "", textColor = ZCEMclr.LT,
        onClick = function()
            bpmMode = not bpmMode
        end,
    },
    -- PIECE EFFECTS
    WIDGET.new { -- pieces
        name = 'pieces',
        type = 'text', alignX = 'left',
        text = "PIECE EFFECTS",
        color = ZCEMclr.T,
        fontSize = 50,
        x = baseX + 20, y = baseY + 370,
    },
    WIDGET.new { -- ez
        name = 'ez', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = COLOR.lR, text = "eZ - Nightcore+",
        x = baseX + 40, y = baseY + 50 + 400,
        disp = function() return GAME.enightcore end,
        code = function()
            MSG.clear()
            TASK.removeTask_code(Task_MusicEnd)
            if not GAME.enightcore and anyPieceActive() then 
                SFX.play('damage_alert')
                MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                GAME.multiplePiecesActive = true
            else
                SFX.play('social_dm')
            end
            GAME.enightcore = not GAME.enightcore
            MSG('dark', "eZ: " .. (GAME.enightcore and "ON" or "OFF"))
            RefreshBGM(mode)
        end,
    },
    WIDGET.new { -- es
        name = 'es', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = COLOR.lG, text = "eS - Slow-mo+",
        x = baseX + 500, y = baseY + 50 + 400,
        disp = function() return GAME.eslowmo end,
        code = function()
            MSG.clear()
            TASK.removeTask_code(Task_MusicEnd)
            if not GAME.eslowmo and anyPieceActive() then 
                SFX.play('damage_alert')
                MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                GAME.multiplePiecesActive = true
            else
                SFX.play('social_dm')
            end
            GAME.eslowmo = not GAME.eslowmo
            MSG('dark', "eS: " .. (GAME.eslowmo and "ON" or "OFF"))
            RefreshBGM(mode)
        end,
    },
    WIDGET.new { -- ej
        name = 'ej', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = COLOR.lB, text = "eJ - Glass Card+",
        x = baseX + 40, y = baseY + 50 + 480,
        disp = function() return GAME.eglassCard end,
        code = function()
            MSG.clear()
            TASK.removeTask_code(Task_MusicEnd)
            if not GAME.eglassCard and anyPieceActive() then 
                SFX.play('damage_alert')
                MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                GAME.multiplePiecesActive = true
            else
                SFX.play('social_dm')
            end
            GAME.eglassCard = not GAME.eglassCard
            MSG('dark', "eJ: " .. (GAME.eglassCard and "ON" or "OFF"))
            refreshWidgets()
            RefreshBGM(mode)
        end,
    },
    WIDGET.new { -- el
        name = 'el', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = COLOR.lO, text = "eL - Slow Leak",
        x = baseX + 500, y = baseY + 50 + 480,
        disp = function() return GAME.efastLeak end,
        code = function()
            MSG.clear()
            TASK.removeTask_code(Task_MusicEnd)
            if not GAME.efastLeak and anyPieceActive() then 
                SFX.play('damage_alert')
                MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                GAME.multiplePiecesActive = true
            else
                SFX.play('social_dm')
            end
            GAME.efastLeak = not GAME.efastLeak
            MSG('dark', "eL: " .. (GAME.efastLeak and "ON" or "OFF"))
            RefreshBGM(mode)
        end,
    },
    WIDGET.new { -- eT
        name = 'et', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = COLOR.lM, text = "eT - Transparent UI",
        x = baseX + 40, y = baseY + 50 + 560,
        disp = function() return GAME.einvisUI end,
        code = function()
            MSG.clear()
            TASK.removeTask_code(Task_MusicEnd)
            if not GAME.einvisUI and anyPieceActive() then 
                SFX.play('damage_alert')
                MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                GAME.multiplePiecesActive = true
            else
                SFX.play('social_dm')
            end
            GAME.einvisUI = not GAME.einvisUI
            MSG('dark', "eT: " .. (GAME.einvisUI and "ON" or "OFF"))
            RefreshBGM(mode)
        end,
    },
    WIDGET.new { -- eo
        name = 'eo', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = COLOR.lY, text = "eO - Transparent Card",
        x = baseX + 500, y = baseY + 50 + 560,
        disp = function() return GAME.einvisCard end,
        code = function()
            MSG.clear()
            TASK.removeTask_code(Task_MusicEnd)
            if not GAME.einvisCard and anyPieceActive() then 
                SFX.play('damage_alert')
                MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                GAME.multiplePiecesActive = true
            else
                SFX.play('social_dm')
            end
            GAME.einvisCard = not GAME.einvisCard
            MSG('dark', "eO: " .. (GAME.einvisCard and "ON" or "OFF"))
            RefreshBGM(mode)
        end,
    },
    WIDGET.new { -- ei
        name = 'ei', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = COLOR.lC, text = "eI - Closer Card",
        x = baseX + 40, y = baseY + 50 + 640,
        disp = function() return GAME.ecloseCard end,
        code = function()
            MSG.clear()
            TASK.removeTask_code(Task_MusicEnd)
            if not GAME.ecloseCard and anyPieceActive() then 
                SFX.play('damage_alert')
                MSG('dark', "WARNING: MULTIPLE PIECES ENABLED DISABLES SCORING AND MAY CAUSE ISSUES. DO NOT REPORT!")
                GAME.multiplePiecesActive = true
            else
                SFX.play('social_dm')
            end
            GAME.ecloseCard = not GAME.ecloseCard
            MSG('dark', "eI: " .. (GAME.ecloseCard and "ON" or "OFF"))
            refreshWidgets()  
            RefreshBGM(mode)
        end,
    },
    WIDGET.new { -- urm
        name = 'urm', type = 'checkBox',
        fillColor = ZCEMclr.cbFill,
        frameColor = ZCEMclr.cbFrame,
        textColor = COLOR.R, text = "Ultra Reverse",
        x = baseX + 500, y = baseY + 50 + 640,
        disp = function() return URM end,
        code = function()
            URM = not URM
            SFX.play(URM and 'exchange' or 'undo')
            GAME.hardMode = GAME.mod.EX > 0 or GAME.anyRev and not URM
            GAME.refreshLayout()
            GAME.refreshUltra()
            --GAME.refreshCurrentCombo()
            GAME.refreshPBText()
            RefreshBGM(mode)
            GAME.refreshRPC()
            RefreshHelpText()
        end,
    },
    WIDGET.new { -- Clear Button
        name = 'clear', type = 'button', 
        x = baseX + 220, y = baseY + 60 + 720, w = 410, h = 70,
        color = ZCEMclr.T,
        sound_hover = 'menutap',
        fontSize = 50, text = "CLEAR PIECES", textColor = ZCEMclr.LT,
        onClick = function()
            if anyPieceActive() or URM then
                SFX.play('allclear')
                MSG('dark', 'All Clear')
            else
                if combo == 0 or (STAT.unlockAll and ACHV.lazy_bastard) then
                    MSG.clear()
                    MSG("dark", "What do you want me to deselect?")
                    SFX.play('no')
                elseif combo < 16 then
                    local str = ''
                    for i = 1, combo do
                        str = str .. '?'
                    end
                    MSG.clear()
                    MSG("dark", str)
                    SFX.play('combo_' .. combo)
                else
                    if not ACHV.lazy_bastard then
                        IssueAchv('lazy_bastard')
                    else
                        MSG("dark", "Fine, okay, everything is unlocked now.")
                    end
                    GAME.unlockAll()
                    SFX.play('combo_16')
                end
                combo = combo + 1
                comboTimer = 3
            end
            URM = false
            GAME.nightcore = false
            GAME.slowmo = false
            GAME.glassCard = false
            GAME.fastLeak = false
            GAME.invisUI = false
            GAME.invisCard = false
            GAME.closeCard = false
            GAME.enightcore = false
            GAME.eslowmo = false
            GAME.eglassCard = false
            GAME.efastLeak = false
            GAME.einvisUI = false
            GAME.einvisCard = false
            GAME.ecloseCard = false
            GAME.multiplePiecesActive = false
            GAME.pieceEffectID = #PieceData
            GAME.hardMode = GAME.mod.EX > 0 or GAME.anyRev and not URM
            GAME.refreshLayout()
            GAME.refreshUltra()
            GAME.refreshCurrentCombo()
            GAME.refreshPBText()
            RefreshBGM(mode)
            GAME.refreshRPC()
            RefreshHelpText()
            refreshWidgets()
        end,
    },
    WIDGET.new { -- normal piece button
        name = 'help2', type = 'button', 
        x = baseX + 685, y = baseY + 60 + 720, w = 410, h = 70,
        color = ZCEMclr.T,
        sound_hover = 'menutap',
        fontSize = 50, text = "CYCLE PIECES", textColor = ZCEMclr.LT,
        onClick = function()
            GAME.pieceEffectID = (GAME.pieceEffectID or 0) % #PieceData + 1
            if GAME.pieceEffectID <= #PieceData - 1 then
                local piece = ('zsjltoi'):sub(GAME.pieceEffectID, GAME.pieceEffectID)
                SFX.play(piece, 1, 0, Tone(6))
                if GAME.pieceEffectID > 7 then
                    SFX.play('combo_'..(GAME.pieceEffectID - 7)..'_power', 1, 0, Tone(0))
                end
            else
                SFX.play('allclear')
            end

            --for i = 1, 7 do
            -- Trevor Smithy
            for i = 1, #PieceData - 1 do
                GAME[PieceData[i].id] = GAME.pieceEffectID == i
            end

            GAME.refreshLayout()
            RefreshBGM()
            GAME.refreshRPC()
            -- Trevor Smithy
            GAME.refreshCurrentCombo()
            refreshWidgets()
            GAME.multiplePiecesActive = false
            MSG({
                cat = 'dark',
                str = PieceData[GAME.pieceEffectID].popup,
                time = 1.2
            })
        end,
    },
    WIDGET.new {
        name = 'description', type = 'hint',
        pos = { 0.98, 1 }, x = 0, y = -25, w = 45, cornerR = 20,
        color = ZCEMclr.L, textColor = ZCEMclr.L,
        fontSize = 40, text = "?", -- Dynamic text
        sound_hover = 'menutap',
        labelPos = 'left',
        floatFontSize = 20,
        floatText = descriptionTable[descriptionIndex], -- Dynamic text
        onPress = function()
            local piece = love.mouse.isDown('2') or love.keyboard.isDown('lctrl', 'rctrl')
            descriptionIndex = descriptionIndex + 1
            if descriptionIndex > #descriptionTable then descriptionIndex = 1 end
            scene.widgetList.description.floatText = piece and pieceDescriptionTable[descriptionIndex] or descriptionTable[descriptionIndex]
            if descriptionIndex == 2 and bpmMode then scene.widgetList.description.floatText = "BPM: Shows current song's BPM, affected by Z/S/eZ/eS/all GVs/ueEX." end
            scene.widgetList.description:reset()
        end
    },
}

-- Apply visibility functions if not set
for _, W in next, page1 do W.visibleFunc = W.visibleFunc or pageVisFunc[1] end
for _, W in next, page2 do W.visibleFunc = W.visibleFunc or pageVisFunc[2] end
for _, W in next, page3 do W.visibleFunc = W.visibleFunc or pageVisFunc[3] end
for _, W in next, page4 do W.visibleFunc = W.visibleFunc or pageVisFunc[4] end

-- Tabs
local tab = {
    WIDGET.new {
        name = 'back', type = 'button',
        pos = { 0, 0 }, x = 60, y = 140, w = 160, h = 60,
        color = { .15, .15, .15 },
        fontSize = 30, text = "    BACK", textColor = 'DL',
        onClick = function() love.keypressed('escape') end,
    },
    WIDGET.new {
        name = 'conf', type = 'button',
        pos = { 1, 0 }, x = -60, y = 140, w = 160, h = 60,
        color = { COLOR.HEX '383838' },
        fontSize = 30, text = "CONF   ", textColor = 'DL',
        onClick = function() love.keypressed('1') end,
    },
    WIDGET.new {
        name = 'utils', type = 'button',
        pos = { 1, 0 }, x = -60, y = 230, w = 160, h = 60,
        color = { COLOR.HEX '383838' },
        fontSize = 30, text = "UTILS  ", textColor = 'DL',
        onClick = function() love.keypressed('2') end,
    },
    WIDGET.new {
        name = 'album', type = 'button',
        pos = { 1, 0 }, x = -60, y = 320, w = 160, h = 60,
        color = { COLOR.HEX '383838' },
        fontSize = 30, text = "ALBUM  ", textColor = 'DL',
        onClick = function() love.keypressed('3') end,
    },
    WIDGET.new {
        name = 'zcem', type = 'button',
        pos = { 1, 0 }, x = -60, y = 410, w = 160, h = 60,
        color = 'DG',
        sound_hover = 'menutap',
        fontSize = 30, text = "ZCEM   ", textColor = { .15, .75, .15 },
        onPress = function() love.keypressed('4') end,
        onClick = function() love.keyreleased('4') end,
    },
}

for _, W in next, page1 do if W.type == 'button' or W.type == 'checkBox' then W.sound_hover, W.sound_release = 'menutap', 'menuclick' end end
for _, W in next, page2 do if W.type == 'button' or W.type == 'checkBox' then W.sound_hover, W.sound_release = 'menutap', 'menuclick' end end
for _, W in next, page3 do if W.type == 'button' or W.type == 'checkBox' then W.sound_hover = 'menutap' end end -- Album buttons should be quiet

scene.widgetList = {}
TABLE.append(scene.widgetList, page1)
TABLE.append(scene.widgetList, page2)
TABLE.append(scene.widgetList, page3)
TABLE.append(scene.widgetList, page4)
TABLE.append(scene.widgetList, tab)

return scene
