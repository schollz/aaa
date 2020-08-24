-- aaa

engine.name='PolySub4'

-- modes adjusted by encoders
mode_switch=2 -- adsr = 1, params = 2
mode_adsr_adjust=1
-- flags to update parameters
flag_update_draw=true
flag_update_adsr=true

function init()
  params:add_separator("aaa params")
  params:add_group("adsr",4)
  params:add_control("attackTime","attackTime",controlspec.new(0,10,"lin",0.1,1.3,"s"))
  params:set_action("attackTime",update_adsr)
  params:add_control("decayTime","decayTime",controlspec.new(0,10,"lin",0.1,2.0,"s"))
  params:set_action("decayTime",update_adsr)
  params:add_control("sustainLevel","sustainLevel",controlspec.new(0,1,"lin",0.1,0.7))
  params:set_action("sustainLevel",update_adsr)
  params:add_control("releaseTime","releaseTime",controlspec.new(0,10,"lin",0.1,1.6,"s"))
  params:set_action("releaseTime",update_adsr)
  
  midi_signal_in=midi.connect(1)
  midi_signal_in.event=on_midi_event
  
  updater=metro.init()
  updater.time=0.1
  updater.count=-1
  updater.event=update
  updater:start()
end

function on_midi_event(data)
  msg=midi.to_msg(data)
  if msg.type=='note_on' then
    hz=(440/32)*(2^((msg.note-9)/12))
    print(msg.note,msg.vel/127.0)
    engine.start(msg.note,msg.vel/127.0)
  elseif msg.type=='note_off' then
    engine.stop(msg.note)
  end
end

function update(c)
  if flag_update_draw==true then
    redraw()
  end
  if flag_update_adsr==true then
    update_adsr()
  end
end

function update_adsr()
  flag_update_adsr=false
  engine.cutAtk(params:get("attackTime"))
  engine.cutDec(params:get("decayTime"))
  engine.cutSus(params:get("sustainLevel"))
  engine.cutRel(params:get("releaseTime"))
  print("updating adsr")
  -- update engines
end

function enc(n,d)
  if n==1 then
    mode_switch=util.clamp(mode_switch+d,1,2)
    print(mode_switch)
  elseif mode_switch==1 then
    if n==2 then
      mode_adsr_adjust=math.floor(util.clamp(mode_adsr_adjust+d,1,4.9))
    elseif n==3 then
      if mode_adsr_adjust==1 then
        params:delta("attackTime",d)
      elseif mode_adsr_adjust==2 then
        params:delta("decayTime",d)
      elseif mode_adsr_adjust==3 then
        params:delta("sustainLevel",d)
      elseif mode_adsr_adjust==4 then
        params:delta("releaseTime",d)
      end
      flag_update_adsr=true
    end
  end
  
  flag_update_draw=true
end

function redraw()
  flag_update_draw=false
  screen.clear()
  draw_top_menu()
  if mode_switch==1 then
    draw_adsr()
  elseif mode_switch==2 then
    size={width=100,height=8,xoffset=12}
    screen.line_width(size.height)
    
    curY=20
    value=0.5
    for i=1,4 do
      screen.level(15)
      screen.move(size.xoffset,curY)
      screen.line(size.xoffset+math.floor(size.width*value),curY)
      screen.stroke()
      screen.level(1)
      screen.move(size.xoffset+math.floor(size.width*value),curY)
      screen.line(size.xoffset+size.width,curY)
      screen.stroke()
      curY=curY+size.height+5
    end
  end
  screen.update()
end

function draw_top_menu()
  screen.level(15)
  screen.move(2,8)
  screen.text("aaa")
  screen.fill()
  screen.move(45,8)
  if mode_switch==1 then
    screen.text("adsr")
  elseif mode_switch==2 then
    screen.text("params")
  end
  screen.move(89,8)
  screen.text(":)")
end

function draw_adsr()
  screenBounds={8,60,82,20}
  total_width=params:get("attackTime")+params:get("decayTime")+params:get("releaseTime")
  curX=screenBounds[1]
  curY=screenBounds[2]
  screen.move(curX,curY)
  
  curX=curX+math.floor(screenBounds[3]*params:get("attackTime")/total_width)
  curY=curY+screenBounds[4]-screenBounds[2]
  if mode_adsr_adjust==1 then
    screen.level(15)
    screen.line_width(3)
  else
    screen.level(7)
    screen.line_width(1)
  end
  screen.line(curX,curY)
  screen.stroke()
  
  screen.move(curX,curY)
  curX=curX+math.floor(screenBounds[3]*params:get("decayTime")/total_width)
  curY=curY-(screenBounds[4]-screenBounds[2])*(1-params:get("sustainLevel"))
  if mode_adsr_adjust==2 then
    screen.level(15)
    screen.line_width(3)
  else
    screen.level(7)
    screen.line_width(1)
  end
  screen.line(curX,curY)
  screen.stroke()
  
  screen.move(curX,curY)
  curX=curX+30
  if mode_adsr_adjust==3 then
    screen.level(15)
    screen.line_width(3)
  else
    screen.level(7)
    screen.line_width(1)
  end
  screen.line(curX,curY)
  screen.stroke()
  
  screen.move(curX,curY)
  curX=curX+math.floor(screenBounds[3]*params:get("releaseTime")/total_width)
  curY=screenBounds[2]
  if mode_adsr_adjust==4 then
    screen.level(15)
    screen.line_width(3)
  else
    screen.level(7)
    screen.line_width(1)
  end
  screen.line(curX,curY)
  screen.stroke()
  
  print("ok")
  screen.line_width(1)
  screen.move(screenBounds[1],screenBounds[2])
  screen.line(curX,curY)
  screen.stroke()
end

-- Utils
-- https://github.com/neauoire/tutorial/blob/master/7_midi.lua

function clamp(val,min,max)
  return val<min and min or val>max and max or val
end
