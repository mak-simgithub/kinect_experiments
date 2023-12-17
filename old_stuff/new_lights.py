from p5 import *
import time
import random
import numpy
import math

def setup():
    size(2400, 1200)
    color_mode('HSB', 360, 100, 100, 255)

    camera((0,0,-1000),(0,0,0),(0,1,0))

    global bar1
    global bar2
    global bar3

    bar1 = lightbar()
    bar2 = lightbar(direction = [9,1,5], pos = [-100,100,50], length = 20)
    bar3 = lightbar(direction = [1,4,2], pos = [200,-50,-50])

    global barensemble

    ensemble = barensemble([bar1, bar2, bar3])


    global greenflash

    greenflash = lighteffect("pulse", [2000,1000,0.33,127,50,100])

    bar3.add_effect("greenflash", greenflash)


     # x geht von links nach rechts, y geht von oben nach unten und z geht vom screen in die tiefe


def draw():
    background(0, 0, 30, 255)


    global bar1
    global bar2


    bar1.pulse()
    bar1.lightshuttle()
    bar2.lightshuttle()

    bar1.draw()
    bar2.draw()


    global bar3

    bar3.apply_effects()
    bar3.draw()



class lighteffect:
    def __init__(self, effect_type, args):
        self.start = 0
        self.type = effect_type
        self.args = args
    def apply(self, lightarray):
        if self.type == "pulse":

            period = self.args[0]
            duration = self.args[1]
            fade = self.args[2]
            color = self.args[3:6]

            time_passed = millis()-self.start

            if time_passed > period:
                self.start = millis()


            if time_passed < duration*fade:
                pulse_intensity = (time_passed/duration/fade)
            elif time_passed > duration*fade and time_passed < duration*(1-fade):
                pulse_intensity = 1
            elif time_passed > duration*(1-fade) and time_passed < duration:
                pulse_intensity = (1-(time_passed-duration*(1-fade))/duration/fade)
            else:
                pulse_intensity = 0

            pulse_intensity = math.pow(pulse_intensity,2)

            h = color[0]
            s = color[1]
            l = color[2]*pulse_intensity

            hslcolor = Color(h,s,l)
            rgbcolor = hslcolor.rgb

            lightarray[0,:] = lightarray[0,:] + rgbcolor[0]#r
            lightarray[1,:] = lightarray[1,:] + rgbcolor[1]#g
            lightarray[2,:] = lightarray[2,:] + rgbcolor[2]#b

            return lightarray

        elif type == "rail":
            a=1
        elif type == "shuttle":
            a=1



class barensemble:
    def __init__(self, bars):
        self.bars = bars



