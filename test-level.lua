-- 0,1,3,4,5,6,7,8,9,10,11,12,14
-- 138->2,140->13

-- ground = 3,

function test_level_init()
    current_cam_tile_offset_x = (cam_x%terrain_ts)/terrain_ts
    current_cam_tile_offset_z = (cam_z%terrain_ts)/terrain_ts

    pal(2, 138, 1)
    pal(13, 140, 1)
    
    print(((terrain_mesh_nc-1)*terrain_ts)/2)
    indicator_object = create_sprite3d(terrain_mx, 0, ((terrain_mesh_nc-1)*terrain_ts)/2, function(x,y) circfill(x-1,y+1,1,9) end)
    sprites3d = {indicator_object}
end

function test_level_update()
    last_cam_tile_offset_x = current_cam_tile_offset_x
    last_cam_tile_offset_z = current_cam_tile_offset_z

    if(btn(0))then
        indicator_object.x -= 1
    end

    if(btn(1))then
        indicator_object.x += 1
    end

    if(btn(2))then
        indicator_object.z += 1
    end

    if(btn(3))then
        indicator_object.z -= 1
    end

    cam_x = indicator_object.x
    cam_z = indicator_object.z - terrain_ms/2

    current_cam_tile_offset_x = (cam_x%terrain_ts)/terrain_ts
    current_cam_tile_offset_z = (cam_z%terrain_ts)/terrain_ts


end 