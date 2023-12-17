from p5 import *
import math
import random

MIDI_key = 0
MIDI_key_old = 0
last_key_change = 0
delta_key_change = 0

cam_pos_x = 0
cam_pos_x = 0
cam_pos_x = 0

rotation_vect_x = 0
rotation_vect_y = 0
rotation_vect_z = 0
    
travel_vect_x = 0
travel_vect_y = 0
travel_vect_z = 0
    

def setup():
    size(1600, 800)
    color_mode('HSB', 360, 100, 100, 255)
    
    global last_key_change
    last_key_change = 0
    global delta_key_change
    delta_key_change = 4500
    global MIDI_key
    MIDI_key = 1
    global MIDI_key_old
    MIDI_key_old = 0

def draw():
    
    global last_key_change
    global delta_key_change
    global MIDI_key
    global MIDI_key_old
    
    global cam_pos_x
    global cam_pos_y
    global cam_pos_z
    
    global rotation_vect_x
    global rotation_vect_y
    global rotation_vect_z
    
    global travel_vect_x
    global travel_vect_y
    global travel_vect_z
    
    
    locX = mouse_x - width/2
    locY = mouse_y - height/2
    
    MIDI_volume = random.randrange(0,127)
    
    if millis()-last_key_change > delta_key_change:
        MIDI_key = random.randrange(1,12)
        last_key_change = millis()
    
    
    background(math.pow(MIDI_key,2), 100, 70, 255)
    
    #camera stuff
    #rotate_x(frame_count * 0.02)
    #rotate_y(frame_count * 0.01)
    #shear_x(frame_count * 0.01)
    #translate(1,2,3)
    
    if not MIDI_key_old == MIDI_key:
        cam_pos_x = random.randrange(200,2000)
        cam_pos_y = random.randrange(200,2000)
        cam_pos_z = random.randrange(200,2000)
        
        travel_vect_x = 1-2*random.random()
        travel_vect_y = 1-2*random.random()
        travel_vect_z = 1-2*random.random()
        
        rotation_vect_x = 1-2*random.random()
        rotation_vect_y = 1-2*random.random()
        rotation_vect_z = 1-2*random.random()
        
    millis_since_change = millis()-last_key_change
        
    camera((cam_pos_x+0.3*travel_vect_x*millis_since_change, cam_pos_y+0.3*travel_vect_y*millis_since_change, cam_pos_z+0.3*travel_vect_z*millis_since_change), (0, 0, 0), (2*rotation_vect_x*frame_count, 2*rotation_vect_y*frame_count, 2*rotation_vect_z*frame_count))
    
    blinn_phong_material()
    
    for i in range(1,7):
        translate(math.pow(400,0.5*i)%2030,math.pow(400,0.5*i)%1543)
        rotate(i,(math.pow(45,0.2*i)%100,math.pow(63,0.4*i)%100,math.pow(22,0.9*i)%100))
        sphere(300*0.5*i+MIDI_volume*0.4)

    
    light_specular(MIDI_key*10+120, MIDI_key*10, MIDI_key*10+120)
    
    point_light(255, 255, 255, locX, locY, 400)
    
    MIDI_key_old = MIDI_key

    

if __name__ == '__main__':
    run(mode='P3D')
