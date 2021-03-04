pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--globals
gravity = .15
fricton = .95
cave_height=500
min_tunnel_size = 50
wavy_period = 1.5
--end globals
tunnel_center = 0
limit = cave_height/2-min_tunnel_size/2
toplimit = cave_height/2-min_tunnel_size/2 + tunnel_center
bottomlimit = cave_height/2-min_tunnel_size/2 - tunnel_center

--core funcs
function _init()
    game_over = false
    make_player()
    make_cave()
    bullets = {}
end

function _update() 
    if (not game_over) then
        update_cave()
        move_player()
        move_bullets()
        check_hit()
    else
        if (btnp(5)) _init()
    end
end

function _draw()
    cls()
    draw_cave()
    draw_player()
    draw_bullets()

    if (game_over) then
        print("game over!",44,44,7)
        print("your score:"..player.score,34,54,7)
        print("press X to play again!",18,72,6)
    else
        print("score:"..player.y,2,2,7)
    end
end
--end core funcs

function make_player()
    player = {}
    cam = {}
    player.x = 24 --pos
    player.y = 0
    player.dy = 0 --fall speed
    player.rise = 1 --sprites
    player.fall = 2
    player.dead = 3
    player.speed = 2
    player.score = 0
    cam.x = player.x
    cam.y = player.y
end
function make_cave()
    cave = {{["top"]=toplimit-min_tunnel_size/2,["btm"]=bottomlimit-min_tunnel_size/2,["hastentacle"]=false}}
end

function draw_player()
    if (game_over) then
        spr(player.dead,player.x,64-cam.y+player.y)
    elseif (player.dy < 0) then
        spr(player.rise,player.x,64-cam.y+player.y)
    else
        spr(player.fall,player.x,64-cam.y+player.y)
    end
end

function move_player()
    --player.dy+=gravity
    player.dy*=fricton
    if (btn(2)) then
        player.dy -= .5
        --sfx(0)
    elseif (btn(3)) then
        player.dy += .5
    end

    if (btnp(5)) then
        add(bullets,{["x"]=player.x+8,["y"]=player.y+4})
    end

    player.y += player.dy

    cam.y += (player.y-cam.y)/4
    
    player.score += player.speed
end

function move_bullets()
    local todelete = {}
    for i=1,#bullets do
        bullets[i].x += 2
        if bullets[i].x > 125 then
            add(todelete,i)
        end
    end
    for i=1,#todelete do
        del(bullets,bullets[todelete[i]])
    end
end
function draw_bullets() 
    for i=1,#bullets do
        line(bullets[i].x-1,64-cam.y+bullets[i].y,bullets[i].x+1,64-cam.y+bullets[i].y,9)
    end
end

function update_cave() 
    if (#cave>player.speed) then
        for i=1,player.speed do
            del(cave,cave[1])
        end
    end

    while (#cave<128) do
        local col = {}
        local mov = cos((player.score-100)/500.0)*(1.5*cave_height/2)/500
        local up = (rnd(6)-3) + mov
        local dwn = (rnd(6)-3) - mov
        toplimit = cave_height/2-min_tunnel_size/2 + tunnel_center
        bottomlimit = cave_height/2-min_tunnel_size/2 - tunnel_center
        col.top=mid(3,cave[#cave].top+up,cave_height)
        col.btm=mid(3,cave[#cave].btm+dwn,cave_height)

        local height_diff = cave_height-col.top-col.btm
        if (height_diff > 100) then
            if (rnd(1) > .5) then
                col.top+=1
            else
                col.btm+=1
            end
        elseif (height_diff <50) then
            if (rnd(1) > .5) then
                col.top-=1
            else
                col.btm-=1
            end
        end

        col.hastentacle = false
        if (rnd()<=.01) then
            col.tentacle = {}
            col.hastentacle = true
            if (rnd()>.5) then
                col.tentacle.facingup = true
                col.tentacle.bulb = col.btm + height_diff/4 + rnd(height_diff/2)
            else
                col.tentacle.facingup = false            
                col.tentacle.bulb = col.top + height_diff/4 + rnd(height_diff/2)
            end
        end

        add(cave,col)
    end
end

function draw_cave() 
    top_color=8
    btm_color=14
    wavy_coeff = 0
    for i=1,#cave do
        wavy_coeff = sin((player.score*wavy_period+i)/16)
        line(i-1,64-cam.y-cave_height/2,i-1,64-cam.y-cave_height/2+cave[mid(1,i+flr(wavy_coeff+.5),#cave)].top,top_color)
        line(i-1,64-cam.y+cave_height/2,i-1,64-cam.y+cave_height/2-cave[mid(1,i+flr(wavy_coeff+.5),#cave)].btm,btm_color)
        --debug sin waves
        --pset(i-1,10+wavy_coeff*5,6)
        --pset(i-1,110+flr(wavy_coeff+.5)*5,6)
        if (cave[i].hastentacle) then
            if (cave[i].tentacle.facingup) then
                rect(i,64-cam.y+cave_height/2-cave[i].tentacle.bulb,i-2,64-cam.y+cave_height/2-cave[i].btm,10)
            else
                rect(i,64-cam.y-cave_height/2+cave[i].tentacle.bulb,i-2,64-cam.y-cave_height/2+cave[i].top,10)
            end
        end
    end
end

function worldtoscreen()

end

function check_hit()
    --print("eeeeeee",0,64)
    local todelete = {}
    for i=1,#bullets do
        if (-cave_height/2+cave[bullets[i].x+1].top>bullets[i].y or cave_height/2-cave[bullets[i].x+1].btm<bullets[i].y) then
            add(todelete,bullets[i])
            --print("aaaaa")
        end
    end
    for i=1,#todelete do
        del(bullets,todelete[i])
    end

    -- for i=player.x,player.x+7 do
    --     if (-cave_height/2+cave[i+1].top>player.y or cave_height/2-cave[i+1].btm<player.y+7) then
    --         game_over = true
    --         sfx(1)
    --     end
    -- end
end

--utility funcs
function smoothstep(x)
    return x*x*(3-2*x)
end

__gfx__
00000000000000000000000006666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660000006600066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006666000006600066866866000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000066666600006600066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000660000666666006666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000660000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000006600000066000006d6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000006d6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000050000600007000070000700006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000003000060000600006000060000600007000070000700007000070000000000000000000000000000000000000000000040000400004000030000300003000030000200002000000000000000000000
