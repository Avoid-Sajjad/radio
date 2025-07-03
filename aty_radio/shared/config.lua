Config = {
	OldESX = false,
    RadioProp = "prop_cs_walkie_talkie",
    AttachPropOnUse = true, -- Attach the radio to the player when using it
    DisableOnDeath = true, -- Disable the radio when the player dies
    EnableShowUsers = true, -- Enable the seeing connected users feature
    EnableRequesting = true, -- Enable the requesting feature
    UseAnimation = true, -- Use animation when using the radio

    ItemSettings = {
        RequireItem = true,
        Item = "radio",
    },

    CommandSettings = {
        Enable = true,
        Command = "radio",
    },

    HackingSettings = {
        UsbItem = "trojan_usb", -- Item required to hack
        LabtopItem = "laptop", -- Item required to hack
        HackingCoordinates = {
            {
                coords = vector4(739.2815, 1276.1788, 360.2965, 183.2185),
                hackTime = 15, -- Time in seconds to hack
            }
        },
    },

    ExamSettings = {
        Npc = {
            Enable = false,
            Coords = vector4(-267.8953, -964.2256, 31.2231, 295.3465),
            Ped = "cs_tom",
        },

        Blip = {
            Enable = false,
            Coords = vector3(-267.8953, -964.2256, 31.2231),
            Sprite = 459,
            Color = 5,
            Label = "Radio Exam",
        },

        QuestionsToPass = 4,
        ExamPrice = 5000,

        ExamQuestions = {
            {
                question = 'What is the minimum age to obtain a radio license?',
                answers = {'18', '16', '21', '14'},
                correct = '18'
            },
            {
                question = 'What is the maximum power output for a radio station?',
                answers = {'1000W', '500W', '100W', '50W'},
                correct = '100W'
            },
            {
                question = 'What is the maximum bandwidth for a radio station?',
                answers = {'100kHz', '50kHz', '20kHz', '10kHz'},
                correct = '20kHz'
            },
            {
                question = 'What is the maximum antenna height for a radio station?',
                answers = {'100m', '50m', '20m', '10m'},
                correct = '20m'
            },
            {
                question = 'What is the maximum range for a radio station?',
                answers = {'100km', '50km', '20km', '10km'},
                correct = '50km'
            },
            {
                question = 'What is the maximum number of channels for a radio station?',
                answers = {'10', '5', '3', '1'},
                correct = '5'
            }
        },
    },

    LockedChannels = {
        {
            name = "police",
            jobs = {"police", "sheriff", "ambulance"},
            frequency = 1,
            accepterGrade = 2 -- Minimum grade to accept the request
        },
        {
            name = "sheriff",
            jobs = {"police", "sheriff", "ambulance"},
            frequency = 2,
            accepterGrade = 2 -- Minimum grade to accept the request
        },
        {
            name = "ambulance",
            jobs = {"police", "sheriff", "ambulance"},
            frequency = 3,
            accepterGrade = 2 -- Minimum grade to accept the request
        },
        {
            name = "fib",
            jobs = {"fib", "police"},
            frequency = 4,
            accepterGrade = 2 -- Minimum grade to accept the request
        },
    },

    Notify = function(message, title, type)
        TriggerEvent("QBCore:Notify", message, type)
    end,

    HackDispatch = function(serverId, ped, frequency)
        -- You can use this function to dispatch the hacking to the police department
    end
}