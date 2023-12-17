from p5 import *

img = None
small_point = 4
large_point = 40

def setup():
    global img
    size(720, 400)
    no_stroke()
    background(255)
    img = load_image("moonwalk.jpg")


def draw():
    global img, large_point, small_point
    pointillize = remap(mouse_x, [0, width], [small_point, large_point])
    x = floor(random_uniform(img.width))
    y = floor(random_uniform(img.height))

    pix = img._get_pixel((x, y))
    fill(pix, 128)

    ellipse((x, y), pointillize, pointillize)

if __name__ == '__main__':
    run()