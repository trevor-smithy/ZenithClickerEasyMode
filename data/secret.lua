----------------------------------------------------------------------
--                        SPOILER WARNING                           --
-- This file contains contents that may spoil your game experience. --
-- Be sure you've finished the game, including Ultra Reversed Mods  --
--                     Read at your own risk.                       --
----------------------------------------------------------------------
local d = {
    combos = {
        ultra = {
            -- Custom Ultras
            { set = "eAS eDH eGV eIN eMS eNH eVL rEX", name = '"ULTRA HARD BATH WATER"', customUltraCombo = true, peasantRevolution = true},
            { set = "eDH eEX eGV rNH", name = '"HOLY ASCENSION"', customUltraCombo = true},
            { set = "eDP eEX eIN rMS", name = '"STABILIZED ENTROPY"', customUltraCombo = true},
            { set = "eAS eDP eEX rGV", name = '"RESTRAINED COLLAPSE"', customUltraCombo = true},
            { set = "eDH eEX eGV rVL", name = '"RESTORED VOLITION"', customUltraCombo = true},
            { set = "eEX eIN eMS rDH", name = '"DISPROVEN BLASPHEMY"', customUltraCombo = true},
            { set = "eAS eEX eNH rIN", name = '"SOLVED PARADOX"', customUltraCombo = true},
            { set = "eEX eNH eVL rAS", name = '"DEMYSTIFIED GRIMOIRE"', customUltraCombo = true},
            { set = "eEX eMS eVL rDP", name = '"LASTING EDEN"', customUltraCombo = true},
            -- Misc
            { set = "eAS eDH eDP eGV eIN eMS eNH eVL rEX", name = '"ULTRA HARD BATH WITH A FRIEND"'},
            { set = "eAS eDH eEX eGV eIN eMS eNH eVL rDP", name = '"BATH WITH A STALKER"'},
            { set = "eAS eDH eEX rGV", checks = {'canBeRandomlySelected', false, 'enightcore', false}, name = '"PATIENCE IS A VIRTUE..."'},
            { set = "eAS eDH eEX rGV", checks = {'enightcore', true}, name = [["BUT IT ISN'T ONE OF MINE"]], customUltraCombo = true},
            -- No Named Rev Equivalent
            { set = "rAS rDH rDP rEX rGV rIN rMS rNH rVL", checks = {'badTime', true, 'badTimeStarted', false}, name = '"BAD TIME"', customUltraCombo = true},
            { set = "eAS eDH eDP eGV eIN eMS eNH rEX", checks = {'ecloseCard', true}, name = '"ULTRA HARD CRAMPED BATH WITH A FRIEND"'},
            -- Double ultras
            { set = "eEX eGV eIN eMS rDH rNH", name = '"BLASPHEMOUS ASCENSION"', forceRev = true, customUltraCombo = true},
            { set = "eAS eDP eEX eNH rIN rMS", name = '"PARADOXICAL ENTROPY"', forceRev = true, customUltraCombo = true},
            { set = "eDP eEX eNH eVL rAS rGV", name = '"DEPRAVED GALAXY"', forceRev = true, customUltraCombo = true},
            { set = "eDH eEX eGV eMS rDP rVL", name = '"SEVERED VOLITION"', forceRev = true, customUltraCombo = true},
            -- Triple Ultras: Whelmed Smithy is below
            { set = "eAS eDP eEX eGV eIN eVL rDH rMS rNH", name = '"DEAD ON ARRIVAL"', forceRev = true, customUltraCombo = true},
            { set = "eAS eDH eEX eMS eNH eVL rDP rGV rIN", name = '"EPIC GRANDMASTER DUEL"', forceRev = true, customUltraCombo = true},
            -- Quadruple Ultras
            --nh ms dh in, ex gv vl as
            {set = "eAS eEX eGV eVL rDH rIN rMS rNH", name = '"GUESSING GAME"', forceRev = true, customUltraCombo = true},
            {set = "eDH eIN eMS eNH rAS rEX rGV rVL", name = '"FINAL DEVELOPMENT"', forceRev = true, customUltraCombo = true},
            -- Ultimate Challenge
            {set = "eEX rAS rDH rGV rIN rMS rNH rVL",    name = '"ULTIMATE CHALLENGE"', forceRev = true, customUltraCombo = true, ultimateChallenge = true},
            {set = "eDP eEX rAS rDH rGV rIN rMS rNH rVL", name = '"FRIENDLY CHALLENGE"', forceRev = true, customUltraCombo = true, ultimateChallenge = true},
            -- Smithy
            { set = "eDH eDP eGV eIN eMS eNH rAS rEX rVL", name = '"THE WHELMED SMITHY"', forceRev = true, customUltraCombo = true},
            { set = "eAS eEX eVL rDH rDP rGV rIN rMS rNH", name = '"THE PARALYZED SMITHY"', forceRev = true, customUltraCombo = true},
        },
        uneasy = {
            { set = "DP eAS eDH eEX eGV eIN eMS eNH eVL", name = '"BATH WITH A LOVER?"'},
            { set = "DH DP GV IN MS NH eAS eEX eVL", name = '"THE BOGGED-DOWN SMITHY"'},
            { set = "AS NH eEX", name = '"THE PIXEL ARTIST"'}, -- Credit: LovelyStar
            { set = "eAS eDH eEX eGV eIN eMS eNH eVL", name = '"HARD BATH WATER"'},
            { set = "eAS eDH eDP eEX eGV eIN eMS eNH eVL", name = '"HARD BATH WITH A FRIEND"'},
            { set = "eEX", name = 'UNEASY'},
            { set = "eEX eNH", checks = {'glassCard', true}, name = '"PROFLIGACY"'},
            { set = "eEX eMS", checks = {'slowmo', true}, name = '"DIOGENES SYNDROME"'},
            { set = "eEX eGV", checks = {'slowmo', true}, name = '"DYSANIA"'},
            { set = "eEX eVL", checks = {'closeCard', true}, name = '"SUBLUXATION"'},
            { set = "eDH eEX", checks = {'nightcore', true}, name = '"LIMBO"'},
            { set = "eEX eIN", checks = {'invisCard', true}, name = '"PRESBYOPIA"'},
            { set = "eAS eEX", checks = {'fastLeak', true}, name = '"CARPAL TUNNEL"'},
            { set = "eDP eEX", checks = {'invisUI', true}, name = '"PROSOPAGNOSIA"'},
            { set = "eDH eEX eMS eVL", name = '"UNPROFESSIONAL CLEANER"'},
            { set = "eEX eGV", checks = {'canBeRandomlySelected', false, 'slowmo', false}, name = '"UNCOMFORTABLE BED"'},
            { set = "eEX eVL", checks = {'canBeRandomlySelected', false, 'closeCard', false}, name = '"UNPROFESSIONAL WEIGHTLIFTER"'},
            { set = "eEX eIN", checks = {'canBeRandomlySelected', false, 'invisCard', false}, name = '"IMPERFECT VISION"'},
            { set = "eDP eEX", checks = {'canBeRandomlySelected', false, 'invisUI', false}, name = '"BEST FRIENDS?"'},
            { set = "eAS eDH eEX eMS eNH eVL", name = '"THE GAMER TRINITY"'},
            -- Smithy
            { set = "eAS eEX eVL", name = '"THE UNEASY SMITHY"'},
        },
        other = {
            { set = "eAS eDH eEX rGV", checks = {'ultraIfRandom', true, 'enightcore', true}, name = [["BUT IT ISN'T ONE OF MINE"]]},
            -- Smithy
            { set = "DH DP GV IN MS NH eAS eEX eVL", name = '"THE SWAMPED SMITHY"'},
            { set = "eDH eDP eGV eIN eMS eNH rAS rEX rVL", name = '"THE UNDERWHELMED SMITHY"'},
            { set = "eAS eEX eVL rDH rDP rGV rIN rMS rNH", name = '"THE OVERWHELMED SMITHY"'},
        }
    }
}

return d