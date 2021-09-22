--matricial represetntation of terrain vertices
objects3d = {}
sprites3d = {}

terrain_nc = 100
terrain_mesh_nc = 10
terrain_ts = 15
terrain_ms = terrain_mesh_nc*terrain_ts

terrain_mx = ((terrain_mesh_nc-1)*terrain_ts)/2

--
k_screen_scale=80
k_x_center=64
k_y_center=64

z_clip=300
z_max=15

cam_dist_terrain = 10 + terrain_ts/2
cam_x,cam_y,cam_z = 0,-80,-cam_dist_terrain
cam_ax, cam_ay, cam_az = -0.14,0,0

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

function transform_object(object3d)
    generate_matrix_transform(object3d.ax,object3d.ay,object3d.az)
    for i=1, #object3d.verts do
        local t_vertex=object3d.t_verts[i]
        local vertex=object3d.verts[i]
        
        t_vertex[1],t_vertex[2],t_vertex[3]=rotate_point(vertex[1],vertex[2],vertex[3])
    
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
        trifill( t.p1x,t.p1y,t.p2x,t.p2y,t.p3x,t.p3y, t.color )
    end
end

function render_terrain(matrix_object3d)
    --Project
    local trans_proj_verts = {}
    for v=0,terrain_mesh_nc*terrain_mesh_nc do
        local vert_x= (v*terrain_ts)%terrain_ms
        local temp = vert_x
        local vert_y = 0
        local vert_z = flr(v/terrain_mesh_nc)*terrain_ts

       -- vertex[1]-= cam_x
        --vertex[2]-= cam_y
        --vertex[3]-= cam_z
        
        --project
        local mov_tiles_x = flr((indicator_object.x-terrain_mx+terrain_ts/2)/terrain_ts)
        local mov_tiles_z = flr((indicator_object.z-terrain_mx+terrain_ts/2)/terrain_ts)

        vert_x-= cam_x - mov_tiles_x  * terrain_ts -- sgn(indicator_object.x-45) * flr(abs(indicator_object.x-45) / (terrain_ts/2))*(terrain_ts) --+ terrain_ts*flr(indicator_object.x/terrain_ts)     -- + ((terrain_mesh_nc-1)*terrain_ts)/2 - terrain_ts/2 -  flr(indicator_object.x/terrain_ts) * terrain_ts - terrain_ts/2
        vert_y-= cam_y + integer_list[(v + mov_tiles_x + mov_tiles_z*terrain_mesh_nc)%terrain_nc]
        vert_z-= cam_z - mov_tiles_z * terrain_ts --- flr(flr(cam_z+cam_dist_terrain)/terrain_ts)*terrain_ts + cam_dist_terrain
        
        vert_x, vert_y, vert_z=rotate_cam_point(vert_x, vert_y, vert_z)

        
        --print(vert_x)
        --print(vert_z)

        trans_proj_verts[v] = {vert_x, vert_y, vert_z, vert_x*k_screen_scale/vert_z+k_x_center,vert_y*k_screen_scale/vert_z+k_x_center, color_terrain[(v + mov_tiles_x + mov_tiles_z*terrain_mesh_nc)%terrain_nc]}


        if v==0 then
        --=    print(vert_x, 1, 30, 9)
        end

        --print(temp,trans_proj_verts[v][4], trans_proj_verts[v][5]+3)
    end

    
    for v=0,#trans_proj_verts-(terrain_mesh_nc*2)+terrain_mesh_nc-2 do
        if((v+1)%(terrain_mesh_nc) != 0 and v<#trans_proj_verts-terrain_mesh_nc) then

            local color = 3

            local p1 = trans_proj_verts[v]
            local p3 = trans_proj_verts[v+1]
            local p2 = trans_proj_verts[v + terrain_mesh_nc + 1]
            local p4 = trans_proj_verts[v + terrain_mesh_nc]

            local p1x,p1y,p1z= p1[1], p1[2], p1[3] 
            local p2x,p2y,p2z= p2[1], p2[2], p2[3] 
            local p3x,p3y,p3z= p3[1], p3[2], p3[3] 
            local p4x,p4y,p4z= p4[1], p4[2], p4[3]

            local cz=.01*(p1z+p2z+p3z)/3
            local cx=.01*(p1x+p2x+p3x)/3
            local cy=.01*(p1y+p2y+p3y)/3
            local z_paint= -cx*cx-cy*cy-cz*cz

            local s1x,s1y = p1[4],p1[5]
            local s2x,s2y = p2[4],p2[5]
            local s3x,s3y = p3[4],p3[5]
            local s4x,s4y = p4[4],p4[5]


            --only use backface culling on simple option without clipping
            --check if triangles are backwards by cross of two vectors
            --print('tr')
            if(( (s1x-s2x)*(s3y-s2y)-(s1y-s2y)*(s3x-s2x)) < 0)then
                add(triangle_list,{
                    p1x=s1x,
                    p1y=s1y,
                    p2x=s2x,
                    p2y=s2y,
                    p3x=s3x,
                    p3y=s3y,
                    tz=z_paint,
                    color=p1[6]})
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
                    color=p1[6]})
            end
        end
    end
