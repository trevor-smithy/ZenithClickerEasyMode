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
            { set = "eASeDHeGVeINeMSeNHeVLrEX", name = '"ULTRA HARD BATH WATER"', customUltraCombo = true, peasantRevolution = true},
            { set = "eDHeEXeGVrNH", name = '"HOLY ASCENSION"', customUltraCombo = true},
            { set = "eDPeEXeINrMS", name = '"STABILIZED ENTROPY"', customUltraCombo = true},
            { set = "eASeDPeEXrGV", name = '"RESTRAINED COLLAPSE"', customUltraCombo = true},
            { set = "eDHeEXeGVrVL", name = '"RESTORED VOLITION"', customUltraCombo = true},
            { set = "eEXeINeMSrDH", name = '"DISPROVEN BLASPHEMY"', customUltraCombo = true},
            { set = "eASeEXeNHrIN", name = '"SOLVED PARADOX"', customUltraCombo = true},
            { set = "eEXeNHeVLrAS", name = '"DEMYSTIFIED GRIMOIRE"', customUltraCombo = true},
            { set = "eEXeMSeVLrDP", name = '"LASTING EDEN"', customUltraCombo = true},
            -- Misc
            { set = "eASeDHeDPeGVeINeMSeNHeVLrEX", name = '"ULTRA HARD BATH WITH A FRIEND"'},
            { set = "eASeDHeEXeGVeINeMSeNHeVLrDP", name = '"BATH WITH A STALKER"'},
            { set = "eDHeDPeGVeINeMSeNHrASrEXrVL", name = '"THE WHELMED SMITHY"'},
            { set = "eASeDHeEXrGV", checks = {'enightcore', false}, name = '"PATIENCE IS A VIRTUE..."'},
            { set = "eASeDHeEXrGV", checks = {'enightcore', true}, name = [["BUT IT ISN'T ONE OF MINE"]], customUltraCombo = true},
            -- No Named Rev Equivalent
            { set = "rASrDHrDPrEXrGVrINrMSrNHrVL", checks = {'badTime', true, 'badTimeStarted', false}, name = '"BAD TIME"', customUltraCombo = true},
            { set = "eASeDHeDPeGVeINeMSeNHrEX", checks = {'ecloseCard', true}, name = '"ULTRA HARD CRAMPED BATH WITH A FRIEND"'},
            -- Double ultras
            { set = "eEXeGVeINeMSrDHrNH", name = '"BLASPHEMOUS ASCENSION"', forceRev = true, customUltraCombo = true},
            { set = "eASeDPeEXeNHrINrMS", name = '"PARADOXICAL ENTROPY"', forceRev = true, customUltraCombo = true},
            { set = "eDPeEXeNHeVLrASrGV", name = '"DEPRAVED GALAXY"', forceRev = true, customUltraCombo = true},
            { set = "eDHeEXeGVeMSrDPrVL", name = '"SEVERED VOLITION"', forceRev = true, customUltraCombo = true},
            -- Smithy
            { set = "eASeEXeVLrDHrDPrGVrINrMSrNH", name = '"THE PARALYZED SMITHY"'},
        },
        uneasy = {
            { set = "DPeASeDHeEXeGVeINeMSeNHeVL", name = '"BATH WITH A LOVER?"'},
            { set = "DHDPGVINMSNHeASeEXeVL", name = '"THE BOGGED-DOWN SMITHY"'},
            { set = "ASNHeEX", name = '"THE PIXEL ARTIST"'}, -- Credit: LovelyStar
            { set = "eASeDHeEXeGVeINeMSeNHeVL", name = '"HARD BATH WATER"'},
            { set = "eASeDHeDPeEXeGVeINeMSeNHeVL", name = '"HARD BATH WITH A FRIEND"'},
            { set = "eEX", name = 'UNEASY'},
            { set = "eEXeNH", checks = {'glassCard', true}, name = '"PROFLIGACY"'},
            { set = "eEXeMS", checks = {'slowmo', true}, name = '"DIOGENES SYNDROME"'},
            { set = "eEXeGV", checks = {'slowmo', true}, name = '"DYSANIA"'},
            { set = "eEXeVL", checks = {'closeCard', true}, name = '"SUBLUXATION"'},
            { set = "eDHeEX", checks = {'nightcore', true}, name = '"LIMBO"'},
            { set = "eEXeIN", checks = {'invisCard', true}, name = '"PRESBYOPIA"'},
            { set = "eASeEX", checks = {'fastLeak', true}, name = '"CARPAL TUNNEL"'},
            { set = "eDPeEX", checks = {'invisUI', true}, name = '"PROSOPAGNOSIA"'},
            { set = "eDHeEXeMSeVL", name = '"UNPROFESSIONAL CLEANER"'},
            { set = "eEXeGV", {'slowmo', false}, name = '"UNCOMFORTABLE BED"'},
            { set = "eEXeVL", checks = {'closeCard', false}, name = '"UNPROFESSIONAL WEIGHTLIFTER"'},
            { set = "eEXeIN", checks = {'invisCard', false}, name = '"IMPERFECT VISION"'},
            { set = "eDPeEX", checks = {'invisUI', false}, name = '"BEST FRIENDS?"'},
            { set = "eASeDHeEXeMSeNHeVL", name = '"THE GAMER TRINITY"'},
            -- Smithy
            { set = "eASeEXeVL", name = '"THE UNEASY SMITHY"'},
        },
        other = {
            { set = "eASeDHeEXrGV", checks = {'enightcore', true}, name = [["BUT IT ISN'T ONE OF MINE"]]},
            -- Smithy
            { set = "DHDPGVINMSNHeASeEXeVL", name = '"THE SWAMPED SMITHY"'},
            { set = "eDHeDPeGVeINeMSeNHrASrEXrVL", name = '"THE UNDERWHELMED SMITHY"'},
            { set = "eASeEXeVLrDHrDPrGVrINrMSrNH", name = '"THE OVERWHELMED SMITHY"'},
        }
    }
}

return d