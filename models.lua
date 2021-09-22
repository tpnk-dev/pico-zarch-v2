-- nr = number of rows
-- nc = number of columns
-- ts = tile size
-- create verts and tris for terrain
-- add verts to terrain_matrix
function create_terrain()
    local verts_matrix = {}

    local colors={[0]=15, 4, 5}

    for r=0, terrain_mesh_nc-1 do
        verts_matrix[r+1] = {}
        for c=0, terrain_mesh_nc-1 do
            local new_vert = {r*terrain_ts,integer_list[c][r],c*terrain_ts, color_terrain[c][r]}
            add(verts, new_vert)
            verts_matrix[r+1][c+1] = new_vert
        end
    end

    local tris={}
    

    for c=0,terrain_mesh_nc-2 do
        for r=0, terrain_mesh_nc-2 do
            fi=(r*(terrain_mesh_nc-1)+c)*2
            l1=r*terrain_mesh_nc+c
            l2=l1+1
            l3=l1+terrain_mesh_nc
            l4=l3+1
            
            tris[fi+1]={l1+1,l3+1,l2+1, colors[c%2 + r%2]}
            tris[fi+2]={l2+1,l3+1,l4+1, colors[c%2 + r%2]}
        end
    end
    
    terrain = create_matrix_object3d(verts_matrix)
end