
function thaResourceStarting( )
   --              3 koordináta bal alsó   3 jobb sarok koordínáta 3 bal felső sarok  3 jobb felső sarok
    water1 = createWater(-2951, -2998, 0,  768.26654052734, -2980.0922851562, 0, -2951, 681, 0, 2997, 681, 0)
    setWaterLevel(water1,0)
    water3 = createWater(676.14593505859, -2828.9460449219, 0, 2955.9890136719, -2800.5632324219, 0, 676.14593505859, 564.71948242188, 0, 2981.3305664062, 564.71948242188, 0)
    setWaterLevel(water3,0)
   -- water = createWater(-2980.1962890625, -2805.0942382812, 0,234.03019714355, -2838.3083496094, 0,-454.95684814453, 452.8450012207, 0)
end
addEventHandler("onClientResourceStart", resourceRoot, thaResourceStarting)

function thaResourceStarting( )
  -- bal szarok, jobb sarok, bal felső, jobb felső
  water2 = createWater(-2998, -2998, 0, -1188, -2998, 0, -2998, 1553, 0, -1188, 1553,0)
  water4 = createWater(-2828.9460449219, -2828.9460449219, 0, 2955.9890136719, -2828.9460449219, 0, -2828.9460449219, 564.71948242188, 0, 2955.9890136719, 564.71948242188, 0)
end
addEventHandler("onClientResourceStart", resourceRoot, thaResourceStarting)