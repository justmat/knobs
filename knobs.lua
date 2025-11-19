print("////////////////////")
print("knobs? yeah, we got knobs")
print("////////////////////")

pset_init('knobs')

alt = false
mode = 1
ccs = {}

for i = 1, 4 do arc_res(i, 10) end


function cc_init()
  local tmp = pset_read(1)
  if tmp then
    ccs = tmp
  else
    for i = 1, 4 do
      ccs[i] = {cc = i, chan = 1, val = 0}
    end
  end
end


function midiv_to_ledv(v)
	v = math.floor(linlin(0, 127, 0, 64, v))
	return v
end


function draw_home()
	arc_led_all(0)
  for i = 1, 4 do
    arc_led(i, midiv_to_ledv(ccs[i].val), 10)
  end
	arc_refresh()
end


function draw_setup_cc()
  arc_led_all(0)
  -- the drawing logic for cc setup 
  -- comes from @tehn and the wonderful
  -- erosion script
  for i = 1, 4 do
    local z = ccs[i].cc
    local a = math.floor(z / 100)
    local b = math.floor((z % 100) / 10)
    local c = math.floor(z % 10)
    arc_led(i, 63, a==1 and 10 or 1)
    for n=1,9 do
      arc_led(i, 51 + n, b == n and 10 or 1)
      arc_led(i, 40 + n, c == n and 10 or 1)
    end
  end
  arc_refresh()
end


function event_arc_key(z)
  -- use the button as alt
  -- save pset at button release
  alt = z == 1 and true or false
  if alt then
    draw_setup_cc()
  else
    draw_home()
    pset_write(1, ccs)
  end
end


function event_arc(n, d)
  if alt then
    ccs[n].cc = clamp(ccs[n].cc + d, 0, 127)
    draw_setup_cc()
  else
    ccs[n].val = math.floor(clamp(ccs[n].val + d, 0, 127))
    midi_cc(ccs[n].cc, ccs[n].val, ccs[n].chan)
    draw_home()
  end
end


cc_init()
draw_home()