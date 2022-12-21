import math
import moderngl_window as mglw
import imgui
from moderngl_window.integrations.imgui import ModernglWindowRenderer
import numpy as np
from time import sleep

class App(mglw.WindowConfig):
    title = "Slimes simulation"
    width = 1600
    height = 900
    # width = 4000
    # height = 2000
    window_size = width, height
    padding = 100,100
    resource_dir = 'programs'
    vsync = True
    num_slimes = 200000

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.prog = self.load_program(vertex_shader='vert.glsl',
                                      fragment_shader='frag.glsl')
        self.compute = self.load_compute_shader(path='comp.glsl')

        self.compute['speed'] = 2
        self.compute['senseDis'] = 5
        self.compute['senseAngle'] = math.pi/4

        self.compute['padding'] = self.padding
        self.compute['boundary'] = self.window_size

        self.prog['padding'] = self.padding
        self.prog['boundary'] = self.window_size
        self.prog['color'] = (1,1,1)

        radius = 1
        center = (self.width/2, self.height/2)

        positionsX = np.random.uniform(center[0] - radius, center[0] + radius,(self.num_slimes,1)).astype('f4')
        positionsY = np.random.uniform(center[1] - radius, center[1] + radius,(self.num_slimes,1)).astype('f4')

        directionX = np.random.randint(-100,100,(self.num_slimes,1)).astype('f4')
        directionX /= 100
        directionY = np.random.randint(-100,100,(self.num_slimes,1)).astype('f4')
        directionY /= 100

        data = np.hstack((positionsX,positionsY,directionX,directionY)).astype('f4')
        # print(data)

        self.slimes = self.ctx.buffer(data=data.tobytes())

        self.texture = self.ctx.texture(size=self.window_size,components=4,dtype='f4')
        self.quad = mglw.geometry.quad_fs()

        # GUI init
        # imgui.create_context()
        # io = imgui.get_io()
        # io.fonts.add_font_from_file_ttf('font.ttf', 30)
        # self.imgui = ModernglWindowRenderer(self.wnd)
        # self.imgui.refresh_font_texture()

        # self.wnd.exit_key = None

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
        # self.render_ui()

    # def render_ui(self):
    #     imgui.new_frame()
    #     # imgui.set_next_window_size(200, 200)
    #     # imgui.begin("Your first window!", False, imgui.WINDOW_NO_MOVE+imgui.WINDOW_NO_RESIZE+imgui.WINDOW_NO_COLLAPSE)
    #     imgui.begin("Your first window!", False, imgui.WINDOW_NO_MOVE+imgui.WINDOW_NO_RESIZE+imgui.WINDOW_NO_COLLAPSE)
    #     imgui.text("Hello world! TESTTESTTESTTESTTEST")
    #     imgui.end()
    #     imgui.render()
    #     self.imgui.render(imgui.get_draw_data())

    # def resize(self, width: int, height: int):
    #     self.imgui.resize(width, height)

    # def mouse_position_event(self, x, y, dx, dy):
    #     self.imgui.mouse_position_event(x, y, dx, dy)

    # def mouse_drag_event(self, x, y, dx, dy):
    #     self.imgui.mouse_drag_event(x, y, dx, dy)

    # def mouse_scroll_event(self, x_offset, y_offset):
    #     self.imgui.mouse_scroll_event(x_offset, y_offset)

    # def mouse_press_event(self, x, y, button):
    #     self.imgui.mouse_press_event(x, y, button)

    # def mouse_release_event(self, x: int, y: int, button: int):
    #     self.imgui.mouse_release_event(x, y, button)

if __name__ == '__main__':
    mglw.run_window_config(App)


