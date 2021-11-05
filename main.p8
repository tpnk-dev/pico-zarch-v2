pico-8 cartridge // http://www.pico-8.com
version 33
__lua__

#include hex_base64_decoder.lua
#include pico-zarch-engine-v2.lua
#include perlin-noise.lua
#include models.lua
#include starting-screen.lua
#include test-level.lua


function _init()
    srand(5)
    generate_cam_matrix_transform(cam_ax, cam_ay, cam_az)

    cls()
    splash = explode64(splash_rle)

    draw_rle(splash,0,0)
    
    print(explode_hex(player_v_string, ",")[2])

    pal(2, 139, 1)
    pal(13, 140, 1)

    draw_terrain = false
    current_level_update = update_starting_screen
    integer_list = {}
    color_terrain = {}
    size = terrain_nc

   create_terrain_string(terrain_rle)
   -- create_list()
   -- noise(4)
   -- noise(1)
    recolor()
    
    --test_level_init()
    --test_level_init()
    starting_screen_init()
end

function _update()   
    if(time() > 2) then
        current_level_update()
    end
end

function _draw()
    if(time() > 2) then
        cls()

        update_3d()

        if(draw_terrain) render_terrain() draw_3d() render_gui() else draw_3d() rectfill( 0, 0, 128, 8, 6 ) print('prion',12,2,8) print('marcospiv 2021',47,2,7) print('🅾️ to thrust and ❎ to shoot',8,100,8) print('<press ❎ to continue>',20,110,7)

       -- print(player.ax, 1, 90, 9)
       -- print(mov_tiles_z_trunc, 1, 90, 9)
       -- print(integer_list[mov_tiles_z_trunc][mov_tiles_x_trunc])
    end
end


__gfx__
00000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
