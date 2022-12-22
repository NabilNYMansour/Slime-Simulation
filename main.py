import math
import moderngl_window as mglw
import imgui
from moderngl_window.integrations.imgui import ModernglWindowRenderer
import numpy as np
from time import sleep

class App(mglw.WindowConfig):
    title = "Slimes simulation"
    ratio = 9/16
    width = 1600
    height = int(width*9/16)
    window_size = width, height
    padding = 10,10
    resource_dir = 'programs'
    vsync = True

    num_slimes = 200000
    speed = 1
    sense_agnle = math.pi/4
    sense_dis = 3

    is_slimes_solid_color = False
    solid_color = 0.75,0.45,0.45
    padding_color = (0.04,0.08,0.16)
    background_color = (0,0,0)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        # Shaders init
        self.prog = self.load_program(vertex_shader='vert.glsl',
                                      fragment_shader='frag.glsl')
        self.compute = self.load_compute_shader(path='comp.glsl')

        self.compute['speed'] = self.speed
        self.compute['senseDis'] = self.sense_dis
        self.compute['senseAngle'] = self.sense_agnle

        self.compute['padding'] = self.padding
        self.compute['boundary'] = self.window_size
        self.compute['iSsolidColor'] = self.is_slimes_solid_color
        self.compute['solidColor'] = self.solid_color

        self.prog['padding'] = self.padding
        self.prog['boundary'] = self.window_size
        self.prog['paddingColor'] = self.padding_color
        self.prog['backgroundColor'] = self.background_color

        # Buffers init
        data = self.init_data()
        self.slimes = self.ctx.buffer(data=data.tobytes())
        self.texture = self.ctx.texture(size=self.window_size,components=4,dtype='f4')
        self.quad = mglw.geometry.quad_fs()

        # GUI init
        imgui.create_context()
        io = imgui.get_io()
        io.fonts.add_font_from_file_ttf('font.ttf', 30)
        self.imgui = ModernglWindowRenderer(self.wnd)
        self.imgui.refresh_font_texture()

    def init_data(self):
        radius = 1
        center = (self.width/2, self.height/2)

        positionsX = np.random.uniform(center[0] - radius, center[0] + radius,(self.num_slimes,1)).astype('f4')
        positionsY = np.random.uniform(center[1] - radius, center[1] + radius,(self.num_slimes,1)).astype('f4')

        directionX = np.random.randint(-100,100,(self.num_slimes,1)).astype('f4')
        directionX /= 100
        directionY = np.random.randint(-100,100,(self.num_slimes,1)).astype('f4')
        directionY /= 100

        data = np.hstack((positionsX,positionsY,directionX,directionY)).astype('f4')
        return data

    def reset(self):
        self.slimes.release()
        self.texture.release()

        data = self.init_data()

        self.slimes = self.ctx.buffer(data=data.tobytes())
        self.texture = self.ctx.texture(size=self.window_size,components=4,dtype='f4')

    def render(self, time, frame_time):
        # print(np.frombuffer(self.slimes.read(), dtype='f4')[-4:])
        # sleep(0.5)
        self.ctx.clear()

        w, h = self.slimes.size, 1
        gw, gh = 1024, 1
        nx, ny, nz = math.ceil(w/gw), math.ceil(h/gh), 1

        self.slimes.bind_to_storage_buffer(1)
        self.texture.bind_to_image(0, read=False, write=True)
        self.compute.run(nx, ny, nz)

        self.texture.use(location=0)
        self.quad.render(self.prog)
        self.render_ui()

    def render_ui(self):
        imgui.new_frame()
        imgui.begin("Settings", False, imgui.WINDOW_NO_MOVE) # 1 begin


        # Reset
        if imgui.button("Reset Simulation"):
            self.reset()

        # Variables
        imgui.begin_child("region", -50, 0, border=True)
        imgui.text("Variables:")

        ## speed
        imgui.push_item_width(imgui.get_window_width()*0.3)
        changedS, new_speed = imgui.input_float("Slimes' Speed", value=self.speed, step_fast=0.1, format='%.1f')
        if changedS:
            self.speed = new_speed
            self.compute['speed'] = self.speed

        imgui.push_item_width(imgui.get_window_width()*0.45)
        changedD, new_dis = imgui.input_float("Slimes' sense distance", value=self.sense_dis, step_fast=0.1, format='%.1f')
        if changedD:
            self.sense_dis = new_dis
            self.compute['senseDis'] = self.sense_dis

        ## sense angle
        imgui.push_item_width(imgui.get_window_width()*0.5)
        changedA, new_angle = imgui.slider_float("Slimes' sense agnle", value=self.sense_agnle/math.pi, 
            min_value=0, max_value=1, format="%.2f PI")
        if changedA:
            self.sense_agnle = new_angle*math.pi
            self.compute['senseAngle'] = self.sense_agnle
        imgui.end_child()

        # Padding
        imgui.begin_child("region", -50, 0, border=True)
        imgui.text("Padding:")
        imgui.push_item_width(imgui.get_window_width()*0.75)
        changedX, valueX = imgui.slider_float("X", value=self.padding[0], 
            min_value=0, max_value=self.width/2, format="%.0f")
        changedY, valueY = imgui.slider_float("Y", value=self.padding[1], 
            min_value=0, max_value=self.height/2, format="%.0f")
        if changedX or changedY:
            self.padding = valueX,valueY
            self.compute['padding'] = self.padding
            self.prog['padding'] = self.padding
        imgui.end_child()

        # Coloring
        imgui.begin_child("region", -50, 0, border=True)
        imgui.text("Color Mode:")
        if imgui.radio_button("Render Slimes with solid color", self.is_slimes_solid_color):
            self.is_slimes_solid_color = not self.is_slimes_solid_color
            self.compute['iSsolidColor'] = self.is_slimes_solid_color
        imgui.push_item_width(imgui.get_window_width()*0.5)
        changedC, new_solid_color = imgui.color_edit3("Slimes' Solid Color", *self.solid_color)
        if changedC:
            self.solid_color = new_solid_color
            self.compute['solidColor'] = self.solid_color
        changedPC, new_pad_solid_color = imgui.color_edit3("Padding Color", *self.padding_color)
        if changedPC:
            self.padding_color = new_pad_solid_color
            self.prog['paddingColor'] = self.padding_color
        changedBC, new_background_color = imgui.color_edit3("Background Color", *self.background_color)
        if changedBC:
            self.background_color = new_background_color
            self.prog['backgroundColor'] = self.background_color
        imgui.end_child()


        imgui.end() # 1 end
        imgui.render()
        self.imgui.render(imgui.get_draw_data())

    def resize(self, width: int, height: int):
        self.imgui.resize(width, height)

    def mouse_position_event(self, x, y, dx, dy):
        self.imgui.mouse_position_event(x, y, dx, dy)

    def mouse_drag_event(self, x, y, dx, dy):
        self.imgui.mouse_drag_event(x, y, dx, dy)

    def mouse_scroll_event(self, x_offset, y_offset):
        self.imgui.mouse_scroll_event(x_offset, y_offset)

    def mouse_press_event(self, x, y, button):
        self.imgui.mouse_press_event(x, y, button)

    def mouse_release_event(self, x: int, y: int, button: int):
        self.imgui.mouse_release_event(x, y, button)

    def key_event(self, key, action, modifiers):
        self.imgui.key_event(key, action, modifiers)

    def unicode_char_entered(self, char):
        self.imgui.unicode_char_entered(char)

if __name__ == '__main__':
    mglw.run_window_config(App)