end


function render_object(object)
    --project all points in object to screen space
    --it's faster to go through the array linearly than to use a for all()

    for i=1, #object.t_verts do
        local vertex=object.t_verts[i]
        vertex[4],vertex[5] = vertex[1]*k_screen_scale/vertex[3]+k_x_center,vertex[2]*k_screen_scale/vertex[3]+k_x_center

        --if(object.verts[i][4] != nil) then
        --    print(object.verts[i][4], vertex[4], vertex[5]-5, 7)
        ---end
	    print(object.verts[i][1]..","..""..object.verts[i][2]..","..object.verts[i][3], vertex[4], vertex[5]-5, 7)
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
end

function render_sprites3d()
    for sprite in all(sprites3d) do
        local vert_x, vert_y, vert_z = sprite.x, sprite.y, sprite.z
        vert_x -= cam_x 
        vert_y -= cam_y 
        vert_z -= cam_z
        
        vert_x, vert_y, vert_z=rotate_cam_point(vert_x, vert_y, vert_z)
        
        --print(vert_x)
        --print(vert_z)
        sprite.draw_func(vert_x*k_screen_scale/vert_z+k_x_center,vert_y*k_screen_scale/vert_z+k_x_center)
    end
end

function draw_3d()
    triangle_list={}

	render_terrain() --sort_faces(object)
	draw_triangle_list()

    render_sprites3d()

	--triangle_list={}

    --for object3d in all(objects3d) do
        --if(object3d.visible) then
    --    render_object(object3d) --sort_faces(object)
            --if(object.color_mode==k_colorize_dynamic or object.color_mode==k_multi_color_dynamic) color_faces(object,object.color)
        --end
    --end
   -- render_time=stop_timer()
   
    --quicksort(triangle_list)
    --draw_triangle_list()
end


function update_3d()
    --update_visible(terrain)
    --for object3d in all(objects3d) do
        --update_visible(object3d)
     --   transform_object(object3d)
    --    cam_transform_object(object3d)
        --update_light()
   -- end
end

function create_object3d(verts, tris, x, y, z, mx, my, mz)
    object3d = {}
    
    object3d.verts=verts or {}
    object3d.tris=tris or {}

    object3d.t_verts={}
    
    for i=1,#object3d.verts do
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

    object3d.mx=mx or 0
    object3d.my=my or 0
    object3d.mz=mz or 0

    transform_object(object3d)

    return object3d
end

function create_sprite3d(x, y, z, draw_func)
    sprite3d = {}
    sprite3d.x=x or 0
    sprite3d.y=y or 0
    sprite3d.z=z or 0

    sprite3d.draw_func=draw_func
    return sprite3d
end



