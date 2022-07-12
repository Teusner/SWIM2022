from manim import *
import numpy as np


class introduction(Scene):
    # Scene config
    config.media_dir = "./build/manim"
    # config.save_last_frame = True 
    config.background_color = "#FAFAFA"
    config.frame_height = 6
    config.frame_width = 6
    def construct(self):
        # System
        system = Dot(np.array([-1.5, -1.5, 0]), radius=0.15).set_color(RED).set_z_index(3)
        text_system = Tex("system", font_size=48).set_color(RED).move_to(system.get_center() + np.array([0, 0.5, 0])).set_z_index(3)

        # Sensor
        sensor = Dot(np.array([1.5, 1.5, 0]), radius=0.15).set_color(TEAL).set_z_index(4)
        text_sensor = Tex("sensor", font_size=48).set_color(TEAL).move_to(sensor.get_center() + np.array([0, 0.5, 0])).set_z_index(4)

        # Trace
        trace = TracedPath(system.get_center).set_color(GRAY_D).set_stroke(width=2).set_z_index(2)

        # Path
        self.path = VMobject().set_color(GRAY_B).set_stroke(width=2).set_z_index(1).start_new_path(np.array([-1.5, -1.5, 0]))
        self.path.add_cubic_bezier_curve_to(np.array([1, -1.5, 0]), np.array([1.5, 1.5, 0]), np.array([-0.5, 1.5, 0]))
        self.path.add_cubic_bezier_curve_to(np.array([-2.5, 1.5, 0]), np.array([-2, -1.5, 0]), np.array([1.5, -0.5, 0]))

        # ti
        ti = Dot(radius=0.1).set_z_index(2).set_color(GRAY_D)
        ti.move_to(self.path.point_from_proportion(0.29))
        text_ti = Tex("$t_i$", font_size=36).set_color(RED).move_to(self.path.point_from_proportion(0.29)+np.array([0.5, 0, 0])).set_z_index(2)
        pulse = Circle(1.3).set_color(RED).move_to(self.path.point_from_proportion(0.29)).set_z_index(2)

        # tj
        text_tj = Tex("$t_j$", font_size=36).set_color(TEAL).move_to(sensor.get_center()+np.array([0.5, 0, 0])).set_z_index(2)

        # Group
        group = VGroup(self.path, system, text_system, sensor, text_sensor)

        # Animation
        self.play(Write(group), run_time=2)
        self.add(trace)

        # [0, ti]
        self.play(MoveAlongPath(system, self.path.get_subcurve(0, 0.3)), rate_func=linear, run_time=3)
        self.add(ti, text_ti, self.path.get_subcurve(0, 0.3).set_color(GRAY_D).set_stroke(width=2))
        self.remove(trace)
        self.wait()

        # [ti, tj]
        trace = TracedPath(system.get_center).set_color(GRAY_D).set_z_index(2)
        self.add(trace)
        self.play(MoveAlongPath(system, self.path.get_subcurve(0.3, 0.4)), GrowFromCenter(pulse), rate_func=linear, run_time=1)
        self.add(text_tj, self.path.get_subcurve(0.3, 0.4).set_color(GRAY_D).set_stroke(width=2))
        self.remove(trace)
        self.wait()

        # [tj, tj+0.1]
        trace = TracedPath(system.get_center).set_color(GRAY_D).set_z_index(2)
        self.add(trace)
        self.play(MoveAlongPath(system, self.path.get_subcurve(0.4, 0.5)), FadeOut(pulse, scale=1.5), rate_func=linear, run_time=1)
        self.add(text_tj, self.path.get_subcurve(0.4, 0.5).set_color(GRAY_D).set_stroke(width=2))
        self.remove(trace)

        # [tj+0.1, 1]
        self.remove(pulse)
        trace = TracedPath(system.get_center).set_color(GRAY_D).set_z_index(2).set_stroke(width=2)
        self.add(trace)
        self.play(MoveAlongPath(system, self.path.get_subcurve(0.5, 1)), rate_func=linear, run_time=6)
        self.add(self.path.get_subcurve(0.5, 1).set_color(GRAY_D).set_stroke(width=2))
        self.wait()

class boat(Scene):
    # Scene config
    config.media_dir = "./build/manim"
    # config.save_last_frame = True 
    config.background_color = "#FAFAFA"
    config.frame_height = 10
    config.frame_width = 10
    def construct(self):
        p0 = -4
        pe = 4
        position = ValueTracker(p0)

        # System
        boat = Polygon([0, -0.2, 0], [0, 0.2, 0], [0.6, 0, 0]).set_style(RED, 1, RED, 1).set_z_index(3)
        boat.add_updater(lambda mobj: mobj.move_to(np.array([position.get_value(), 0, 0])))

        # Wake
        upper_wake = Line()
        lower_wake = Line()
        upper_wake.add_updater(
            lambda mobj: mobj.become(Line(np.array([p0, (position.get_value()-p0)/3, 0]), np.array([position.get_value(), 0, 0])).set_color([BLUE, "#FAFAFA"]).set_z_index(2))
        )
        lower_wake.add_updater(
            lambda mobj: mobj.become(Line(np.array([p0, -(position.get_value()-p0)/3, 0]), np.array([position.get_value(), 0, 0])).set_color([BLUE, "#FAFAFA"]).set_z_index(2))
        )

        def circle_updater(mobj, p):
            v = max(0, (position.get_value()-mobj.get_x())/3.2)
            return Circle(v).set_stroke(BLUE, opacity=np.exp(-v)).move_to(np.array([p, 0, 0]))

        def pulse_updater(mobj, p):
            v = max(0, (position.get_value()-mobj.get_x())/3.2)
            return Circle(v).set_stroke(RED).move_to(np.array([p, 0, 0]))

        circles = VGroup()
        for p in np.arange(p0, pe, 1):
            c = Circle(0, BLUE).move_to(np.array([p, 0, 0])).set_z_index(1)
            if p == -2:
                c.add_updater(lambda mobj, p=p: mobj.become(pulse_updater(mobj, p)))
            else:
                c.add_updater(lambda mobj, p=p: mobj.become(circle_updater(mobj, p)))
            circles.add(c)

        self.add(circles)
        
        # Sensor
        sensor = Dot(np.array([-1.5, -1.5, 0]), radius=0.15).set_color(TEAL).set_z_index(4)

        # Text
        text_ti = Tex("$t_i$").set_color(RED).move_to(np.array([-2, 0.5, 0]))
        text_tj = Tex("$t_j$").set_color(TEAL).move_to(sensor.get_center() + DOWN)

        # Group
        group = VGroup(boat, upper_wake, lower_wake, sensor)

        # Animation
        self.play(Write(group), run_time=2)
        self.play(position.animate.set_value(-2), rate_func=linear, run_time=2)
        self.add(text_ti)
        self.wait()
        self.play(position.animate.set_value(3), rate_func=linear, run_time=5)
        self.add(text_tj)
        self.wait()
        upper_wake.suspend_updating()
        lower_wake.suspend_updating()
        circles.suspend_updating()
        self.play(FadeOut(group), FadeOut(circles), FadeOut(text_ti), FadeOut(text_tj), FadeOut(upper_wake), FadeOut(lower_wake), rate_func=linear, run_time=1.5)