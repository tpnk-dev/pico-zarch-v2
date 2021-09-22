function create_list()
    for i=0,terrain_mesh_nc*terrain_mesh_nc do
        integer_list[i] = flr(rnd(10)) + 5

            if flr(rnd(2)) == 1 then
                integer_list[i] = 0
            end
    end
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
        for v=terrain_mesh_nc+1, (terrain_mesh_nc*terrain_mesh_nc)-(terrain_mesh_nc*2)+terrain_mesh_nc-2 do
            if((v+1)%(terrain_mesh_nc) != 0 and (v)%(terrain_mesh_nc) != 0 and v<(terrain_mesh_nc*terrain_mesh_nc)-terrain_mesh_nc) then
                integer_list[v] = 
                flr((integer_list[v-terrain_mesh_nc-1]
                +integer_list[v-terrain_mesh_nc]
                +integer_list[v-terrain_mesh_nc+1]
                +integer_list[v-1]
                +integer_list[v+1]
                +integer_list[v+terrain_mesh_nc-1]
                +integer_list[v+terrain_mesh_nc]
                +integer_list[v+terrain_mesh_nc+1]) / 8)
                
            end
        end
    end
end

function recolor()

    local color_list = 
    {[0]=13,10,2,2,2,11,3,4,5,
    11,11,4,4,4,4,4} 
    for v=0,terrain_mesh_nc*terrain_mesh_nc do
        --get max of tri
        color_terrain[v] = color_list[max(integer_list[v], integer_list[v+1], integer_list[v + terrain_mesh_nc + 1], integer_list[v + terrain_mesh_nc])]
    end

end