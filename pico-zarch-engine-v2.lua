last_time = time()

triangle_list = {}

--matricial represetntation of terrain vertices

objects3d = {}
objects3d_drawn = {}

sprites3d = {}
sprites3d_drawn = {}

objects3d_to_draw = {}

sector_colors = {}

terrain_ns = 25
terrain_ts = 30

terrain_mesh_faces = 10
terrain_mesh_nv = terrain_mesh_faces+1
terrain_mesh_s = terrain_mesh_faces*terrain_ts 

terrain_nc = terrain_mesh_faces*terrain_ns
terrain_s = terrain_mesh_faces*terrain_ts*terrain_ns

terrain_mx = ((terrain_mesh_nv-1)*terrain_ts)/2
--
k_screen_scale=80
k_x_center=64
k_y_center=64

z_clip=1000
z_max=15

cam_dist_terrain = 10 + terrain_ts/2
cam_x,cam_y,cam_z = 0,-40,-cam_dist_terrain
cam_ax, cam_ay, cam_az = -0.02,0,0

--

mov_tiles_x = 0
mov_tiles_z = 0

mov_tiles_x_trunc = 0
mov_tiles_z_trunc = 0

sub_mov_x = 0
sub_mov_z = 0

ground_y_player = 0

last_sector = 0

function cam_transform_object(object)
    --if(object.visible)then
    for i=1, #object.verts do
        local vertex=object.t_verts[i]

        vertex[1]+=object.x - cam_x
        vertex[2]+=object.y - cam_y
        vertex[3]+=object.z - cam_z
        
        vertex[1],vertex[2],vertex[3]=rotate_cam_point(vertex[1],vertex[2],vertex[3])
    
    end
    --end
end

function generate_matrix_transform(xa,ya,za)
    local sx=sin(xa)
    local sy=sin(ya)
    local sz=sin(za)
    local cx=cos(xa)
    local cy=cos(ya)
    local cz=cos(za)
   
    mat00=cz*cy
    mat10=-sz
    mat20=cz*sy
    mat01=cx*sz*cy+sx*sy
    mat11=cx*cz
    mat21=cx*sz*sy-sx*cy
    mat02=sx*sz*cy-cx*sy
    mat12=sx*cz
    mat22=sx*sz*sy+cx*cy
end

function rotate_point(x,y,z)   
    return (x)*mat00+(y)*mat10+(z)*mat20,(x)*mat01+(y)*mat11+(z)*mat21,(x)*mat02+(y)*mat12+(z)*mat22
end

function rotate_cam_point(x,y,z)
    return (x)*cam_mat00+(y)*cam_mat10+(z)*cam_mat20,(x)*cam_mat01+(y)*cam_mat11+(z)*cam_mat21,(x)*cam_mat02+(y)*cam_mat12+(z)*cam_mat22
end

function generate_matrix_transform_y(xa,ya,za)
    --local sx=sin(xa)
    local sy=-sin(ya)
    --local sz=sin(za)
    --local cx=cos(xa)
    local cy=cos(ya)
    --local cz=cos(za)

	mat00=cy
	mat01=0
	mat02=sy

	mat10=0
	mat11=1
	mat12=0

	mat20=-sy
	mat21=0
	mat22=cy
   
    --mat00=cz*cy
    --mat10=-sz
    --mat20=cz*sy
    --mat01=cx*sz*cy+sx*sy
    --mat11=cx*cz
    --mat21=cx*sz*sy-sx*cy
    --mat02=sx*sz*cy-cx*sy
    --mat12=sx*cz
    --mat22=sx*sz*sy+cx*cy
end

function generate_matrix_transform_x(xa,ya,za)
    local sx=sin(xa)
   -- local sy=sin(ya)
    --local sz=sin(za)
    local cx=cos(xa)
    --local cy=cos(ya)
    --local cz=cos(za)

	mat00=1
	mat01=0
	mat02=0

	mat10=0
	mat11=cx
	mat12=-sx

	mat20=0
	mat21=sx
	mat22=cx
   
    --mat00=cz*cy
    --mat10=-sz
    --mat20=cz*sy
    --mat01=cx*sz*cy+sx*sy
    --mat11=cx*cz
    --mat21=cx*sz*sy-sx*cy
    --mat02=sx*sz*cy-cx*sy
    --mat12=sx*cz
    --mat22=sx*sz*sy+cx*cy
