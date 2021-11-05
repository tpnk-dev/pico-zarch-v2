-- 0,1,3,4,5,6,7,8,9,10,11,12,14
-- 138->2,140->13

-- ground = 3,
player_thruster = -0.2
player_thruster_size = 0
player_thruster_timer = 0


function test_level_init()
    draw_terrain=true
    current_cam_tile_offset_x = (cam_x%terrain_ts)/terrain_ts
    current_cam_tile_offset_z = (cam_z%terrain_ts)/terrain_ts

    player = create_object3d_string(player_v_string, player_f_string, player_m_string, terrain_mx, -integer_list[mov_tiles_z_trunc][mov_tiles_x_trunc]*10, ((terrain_mesh_nv-1)*terrain_ts)/2, 0, 0, 0.5, 6)
    player_shadow = create_object3d_string(player_shadow_v_string, player_shadow_f_string, player_shadow_m_string, terrain_mx, 1, ((terrain_mesh_nv-1)*terrain_ts)/2, 0, 0, 0.5, 7) 

    
    --player_thruster = create_sprite3d(player.x, player.y, player.z, function(x,y) end)

    sprites3d = {}
    objects3d = {player_shadow,player}
end

function thruster_particles()
    local dy = cos(player.ax)*-cos(player.az)
    local dx = sin(player.ay)*sin(player.ax)
    local dz = -cos(player.ay)*sin(player.ax)

    --local particle_position

    --print(sprite)
    for i=0, 2 do
        add(sprites3d, create_sprite3d(player.x+dx*-20+rnd(6)-3, player.y+dy*20, player.z+dz*-20+rnd(6)-3, function(sprite) update_particle(sprite, function(sx,sy,z) rectfill(sx, sy, sx,sy, flr(1/(sprite.life_span*3))%3+7 + rnd(1)) end, 0, player) end, -dx*10 + rnd(4)-2,-dy*10+ rnd(4)-2,-dz*10 + rnd(4)-2, 8, 0.5))
    end
    --[[
    if(sprite.sx > 0 and sprite.sx < 128) then
        if(player_thruster_timer > 0) then
            for i=0, 20 do
                dx = flr((player_thruster_object_origin.y - player.y)/3)
                pset(i*(sprite.sx-player_thruster_object_origin.sx)/20 + (rnd((flr(i/2)+dx))-(0.5*(flr(i/2)+dx))) + player_thruster_object_origin.sx, i*(sprite.sy-player_thruster_object_origin.sy)/20 + player_thruster_object_origin.sy + rnd(flr(i/2)), i%3 + 7)
            end
        end
    end
    --line(x+rnd(10),y+rnd(10),player_thruster_object_destination.sx+rnd(10),player_thruster_object_destination.sy+rnd(10),2,8)
    --]]
end

function indicator_update()
    if(btn(0))then
        player.x -= 3
    end

    if(btn(1))then
        player.x += 3
    end

    if(btn(2))then
        player.z += 3
    end

    if(btn(3))then
        player.z -= 3
    end

    cam_x = player.x
    cam_z = player.z - terrain_mesh_s/2 - 50

    cam_y = -30 
end

function update_particle(sprite, draw_func, gravity, object_occlusion)
   -- print(sprite.vy)
    if(sprite.y - sprite.vy < ground_y_player)then
        sprite.x += sprite.vx
        
        sprite.y -= sprite.vy
        sprite.z += sprite.vz
        sprite.vy -= gravity or 0
        --print(gravity)
    else
        sprite.vy *= -0.1
        sprite.vx *= 0.2
        sprite.vz *= 0.2
        
        --sprite.y -= sprite.vy
        sprite.y = ground_y_player
    end
    --)
    --stop(

    
    draw_func(sprite.sx, sprite.sy, sprite.z, sprite.color)
end

function update_bullet(sprite, draw_func)
    if(sprite.y + sin(sprite.vx) * 10 < ground_y_player)then
        --print(sin(player.ax))
        sprite.x += -sin(sprite.vy)*cos(sprite.vx) * 10
        sprite.z += cos(sprite.vy)*cos(sprite.vx) * 10
        sprite.y += -sin(sprite.vx) * 10
    end

    --sprite.z -= flr(sprite.vy/0.5) * 10
    
    draw_func(sprite.sx, sprite.sy, sprite.z, sprite.color)
end

function explode()
    deli(objects3d, 1)
    deli(objects3d, 1)
    for i=0, 5 do
        add(sprites3d, create_sprite3d(player.x, player.y, player.z, function(sprite) update_particle(sprite, function(sx,sy,z) spr(0, sx, sy, z, 10) end, 1) end, rnd(20)-10,8,rnd(20)-10))
    end

    for i=0, 100 do
        add(sprites3d, create_sprite3d(player.x, player.y, player.z, function(sprite) update_particle(sprite, function(sx,sy,z,color) circfill(sx, sy, 0, i%3+4) end, 1) end, rnd(10)-5,rnd(10)+5,rnd(20)-10))
    end
end

function test_level_update()
    --integer_list[mov_tiles_z_trunc][mov_tiles_x_trunc] = 20
    
    if(player.y <= ground_y_player)then
        dx = cos(player.ay)*cos(player.ax)
        dy = sin(player.ay)*cos(player.ax)
        dz = sin(player.ax)

        player.y += player.vy
        player.x -= player.vx
        player.z -= player.vz

        player.vy += 0.05
        --player.vx -= 0.005
        --player.vz -= 0.005
        
        --player_thruster -= 0.005
        --if player_thruster < 0 then 
        --    player_thruster = 0
        --end
        if(player.y < 0)then
            if(btn(0))then
            player.ay -= 0.03
            end

            if(btn(1))then
                player.ay += 0.03
            end

            if(btn(2))then
                if(player.ax + 0.01 < 0.5) player.ax += 0.02
            end

            if(btn(3))then
                if(player.ax - 0.01 > 0) player.ax -= 0.02
            end
        end
    else
        if((player.vy^2 + player.vy^2 + player.vz^2)/3 > 2) explode()
        player.y = ground_y_player
        player.vx = 0
        player.vy = 0
        player.vz = 0
    end

   -- player.x = player.x%terrain_s
    --player.z = player.z%terrain_s

    player_shadow.x = player.x
    player_shadow.z = player.z + 1
    player_shadow.y = ground_y_player
    player_shadow.ay = player.ay
    if(player.ax < 0.04) player_shadow.ax = player.ax

    local pressed_thruster = false
    if(btn(4))then
        thruster_particles()
        --sprites3d[2] = player_thruster_object_origin
        pressed_thruster = true
        player.vy += player_thruster*cos(player.ax)*-cos(player.az)
        player.vx += player_thruster*sin(player.ay)*sin(player.ax)
        player.vz += player_thruster*-cos(player.ay)*sin(player.ax)
    end

    cam_x = player.x
    cam_z = player.z - terrain_mesh_s/2 - 50
    if(player.y < -80)then
        cam_y = player.y - 10
    else   
        cam_y = -90 
    end

    if(btn(5))then
        add(sprites3d, create_sprite3d(player.x, player.y, player.z, function(sprite) update_bullet(sprite, function(sx,sy,z,color) circfill(sx, sy, 0, 7) end) end, player.ax, player.ay, player.az))
    end
end 