class lightbar:
    def __init__(self, length=100, direction = [1,1,1], pos = [0,0,0], lightsize = 5.5, intra_dist = 6, inter_dist = 16.6, triple = False):
         # x geht von links nach rechts, y geht von oben nach unten und z geht vom screen in die tiefe
        self.barlength = length

        dir_norm = math.sqrt(direction[0]*direction[0]+direction[1]*direction[1]+direction[2]*direction[2])
        self.dir = numpy.array(direction)/dir_norm

        self.pos = numpy.array(pos)

        self.lightsize = lightsize

        self.intra_dist = intra_dist

        self.inter_dist = inter_dist

        self.triple = triple

        # we have 3 times length lights with each 3 coordinates
        #
        #    1b     1c
        #       1a
        #
        # x1a x1b x1c x2a ... xlengthc
        # y1a y1b y1c y2a ... ylengthc
        # z1a z1b z1c z2a ... zlengthc
        #
        # x geht von links nach rechts, y geht von oben nach unten und z geht vom screen in die tiefe
        #

        if triple:
            self.location_array = numpy.zeros([length*3,3])
            self.light_array = numpy.array([numpy.ones([self.barlength*3])*360, numpy.ones([self.barlength*3])*0, numpy.ones([self.barlength*3])*100])

            # (a1,a2,a3) und (b1,b2,b3) sind orthogonal wenn a1*b1+a2*b2+a3*b3 = 0
            # a ist self.dir, b ist up
            # b3 = 0
            # b2 = 1
            # a1*b1 = -a2
            # b1 = -a2/a1

            # normalize it
            # divide by sqrt(1+a2²/a1²)

            up1 = -self.dir[1]/self.dir[0]

            up_norm = math.sqrt(1+self.dir[1]*self.dir[1]/self.dir[0]/self.dir[0])

            up = numpy.array([up1, 1, 0])/up_norm


            # a ist self.dir, b ist up, c ist left, mit kreuzprodukt

            left = numpy.array([self.dir[1]*up[2]-self.dir[2]*up[1], self.dir[2]*up[0]-self.dir[0]*up[2], self.dir[0]*up[1]-self.dir[1]*up[0]])


            b_offset = numpy.array([up[0]+left[0], up[1]+left[1], up[2]+left[2]])*self.intra_dist

            c_offset = numpy.array([up[0]-left[0], up[1]-left[1], up[2]-left[2]])*self.intra_dist

            for i in range(self.barlength):
                #x coordinates
                #a
                self.location_array[i*3,0] = self.pos[0] + i*self.dir[0]*self.inter_dist
                #b
                self.location_array[i*3+1,0] = self.pos[0] + i*self.dir[0]*self.inter_dist + b_offset[0]
                #c
                self.location_array[i*3+2,0] = self.pos[0] + i*self.dir[0]*self.inter_dist + c_offset[0]

                #y coordinates
                #a
                self.location_array[i*3,1] = self.pos[1] + i*self.dir[1]*self.inter_dist
                #b
                self.location_array[i*3+1,1] = self.pos[1] + i*self.dir[1]*self.inter_dist + b_offset[1]
                #c
                self.location_array[i*3+2,1] = self.pos[1] + i*self.dir[1]*self.inter_dist + c_offset[1]

                #z coordinates
                #a
                self.location_array[i*3,2] = self.pos[2] + i*self.dir[2]*self.inter_dist
                #b
                self.location_array[i*3+1,2] = self.pos[2] + i*self.dir[2]*self.inter_dist + b_offset[2]
                #c
                self.location_array[i*3+2,2] = self.pos[2] + i*self.dir[2]*self.inter_dist + c_offset[2]


        else:
            self.location_array = numpy.zeros([length,3])

            for i in range(self.barlength):
                #x coordinates
                #a
                self.location_array[i,0] = self.pos[0] + i*self.dir[0]*self.inter_dist

                #y coordinates
                #a
                self.location_array[i,1] = self.pos[1] + i*self.dir[1]*self.inter_dist

                #z coordinates
                #a
                self.location_array[i,2] = self.pos[2] + i*self.dir[2]*self.inter_dist

            self.light_array = numpy.array([numpy.ones([self.barlength])*0, numpy.ones([self.barlength])*0, numpy.ones([self.barlength])*0])

        self.effects = []
        self.effect_names = []


        self.pulse_start = 0
        self.lightrail_start = 0
        self.lightshuttle_start = 0
        self.lightshuttle_dir = 1

    def add_effect(self, name, effect):
        self.effects.append(effect)
        self.effect_names.append(name)

    def apply_effects(self):
        for effect in self.effects:
            self.light_array = effect.apply(self.light_array)


    def draw(self):

        no_stroke()

        if self.triple:
            for i in range(self.barlength*3):
                #print("Light: " + str(i) + " at pos: " + str(self.location_array[i,0]) + ", " + str(self.location_array[i,1]) + ", " + str(self.location_array[i,2]))
                fill(self.light_array[0,i], self.light_array[1,i], self.light_array[2,i], 255)
                with push_matrix():
                    translate(self.location_array[i,0], self.location_array[i,1], self.location_array[i,2])
                    sphere(self.lightsize, 3, 3)
        else:
            for i in range(self.barlength):
                #print("Light: " + str(i) + " at pos: " + str(self.location_array[i,0]) + ", " + str(self.location_array[i,1]) + ", " + str(self.location_array[i,2]))

                color = Color(r=self.light_array[0,i],g=self.light_array[1,i],b=self.light_array[2,i])

                fill(color)
                with push_matrix():
                    translate(self.location_array[i,0], self.location_array[i,1], self.location_array[i,2])
                    sphere(self.lightsize, 3, 3)

            self.light_array = numpy.array([numpy.ones([self.barlength])*0, numpy.ones([self.barlength])*0, numpy.ones([self.barlength])*0])


    def pulse(self, period=2000, duration=1000, fade=0.33, color = [127, 50, 100]):

        time_passed = millis()-self.pulse_start

        if time_passed > period:
            self.pulse_start = millis()


        if time_passed < duration*fade:
            pulse_intensity = (time_passed/duration/fade)
        elif time_passed > duration*fade and time_passed < duration*(1-fade):
            pulse_intensity = 1
        elif time_passed > duration*(1-fade) and time_passed < duration:
            pulse_intensity = (1-(time_passed-duration*(1-fade))/duration/fade)
        else:
            pulse_intensity = 0

        pulse_intensity = math.pow(pulse_intensity,2)

        if self.triple:
            self.light_array = numpy.array([numpy.ones([self.barlength*3])*color[0], numpy.ones([self.barlength*3])*color[1], numpy.ones([self.barlength*3])*color[2]*pulse_intensity])
        else:
            h = color[0]
            s = color[1]
            l = color[2]*pulse_intensity

            hslcolor = Color(h,s,l)
            rgbcolor = hslcolor.rgb


            self.light_array[0,:] = self.light_array[0,:] + rgbcolor[0]#r
            self.light_array[1,:] = self.light_array[1,:] + rgbcolor[1]#g
            self.light_array[2,:] = self.light_array[2,:] + rgbcolor[2]#b



    def lightrail(self, period=2000, length=5, fade=0.33, color = [7, 50, 100]):

        time_passed = millis()-self.lightrail_start

        if time_passed > period:
            self.lightrail_start = millis()

        if self.triple:
            progress = int(time_passed/period*self.barlength/3)*3

        else:
            progress = int(time_passed/period*self.barlength)+1


        self.lightbullet(progress, length, fade, color)


    def lightshuttle(self, period=2000, length=5, fade=0.33, color = [7, 50, 100]):

        time_passed = millis()-self.lightshuttle_start

        if time_passed > period:
            self.lightshuttle_start = millis()

        if self.triple:
            if self.lightshuttle_dir > 0:
                progress = int(time_passed/period*self.barlength)+1
            else:
                progress = int((1-time_passed/period)*self.barlength)+1

        else:
            if self.lightshuttle_dir > 0:
                progress = int(time_passed/period*self.barlength)+1
            else:
                progress = int((1-time_passed/period)*self.barlength)+1


        if time_passed > period:
            self.lightshuttle_dir = self.lightshuttle_dir*-1

        self.lightbullet(progress, length, fade, color)



    def lightbullet(self, progress = 0, length=5, fade=0.33, color = [7, 50, 100]):

        if self.triple:
            for i in range(self.barlength):
                self.light_array[0,i*3] = color[0]#h
                self.light_array[0,i*3+1] = color[0]#h
                self.light_array[0,i*3+2] = color[0]#h

                self.light_array[1,i*3] = color[1]#s
                self.light_array[1,i*3+1] = color[1]#s
                self.light_array[1,i*3+2] = color[1]#s

                fadein = math.floor(progress-length/2)
                onstart = progress-fade*length/2
                onend = progress+(1-fade)*length/2
                fadeout = math.ceil(progress+length/2)

                #print("___")
                if i >= fadein and i <= onstart:
                    #print("fadein " + str(i))
                    factor = (i-fadein)/(onstart-fadein)

                elif i > onstart and i < onend:
                    #print("on " + str(i))
                    factor = 1

                elif i >= onend and i <= fadeout:
                   #print("fadeout " + str(i))
                   factor = (i-fadeout)/(onend-fadeout)

                else:
                    #print("off " + str(i))
                    factor = 0

                self.light_array[2,i*3] = color[2]*factor#l
                self.light_array[2,i*3+1] = color[2]*factor#l
                self.light_array[2,i*3+2] = color[2]*factor#l

                #print("i: " + str(i))
                #print("light: " + str(self.light_array[2,i*3+2]))
                #print("factor: " + str(factor))
                #print("fadein: " + str(fadein))
                #print("onstart: " + str(onstart))
                #print("onened: " + str(onend))
                #print("fadeout: " + str(fadeout))
                #print("---")

        else:
            for i in range(self.barlength):

                fadein = math.floor(progress-length/2)
                onstart = progress-fade*length/2
                onend = progress+(1-fade)*length/2
                fadeout = math.ceil(progress+length/2)

                #print("___")
                if i >= fadein and i <= onstart:
                    #print("fadein " + str(i))
                    factor = (i-fadein)/(onstart-fadein)

                elif i > onstart and i < onend:
                    #print("on " + str(i))
                    factor = 1

                elif i >= onend and i <= fadeout:
                   #print("fadeout " + str(i))
                   factor = (i-fadeout)/(onend-fadeout)

                else:
                    #print("off " + str(i))
                    factor = 0

                h = color[0]
                s = color[1]
                l = color[2]*factor

                hslcolor = Color(h,s,l)
                rgbcolor = hslcolor.rgb


                self.light_array[0,i] = self.light_array[0,i] + rgbcolor[0]#r
                self.light_array[1,i] = self.light_array[1,i] + rgbcolor[1]#g
                self.light_array[2,i] = self.light_array[2,i] + rgbcolor[2]#b

                #print("i: " + str(i))
                #print("light: " + str(self.light_array[2,i*3+2]))
                #print("factor: " + str(factor))
                #print("fadein: " + str(fadein))
                #print("onstart: " + str(onstart))
                #print("onened: " + str(onend))
                #print("fadeout: " + str(fadeout))
                #print("---")





if __name__ == '__main__':
    run(mode='P3D')