end

function generate_matrix_transform_z(xa,ya,za)
    --local sx=sin(xa)
   -- local sy=sin(ya)
    local sz=sin(za)
    --local cx=cos(xa)
    --local cy=cos(ya)
    local cz=cos(za)

	mat00=cz
	mat01=-sz
	mat02=0

	mat10=sz
	mat11=cz
	mat12=0

	mat20=0
	mat21=0
	mat22=1
   
    --mat00=cz*cy
    --mat10=-sz
    --mat20=cz*sy
    --mat01=cx*sz*cy+sx*sy
    --mat11=cx*cz
    --mat21=cx*sz*sy-sx*cy
    --mat02=sx*sz*cy-cx*sy
    --mat12=sx*cz
    --mat22=sx*sz*sy+cx*cy
end

function transform_object(object3d)
    generate_matrix_transform_x(object3d.ax,object3d.ay,object3d.az)
    for i=1, #object3d.verts do
        local t_vertex=object3d.t_verts[i]
        local vertex=object3d.verts[i]

        t_vertex[1],t_vertex[2],t_vertex[3]=rotate_point(vertex[1],vertex[2],vertex[3])
    end
    
    generate_matrix_transform_y(object3d.ax,object3d.ay,object3d.az)
    for i=1, #object3d.verts do
        local t_vertex=object3d.t_verts[i]
        t_vertex[1],t_vertex[2],t_vertex[3]=rotate_point(t_vertex[1],t_vertex[2],t_vertex[3])
    end

    generate_matrix_transform_z(object3d.ax,object3d.ay,object3d.az)
    for i=1, #object3d.verts do
        local t_vertex=object3d.t_verts[i]
        t_vertex[1],t_vertex[2],t_vertex[3]=rotate_point(t_vertex[1],t_vertex[2],t_vertex[3])
    end
end

function generate_cam_matrix_transform(xa,ya,za)
    local sx=sin(xa)
    local sy=sin(ya)
    local sz=sin(za)
    local cx=cos(xa)
    local cy=cos(ya)
    local cz=cos(za)
   
    cam_mat00=cz*cy
    cam_mat10=-sz
    cam_mat20=cz*sy
    cam_mat01=cx*sz*cy+sx*sy
    cam_mat11=cx*cz
    cam_mat21=cx*sz*sy-sx*cy
    cam_mat02=sx*sz*cy-cx*sy
    cam_mat12=sx*cz
    cam_mat22=sx*sz*sy+cx*cy
end

function quicksort(t,start, endi)
   start, endi = start or 1, endi or #t
  --partition w.r.t. first element
  if(endi - start < 1) then return t end
  local pivot = start
  for i = start + 1, endi do
    if t[i].z <= t[pivot].z then
      if i == pivot + 1 then
        t[pivot],t[pivot+1] = t[pivot+1],t[pivot]
      else
        t[pivot],t[pivot+1],t[i] = t[i],t[pivot],t[pivot+1]
      end
      pivot = pivot + 1
    end
  end
   t = quicksort(t, start, pivot - 1)
  return quicksort(t, pivot + 1, endi)
end

