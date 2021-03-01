pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--globals
gravity = .2
friction = .2
game_over = false
cave_height = 500
tunnel_height = cave_height/2
--end globals

--core funcs

function _update() 
    if (not game_over) then
        update_cave()
        move_player()
        check_hit()
    else
        if (btnp(5)) _init()
    end
end

function _draw()
    cls()
    draw_cave()
    draw_player()

    if (game_over) then
        print("game over!",44,44,7)
        print("your score:"..player.score,34,54,7)
        print("press X to play again!",18,72,6)
    else
        print("score:"..player.score,2,2,7)
    end
end
function _init()
    game_over = false
    make_player()
    make_cave()
end
--end core funcs

--init functions
function make_player()
    player = {}
    player.x = 24 --pos
    player.y = cave_height/2
    player.dy = 0 --fall speed
    player.rise = 1 --sprites
    player.fall = 2
    player.dead = 3
    player.speed = 2
    player.score = 0
end
function make_cave()
    cave = {{["top"]=200,["btm"]=200}}
    top = 200
    btm = 200
end
--end init functions

function draw_player()
    if (game_over) then
        spr(player.dead,player.x,player.y)
    elseif (player.dy < 0) then
        spr(player.rise,player.x,player.y)
    else
        spr(player.fall,player.x,player.y)
    end
end

function move_player()
    player.dy+=gravity

    if (btnp(2)) then
        player.dy -= 5
        sfx(0)
    end

    player.y += player.dy

    player.score += player.speed
end

function update_cave() 
    if (#cave>player.speed) then
        for i=1,player.speed do
            del(cave,cave[1])
        end
    end

    while (#cave<128) do
        local col = {}
        local up = flr(rnd(7)-3)
        local dwn = flr(rnd(7)-3)
        col.top=mid(3,cave[#cave].top+up,top)
        col.btm=mid(btm,cave[#cave].btm+dwn,cave_height)
        add(cave,col)
    end
end

function draw_cave() 
    top_color=5
    btm_color=4
    for i=1,#cave do
        line(i-1,64-cave_height/2,i-1,64-cave_height/2+cave[i].top,top_color)
        line(i-1,64+cave_height/2,i-1,64+cave_height/2-cave[i].btm,btm_color)
    end
end

function check_hit()
    return
    -- for i=player.x,player.x+7 do
    --     if (cave[i+1].top>player.y or cave[i+1].btm<player.y+7) then
    --         game_over = true
    --         sfx(1)
    --     end
    -- end
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
