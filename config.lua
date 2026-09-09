Config = {}

-- 👨‍💼 PED SETTINGS
Config.Ped = {
    model = 'a_m_m_business_01', -- ped model
    coords = vector4(-690.566, -2281.183, 13.027, 138.694)
}

-- 🎯 INTERACTION
Config.UseTarget = true -- use ox_target
Config.DrawText = true  -- fallback text

-- ⏳ OPEN TIME (ms)
Config.OpenTime = 4000

-- 🔒 SQL (anti-duplicate)
Config.UseSQL = true

-- 🧾 DISCORD LOGS
Config.DiscordWebhook = "" -- Put webhook or leave empty

-- 🎁 STARTER REWARDS
Config.StarterItems = {
    { item = "phone", amount = 1 },
    { item = "water", amount = 5 },
    { item = "sandwich", amount = 5 },
    { item = "cash", amount = 50000 }
}

-- 💰 MONEY HANDLING
Config.MoneyAsItem = true 
-- true = gives "cash" item
-- false = gives real money (bank/cash depending framework)

-- 🔔 NOTIFY SETTINGS
Config.Notify = {
    ClaimMessage = "You received a Starter Box!",
    OpenMessage = "Starter box opened!",
    AlreadyClaimed = "You already claimed your starter box!",
    CancelMessage = "Opening canceled"
}

-- 🎬 CINEMATIC SETTINGS
Config.Cinematic = {
    Enabled = true,

    BoxProp = 'prop_cs_cardbox_01',

    SpawnDistance = 0.8, -- how far in front of player

    Animation = {
        dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer"
    }
}

Config.ClaimAnim = {
    Enabled = true,

    Dict = "mp_common",
    PedAnim = "givetake1_a",    
    PlayerAnim = "givetake1_b", 

    Duration = 2000 -- ms
}

-- 🧠 DEBUG MODE
Config.Debug = false