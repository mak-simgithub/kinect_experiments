from p5 import *
import random
import time
import numpy



def setup():
    size(2640, 660)
    
    global tri1
    global tri2
    global tri3
    global tri4
    global tri5
    global tri6
    global tri7
    global tri8
    global tri9
    global tri0
    
    color_mode('HSB', 360, 100, 100, 255)
    
    global last_key_change
    global delta_key_change
    global MIDI_key
    global MIDI_key_old
    global cam_pos_x
    global cam_pos_y
    global cam_pos_z
    global travel_vect_x
    global travel_vect_y
    global travel_vect_z
    global rotation_vect_x
    global rotation_vect_y
    global rotation_vect_z

    last_key_change = 0
    delta_key_change = 1000
    MIDI_key = 1
    MIDI_key_old = 0
    cam_pos_x = random.randrange(200,2000)
    cam_pos_y = random.randrange(200,2000)
    cam_pos_z = random.randrange(200,2000)
    travel_vect_x = 1-2*random.random()
    travel_vect_y = 1-2*random.random()
    travel_vect_z = 1-2*random.random()
        
    rotation_vect_x = 1-2*random.random()
    rotation_vect_y = 1-2*random.random()
    rotation_vect_z = 1-2*random.random()
    
    tri1 = triangle()
    tri2 = triangle(200, 30,400, 200, 100,  12)  
    tri3 = triangle( 50, 12,900,-400, 200, 300)
    tri4 = triangle(231, 54, 10, 324,  22,   5)
    tri5 = triangle( 64,  2, 43,  23, -54,  53)
    tri6 = triangle(234,235,332,-324,   4,  23)
    tri7 = triangle( 64,436,322,   7,-235, -64)
    tri8 = triangle(435, 23,523,-345, -54, 636)
    tri9 = triangle(843,426,634, -34,   4,-345)
    tri0 = triangle( 63,235,534,-235,-532, 532)

def draw():
    background(0)
    
    global last_key_change
    global delta_key_change
    global MIDI_key
    global MIDI_key_old
    global cam_pos_x
    global cam_pos_y
    global cam_pos_z
    global travel_vect_x
    global travel_vect_y
    global travel_vect_z
    global rotation_vect_x
    global rotation_vect_y
    global rotation_vect_z


    if millis()-last_key_change > delta_key_change:
        MIDI_key = random.randrange(1,12)
        last_key_change = millis()
    
    
    #background(math.pow(MIDI_key,2), 100, 70, 255)
    
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

    
    
    global tri1
    global tri2
    global tri3
    global tri4
    global tri5
    global tri6
    global tri7
    global tri8
    global tri9
    global tri0

    tri1.draw()
    tri2.draw()
    tri3.draw()
    tri4.draw()
    tri5.draw()
    tri6.draw()
    tri7.draw()
    tri8.draw()
    tri9.draw()
    tri0.draw()

    #weird_shape(200)
    
    MIDI_key_old = MIDI_key
    


class triangle:
    def __init__(self, size=100, bounce=10, time=700, x=0, y=0, z=0):
        self.size = size
        self.bounce = bounce
        self.time = time
        self.x = x
        self.y = y
        self.z = z
        self.old_millis = 0
        self.p = numpy.ones(15)
        self.p_orig = numpy.ones(15)
        
        self.p_orig[0] = -self.size
        self.p_orig[1] = -self.size
        self.p_orig[2] = -self.size
            
        self.p_orig[3] = self.size
        self.p_orig[4] = -self.size
        self.p_orig[5] = -self.size
            
        self.p_orig[6] = 0
        self.p_orig[7] = 0
        self.p_orig[8] = self.size
            
        self.p_orig[9] = self.size
        self.p_orig[10] = self.size
        self.p_orig[11] = -self.size
           
        self.p_orig[12] = -self.size
        self.p_orig[13] = self.size
        self.p_orig[14] = -self.size
        
        
    def draw(self):
        
        fill(255,0,0)
        
        stroke(255,0,0)
        
        time_passed = millis()-self.old_millis

        if time_passed > self.time:
            self.old_millis = millis()
            
            self.p[0] = self.p_orig[0]+(1-2*random.random())*self.bounce+self.x
            self.p[1] = self.p_orig[1]+(1-2*random.random())*self.bounce+self.y
            self.p[2] = self.p_orig[2]+(1-2*random.random())*self.bounce+self.z
            
            self.p[3] = self.p_orig[3]+(1-2*random.random())*self.bounce+self.x
            self.p[4] = self.p_orig[4]+(1-2*random.random())*self.bounce+self.y
            self.p[5] = self.p_orig[5]+(1-2*random.random())*self.bounce+self.z
            
            self.p[6] = self.p_orig[6]+(1-2*random.random())*self.bounce+self.x
            self.p[7] = self.p_orig[7]+(1-2*random.random())*self.bounce+self.y
            self.p[8] = self.p_orig[8]+(1-2*random.random())*self.bounce+self.z
            
            self.p[9] = self.p_orig[9]+(1-2*random.random())*self.bounce+self.x
            self.p[10] = self.p_orig[10]+(1-2*random.random())*self.bounce+self.y
            self.p[11] = self.p_orig[11]+(1-2*random.random())*self.bounce+self.z
           
            self.p[12] = self.p_orig[12]+(1-2*random.random())*self.bounce+self.x
            self.p[13] = self.p_orig[13]+(1-2*random.random())*self.bounce+self.y
            self.p[14] = self.p_orig[14]+(1-2*random.random())*self.bounce+self.z
            
        
        #begin_shape(kind=TRIANGLES)
        begin_shape(kind=LINES)

        stroke(0,100,80,255)
        vertex(self.p[0], self.p[1], self.p[2])
        vertex(self.p[3], self.p[4], self.p[5])
        vertex(self.p[6], self.p[7], self.p[8])
        
        vertex(self.p[0], self.p[1], self.p[2])
        
        end_shape()
        
        begin_shape(kind=TRIANGLES)
        
        stroke(120,100,80,255)
        fill(120,100,80,255)
        vertex(self.p[3], self.p[4], self.p[5])
        vertex(self.p[9], self.p[10], self.p[11])
        vertex(self.p[6], self.p[7], self.p[8])
        
        #vertex(self.p[3], self.p[4], self.p[5])
        
        
        end_shape()
        
        #begin_shape(kind=TRIANGLES)
        begin_shape(kind=LINES)

        
        stroke(240,100,80,255)
        vertex(self.p[9], self.p[10], self.p[11])
        vertex(self.p[12], self.p[13], self.p[14])
        vertex(self.p[6], self.p[7], self.p[8])
        
        vertex(self.p[9], self.p[10], self.p[11])
        
        
        end_shape()
        
        #begin_shape(kind=TRIANGLES)
        begin_shape(kind=LINES)

        
        stroke(0,100,100,255)
        vertex(self.p[12], self.p[13], self.p[14])
        vertex(self.p[0], self.p[1], self.p[2])
        vertex(self.p[6], self.p[7], self.p[8])
        
        vertex(self.p[12], self.p[13], self.p[14])
        
        end_shape()
    
    
    
if __name__ == '__main__':
    run(mode='P3D')