function trifill(x1,y1,x2,y2,x3,y3, color)
	color1 = color
	local x1=band(x1,0xffff)
          local x2=band(x2,0xffff)
          local y1=band(y1,0xffff)
          local y2=band(y2,0xffff)
          local x3=band(x3,0xffff)
          local y3=band(y3,0xffff)
          
          local nsx,nex
          --sort y1,y2,y3
          if(y1>y2)then
            y1,y2=y2,y1
            x1,x2=x2,x1
          end
          
          if(y1>y3)then
            y1,y3=y3,y1
            x1,x3=x3,x1
          end
          
          if(y2>y3)then
            y2,y3=y3,y2
            x2,x3=x3,x2          
          end
          
         if(y1!=y2)then          
            local delta_sx=(x3-x1)/(y3-y1)
            local delta_ex=(x2-x1)/(y2-y1)
           
            if(y1>0)then
                nsx=x1
                nex=x1
                min_y=y1
            else --top edge clip
                nsx=x1-delta_sx*y1
                nex=x1-delta_ex*y1
                min_y=0
            end
           
            max_y=min(y2,128)
           
            for y=min_y,max_y-1 do

            rectfill(nsx,y,nex,y,color1)
            --if(band(y,1)==0)then rectfill(nsx,y,nex,y,color1) else rectfill(nsx,y,nex,y,color2) end
            nsx+=delta_sx
            nex+=delta_ex
            end

        else --where top edge is horizontal
            nsx=x1
            nex=x2
        end

          
        if(y3!=y2)then
            local delta_sx=(x3-x1)/(y3-y1)
            local delta_ex=(x3-x2)/(y3-y2)
           
            min_y=y2
            max_y=min(y3,128)
            if(y2<0)then
                nex=x2-delta_ex*y2
                nsx=x1-delta_sx*y1
                min_y=0
            end
           
             for y=min_y,max_y do

                rectfill(nsx,y,nex,y,color1)
                --if(band(y,1)==0)then rectfill(nsx,y,nex,y,color1) else rectfill(nsx,y,nex,y,color2) end
                nex+=delta_ex
                nsx+=delta_sx
             end
           
        else --where bottom edge is horizontal
            rectfill(nsx,y3,nex,y3,color1)
            --if(band(y,1)==0)then rectfill(nsx,y3,nex,y3,color1) else rectfill(nsx,y3,nex,y3,color2) end
        end

end

function draw_triangle_list()
    --for t in all(triangle_list) do
    for i=1,#triangle_list do
        local t=triangle_list[i]
        --fillp(0b0000000000000000)
        --if(t.fade_out) fillp(0b1010010110100101)
        trifill( t.p1x,t.p1y,t.p2x,t.p2y,t.p3x,t.p3y, t.color )
    end
end

function render_gui()
    local sector_x = abs(flr(mov_tiles_x/terrain_mesh_faces)%terrain_ns)
    local sector_z = abs(flr(mov_tiles_z/terrain_mesh_faces)%terrain_ns)

    rectfill(terrain_ns, 0, terrain_ns-flr(player.y/5), 0, 11)

    draw_map()

    if (flr(time()%2) == 1) then 
        pset(sector_x, abs(sector_z-terrain_ns)-1, 7) 
    end
end

