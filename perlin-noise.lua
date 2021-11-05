height_color_list = {[0]=13,2,2,2,3,3,3,3} 
variation_color_list = {[0]=13, 10, 2, 11, 10, 4}

function create_list()
    for r=0,terrain_nc-1 do
        integer_list[r] = {}
        for c=0, terrain_nc-1 do
            --integer_list[i] = i%4 + flr(i/terrain_nc)%2%4
            --print(i%2)
            --x[[
            integer_list[r][c] = flr(rnd(15))
    
        
            local rnd = flr(rnd(2))
            if rnd == 1 then
                integer_list[r][c] = 0
            end
            --]]
        end
    end
    print(#integer_list, 1, 1, 8)
    --stop()
end

function write_list()
    for y=0,size-50 do
        for x=0,size-50 do
            pset(x,y,integer_list[y+10][x+10])
        end
    end
end

function noise(times)

    times = times or 1

    for i=1,times do
        for v=terrain_nc+1, (terrain_nc*terrain_nc)-(terrain_nc*2)+terrain_nc-2 do
            if((v+1)%(terrain_nc) != 0 and (v)%(terrain_nc) != 0 and v<(terrain_nc*terrain_nc)-terrain_nc) then
                integer_list[v] = 
                flr((integer_list[v-terrain_nc-1]
                +integer_list[v-terrain_nc]
                +integer_list[v-terrain_nc+1]
                +integer_list[v-1]
                +integer_list[v+1]
                +integer_list[v+terrain_nc-1]
                +integer_list[v+terrain_nc]
                +integer_list[v+terrain_nc+1]) / 8)
                
            end
        end
    end
end

function recolor()
    for r=0,terrain_nc-2 do
        color_terrain[r] = {}
        for c=0, terrain_nc-2 do
            height = max(integer_list[r][c], integer_list[r][(c+1) % #integer_list], integer_list[(r+1) % #integer_list][c], integer_list[(r+1)% #integer_list][(c+1)% #integer_list])
            if(height >= 2) height = variation_color_list[2] + (r%3+c%3)%3 + flr(rnd(2))
           
            color_terrain[r][c] = variation_color_list[height]
           -- print(v)
        end
    end
end