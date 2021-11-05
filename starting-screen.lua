mov_starting = 40
function starting_screen_init()
    cam_y = 0
    player = create_object3d_string(player_v_string, player_f_string, player_m_string, 0, 0, 1000, 0, 0, 0, 7)

    objects3d = {player}
end

function update_starting_screen()
    player.ay -= 0.02
    player.ax += 0.05

    if(player.z-mov_starting > 50) player.z -= mov_starting
    if(player.z>1000) test_level_init() current_level_update = test_level_update

    if(btn(5))then
        mov_starting = -40
    end
end