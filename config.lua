config = {
    debugClient = false, -- Activer/Désactiver les logs de débogage côté client
    debug = true,        -- Activer/Désactiver les logs de débogage côté serveur
    delay = 5000,      -- Délai entre les détections de radar pour un même joueur (en ms)
    maxDistance = 50.0, -- Distance maximale pour détecter un radar (en mètres)
    finePerKmh = 17,     -- Montant de l'amende par km/h au-dessus de la limite
    radarPoints = {
        -- Format: {x = coordX, y = coordY, z = coordZ, heading = direction}
        { position = vector4(170.0, -779.0, 31.0, 315.0), speedlimit = 100} ,         -- Radar PC
        { position = vector4(-2.4, -941.0, 29.3, 117.0), speedlimit = 100 },          -- Radar Chantier
        { position = vector4(1208.0, -1402.0, 35.2, 90.0), speedlimit = 100 },        -- Radar boulevard
        { position = vector4(2506.0, 4145.0, 38.1, 240.0), speedlimit = 100 },        -- Radar route rurale
        { position = vector4(263.2, -1882.3, 26.8, 320.0), speedlimit = 100 },        -- Radar Davis
        { position = vector4(-913.4, 5423.9, 36.5, 120.0), speedlimit = 100 },        -- Radar North Highway
        { position = vector4(1688.4, 1340.5, 87.5, 180.0), speedlimit = 100 },        -- Radar Route Est
        { position = vector4(-2963.4, 482.8, 15.3, 90.0), speedlimit = 100 },         -- Radar Pacific Bluffs
        { position = vector4(2557.9, 349.8, 108.6, 175.0), speedlimit = 100 },        -- Radar Tataviam Sud
        { position = vector4(-1816.8, 843.5, 138.7, 130.0), speedlimit = 100 },       -- Radar Vinewood Hills
        { position = vector4(1691.5, 6425.6, 32.5, 65.0), speedlimit = 100 },         -- Radar Route Nord
        { position = vector4(1413.2, 3619.8, 34.9, 200.0), speedlimit = 100 },        -- Radar Sandy Shores Est
        { position = vector4(-2237.2, 4275.6, 47.8, 150.0), speedlimit = 100 },       -- Radar Cassidy Trail
        { position = vector4(2368.5, 2856.7, 40.1, 60.0), speedlimit = 100 },         -- Radar Route 68 Est
        { position = vector4(-367.8, 4385.2, 58.1, 245.0), speedlimit = 100 },        -- Radar Raton Canyon
        { position = vector4(-402.9, -514.5, 25.1, 354.8), speedlimit = 100 }         -- Autoroute (traitre)
    },
}