function render_terrain(matrix_object3d)
    --Project
    local trans_proj_verts = {}

    -- 0 - 120 : n vertices terrain mesh
    for v=0,(terrain_mesh_nv)*(terrain_mesh_nv)-1 do
        local vert_x= (v*terrain_ts)%(terrain_mesh_s+terrain_ts) + (mov_tiles_x-5)*terrain_ts
        local vert_y = 0
        local vert_z = flr(v/terrain_mesh_nv)*terrain_ts + (mov_tiles_z-5)*terrain_ts

       -- local current_vert = ((v%terrain_mesh_nv + mov_tiles_x)%(terrain_nc) + flr(v/(terrain_mesh_nv))*(terrain_nc) + ((terrain_nc) *mov_tiles_z))%((terrain_nc) *(terrain_nc) )
        vert_x-= cam_x 
      --  print(flr(v/terrain_mesh_nv) + mov_tiles_z%terrain_nc, 1, 1, 8)
      --  print((v%terrain_mesh_nv + mov_tiles_x)%(terrain_nc).." "..(flr(v/terrain_mesh_nv) + mov_tiles_z)%terrain_nc)
        vert_y-= cam_y + integer_list[(flr(v/terrain_mesh_nv) + mov_tiles_z - (terrain_mesh_faces/2))%(terrain_nc-1)][(v%terrain_mesh_nv + mov_tiles_x - (terrain_mesh_faces/2))%(terrain_nc-1)] * 10
        
        vert_z-= cam_z
        
        if(v%terrain_mesh_nv == 0)then  
            vert_x+=sub_mov_x*terrain_ts  
        end

        if(v%terrain_mesh_nv == terrain_mesh_faces)then 
            vert_x+=sub_mov_x*terrain_ts - terrain_ts
        end

        
        if(flr(v/terrain_mesh_nv) == 0)then 
            vert_z+=sub_mov_z*terrain_ts 
        end


        if(flr(v/terrain_mesh_nv) == terrain_mesh_faces)then 
            vert_z+=sub_mov_z*terrain_ts - terrain_ts
        end

        vert_x, vert_y, vert_z=rotate_cam_point(vert_x, vert_y, vert_z)

        trans_proj_verts[v] = {vert_x, vert_y, vert_z, vert_x*k_screen_scale/vert_z+k_x_center,vert_y*k_screen_scale/vert_z+k_x_center, color_terrain[(v + mov_tiles_x + mov_tiles_z*terrain_mesh_nv)]}

        --print(mov_tiles_x, 1, 70, 9)
        --print((flr(v/terrain_mesh_nv) + mov_tiles_z - (terrain_mesh_faces/2))%(terrain_nc-1), trans_proj_verts[v][4], trans_proj_verts[v][5])
        --print((v%terrain_mesh_nv + mov_tiles_x - (terrain_mesh_faces/2))%(terrain_nc-1), trans_proj_verts[v][4], trans_proj_verts[v][5])
    end

    local color = 0
    for v=#trans_proj_verts-(terrain_mesh_nv*2)+terrain_mesh_nv-1,0, -1 do
        if((v+1)%(terrain_mesh_nv) != 0 and v<#trans_proj_verts-terrain_mesh_nv) then
            if(player.y > -400)then 
                local p1 = trans_proj_verts[v]
                local p3 = trans_proj_verts[v+1]
                local p2 = trans_proj_verts[v + terrain_mesh_nv + 1]
                local p4 = trans_proj_verts[v + terrain_mesh_nv]
                --local current_face = ((v%terrain_mesh_nv + mov_tiles_x)%(terrain_nc-1) + flr(v/(terrain_mesh_nv))*(terrain_nc-1) + ((terrain_nc-1) *mov_tiles_z))%((terrain_nc-1) *(terrain_nc-1))
                --print(#color_terrain[1])
                color = color_terrain[(flr(v/terrain_mesh_nv) + mov_tiles_z - (terrain_mesh_faces/2))%(terrain_nc-1)][(v%terrain_mesh_nv + mov_tiles_x - (terrain_mesh_faces/2))%(terrain_nc-1)]
                --color = 3
                

                local p1x,p1y,p1z= p1[1], p1[2], p1[3] 
                local p2x,p2y,p2z= p2[1], p2[2], p2[3] 
                local p3x,p3y,p3z= p3[1], p3[2], p3[3] 
                local p4x,p4y,p4z= p4[1], p4[2], p4[3]

                local cz=.01*(p1z+p2z+p3z)/3
                local cx=.01*(p1x+p2x+p3x)/3
                local cy=.01*(p1y+p2y+p3y)/3
                local z_paint= -cx*cx-cy*cy-cz*cz

                local fade_out = false
                
                local s1x,s1y = p1[4],p1[5]
                local s2x,s2y = p2[4],p2[5]
                local s3x,s3y = p3[4],p3[5]
                local s4x,s4y = p4[4],p4[5]

                --x[[
                if(( (s1x-s2x)*(s3y-s2y)-(s1y-s2y)*(s3x-s2x)) < 0)then
                    add(triangle_list,{
                        p1x=s1x,
                        p1y=s1y,
                        p2x=s2x,
                        p2y=s2y,
                        p3x=s3x,
                        p3y=s3y,
                        tz=z_paint,
                        color=color,
                        fade_out=fade_out})
                end
                if(( (s1x-s4x)*(s2y-s4y)-(s1y-s4y)*(s2x-s4x)) < 0)then
                    add(triangle_list,{
                        p1x=s1x,
                        p1y=s1y,
                        p2x=s4x,
                        p2y=s4y,
                        p3x=s2x,
                        p3y=s2y,
                        tz=z_paint,
                        color=color,
                        fade_out=fade_out})
                end
                --]]
                --print(flr(v/(terrain_mesh_nv)+ mov_tiles_z)%(terrain_nc), s1x,s1y+10)
            end
        end
        
    end
   -- stop()
    draw_triangle_list()
    triangle_list = {}
end

function draw_object3d(object)
    --project all points in object to screen space
    --it's faster to go through the array linearly than to use a for all()
    for i=1, #object.t_verts do
        local vertex=object.t_verts[i]
        vertex[4],vertex[5] = vertex[1]*k_screen_scale/vertex[3]+k_x_center,vertex[2]*k_screen_scale/vertex[3]+k_x_center

        --if(object.verts[i][4] != nil) then
        --    print(object.verts[i][4], vertex[4], vertex[5]-5, 7)
        ---end
	    --print(object.verts[i][1]..","..""..object.verts[i][2]..","..object.verts[i][3], vertex[4], vertex[5]-5, 7)
		--print(object.t_verts[i][1]..","..""..object.t_verts[i][2]..","..object.t_verts[i][3], vertex[4], vertex[5]-5, 7)
		--circfill( vertex[4], vertex[5], 2, 1 )
    end

    for i=1,#object.tris do
        local tri=object.tris[i]
        local color=tri[4]
   
        local p1=object.t_verts[tri[1]]
        local p2=object.t_verts[tri[2]]
        local p3=object.t_verts[tri[3]]
        
        local p1x,p1y,p1z=p1[1],p1[2],p1[3]
        local p2x,p2y,p2z=p2[1],p2[2],p2[3]
        local p3x,p3y,p3z=p3[1],p3[2],p3[3]
       -- print(tri[5])

        
        --print(i, (s1x+s2x)/2, (s1y+s2y)/2)

        local cz=.01*(p1z+p2z+p3z)/3
        local cx=.01*(p1x+p2x+p3x)/3
        local cy=.01*(p1y+p2y+p3y)/3
        local z_paint= -cx*cx-cy*cy-cz*cz
		if((p1z>z_max or p2z>z_max or p3z>z_max))then
            if(p1z< z_clip and p2z< z_clip and p3z< z_clip)then
                local s1x,s1y = p1[4],p1[5]
                local s2x,s2y = p2[4],p2[5]
                local s3x,s3y = p3[4],p3[5]

				if( max(s3x,max(s1x,s2x))>0 and min(s3x,min(s1x,s2x))<128)  then
					--only use backface culling on simple option without clipping
					--check if triangles are backwards by cross of two vectors
					if(( (s1x-s2x)*(s3y-s2y)-(s1y-s2y)*(s3x-s2x)) < 0)then
						add(triangle_list,{p1x=s1x,
							p1y=s1y,
							p2x=s2x,
							p2y=s2y,
							p3x=s3x,
							p3y=s3y,
							tz=z_paint,
							color=color})
					end
				end
            end
        end
    end

    draw_triangle_list()
    triangle_list = {}
end

function update_objects3d()
    for object3d in all(objects3d) do
        transform_object(object3d)
        cam_transform_object(object3d)
    end
end

function update_sprites3d()
    for i=#sprites3d,1,-1 do
        local sprite = sprites3d[i]
        sprite.life_span -= time() - last_time
        if(sprite.life_span < 0) then
            deli(sprites3d, i)
        else
            local vert_x, vert_y, vert_z = sprite.x, sprite.y, sprite.z
            vert_x -= cam_x 
            vert_y -= cam_y 
            vert_z -= cam_z
            
            vert_x, vert_y, vert_z=rotate_cam_point(vert_x, vert_y, vert_z)
            
            --print(vert_x)
            --print(vert_z)
            sprite.sx= vert_x*k_screen_scale/vert_z+k_x_center
            sprite.sy= vert_y*k_screen_scale/vert_z+k_x_center
        end
    end
end

function render_objects()
    local to_draw_row = {}

    for i=#objects3d, 1, -1 do
        local object3d = objects3d[i]
        add(to_draw_row, object3d)
    end
    for i=#sprites3d, 1, -1 do
        local sprite3d = sprites3d[i]
        add(to_draw_row, sprite3d)
    end

    quicksort(to_draw_row)
    for i=#to_draw_row, 1, -1 do

        to_draw_row[i].render(to_draw_row[i])
    end

end

function draw_3d()
    triangle_list = {}
    render_objects()
    
    last_time = time()
end

function update_3d()
    mov_tiles_x = flr(player.x/terrain_ts)
    mov_tiles_z = flr(player.z/terrain_ts)

    mov_tiles_x_trunc = mov_tiles_x%terrain_nc
    mov_tiles_z_trunc = mov_tiles_z%terrain_nc

    sub_mov_x =  (player.x/terrain_ts) % 1 
    sub_mov_z =  (player.z/terrain_ts) % 1 

    ground_y_player = -integer_list[mov_tiles_z_trunc][mov_tiles_x_trunc]*10
    
    --update_visible(terrain)
    update_objects3d()
    update_sprites3d()
end

function create_object3d(verts, tris, x, y, z, mx, my, mz, ax,ay,az)
    object3d = {}
    
    object3d.verts=verts or {}
    object3d.tris=tris or {}

    object3d.t_verts={}

    object3d.mx=mx or 0
    object3d.my=my or 0
    object3d.mz=mz or 0
    
    for i=1,#object3d.verts do
        object3d.verts[i][1] -= mx
		object3d.verts[i][2] -= my
		object3d.verts[i][3] += mz

        object3d.t_verts[i]={}
        for j=1,3 do
            object3d.t_verts[i][j]=object3d.verts[i][j]
        end
    end

    --print(#object3d.verts)
    --stop()

    object3d.x=x or 0
    object3d.y=y or 0
    object3d.z=z or 0

    object3d.vx= 0
    object3d.vy= 0
    object3d.vz= 0

    object3d.ax=ax or 0
    object3d.ay=ay or 0
    object3d.az=az or 0

    object3d.render = draw_object3d

    transform_object(object3d)

    return object3d
end

function create_sprite3d(x, y, z, draw_func, vx,vy,vz, color, life_span)
    sprite3d = {}
    sprite3d.x=x or 0
    sprite3d.y=y or 0
    sprite3d.z=z or 0

    sprite3d.vx=vx or nil
    sprite3d.vy=vy or nil
    sprite3d.vz=vz or nil

    sprite3d.sx= 0
    sprite3d.sy= 0

    sprite3d.life_span = life_span or 2

    sprite3d.color = color or nil

    sprite3d.render=draw_func
    return sprite3d
end

function draw_map()
    --print('',1,1,8)
    for sr=0, terrain_ns-1 do
        for sc=0, terrain_ns-1 do  
            local sector_color = 0
            local sum_color = 0
            --print(#integer_list,1,1,8)
            --print(s, s*6,1, 5)
            
            

            --stop()
        --   print(sector_color)
            --print(flr(sum_color/(terrain_mesh_faces*terrain_mesh_faces)))
            --print(terrain_mesh_faces*sr)
            sector_colors[sr + sc*terrain_ns] = height_color_list[integer_list[(terrain_mesh_faces*sr)][(terrain_mesh_faces*sc)]]
            pset(sc, terrain_ns-sr-1, sector_colors[sr + sc*terrain_ns]) 

            --print(abs(flr(s/(terrain_ns))-terrain_ns))
            --pset(v%(terrain_nc-1), abs(flr(v/(terrain_nc-1))-terrain_nc), color_terrain[v]) 
        end
    end
 --  stop()
   -- stop()
    --print(#color_terrain, 1, 1)
end

