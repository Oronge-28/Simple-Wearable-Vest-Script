Config = {}

-- Framework-Optionen: 'auto' (erkennt ESX oder QBCore automatisch), 'esx', 'qb', oder 'standalone'
Config.Framework = 'auto'

-- Animations-Einstellungen zum An-/Ausziehen der Weste
Config.AnimDict = 'clothingtie'
Config.AnimName = 'try_tie_neutral_a'
Config.AnimDuration = 4000 -- Dauer in Millisekunden (4 Sekunden)

-- Westen-Konfigurationen
Config.Vests = {
    ['bulletproof'] = {
        label = 'Kevlarweste (50%)',
        armor = 50,             -- Rüstungswert (0 bis 100)
        remove = true,          -- Item beim Benutzen löschen
        giveNobproof = true,    -- Spieler erhält das "nobproof" Item beim Anziehen
        -- Visuelle Rüstungsvariation (Komponente 9 ist Schutzweste in GTA V)
        maleProp = { drawable = 11, texture = 1 },   -- Standard GTA V MP männlich Weste
        femaleProp = { drawable = 11, texture = 1 }  -- Standard GTA V MP weiblich Weste
    },
    ['bulletproof2'] = {
        label = 'Schwere Kevlarweste (75%)',
        armor = 75,
        remove = true,
        giveNobproof = true,
        maleProp = { drawable = 12, texture = 0 },   -- Schwere Weste
        femaleProp = { drawable = 12, texture = 0 }
    },
    ['bulletproofpolice'] = {
        label = 'Polizei-Schutzweste (100%)',
        armor = 100,
        remove = true,
        giveNobproof = true,
        maleProp = { drawable = 16, texture = 2 },   -- Taktische Weste
        femaleProp = { drawable = 16, texture = 2 }
    },
    ['nobproof'] = {
        label = 'Weste ablegen',
        armor = 0,              -- Setzt Rüstung auf 0
        remove = true,          -- Entfernt das nobproof Item beim Benutzen
        giveNobproof = false,   -- Gibt kein neues Item
        maleProp = { drawable = 0, texture = 0 },     -- Entfernt die Weste visuell (0 = nackter Oberkörper / keine Weste)
        femaleProp = { drawable = 0, texture = 0 }
    }
}

-- Übersetzungstabelle
Config.Locale = 'de'
Config.Locales = {
    ['de'] = {
        ['putting_on'] = 'Schutzweste wird angelegt...',
        ['taking_off'] = 'Schutzweste wird abgelegt...',
        ['finished_putting_on'] = 'Schutzweste erfolgreich angelegt!',
        ['finished_taking_off'] = 'Schutzweste erfolgreich abgelegt.',
        ['already_max_armor'] = 'Deine Rüstung ist bereits besser oder gleichwertig!',
        ['no_armor_to_remove'] = 'Du trägst keine Schutzweste, die du ablegen könntest!',
        ['action_cancelled'] = 'Aktion abgebrochen!'
    }
}

-- Benachrichtigungstyp: 'sc_hud' (oder 'custom'), 'esx' oder 'ox_lib'
Config.NotifyType = 'sc_hud'

-- Custom Notify Funktion (wird aufgerufen, wenn Config.NotifyType = 'sc_hud' oder 'custom' ist)
Config.CustomShowNotification = function(msg, type, title)
    local t = type or 'info'
    if type == 'primary' then t = 'info' end
    local titleStr = title or 'Schutzwesten'
    exports['sc_hud']:Notification(titleStr, msg, t, 5000)
end

-- Hauptbenachrichtigungsfunktion (wählt basierend auf Config.NotifyType)
Config.ShowNotification = function(msg, type, title)
    local t = type or 'info'
    if type == 'primary' then t = 'info' end
    local titleStr = title or 'Schutzwesten'

    if Config.NotifyType == 'ox_lib' then
        lib.notify({
            title = titleStr,
            description = msg,
            type = t
        })
    elseif Config.NotifyType == 'esx' then
        TriggerEvent('esx:showNotification', msg)
    else
        -- Fallback zu Custom / sc_hud
        Config.CustomShowNotification(msg, type, title)
    end
end

-- Helper-Funktion für Übersetzungen
function t(key, ...)
    local activeLocale = Config.Locales[Config.Locale] or Config.Locales['de']
    local str = activeLocale[key] or key
    return string.format(str, ...)
end
