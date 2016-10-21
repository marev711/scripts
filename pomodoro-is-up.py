#! /usr/bin/env python
import datetime
import easygui

current_time = datetime.datetime.now().strftime("%H:%M:%S")
easygui.msgbox("Pomodoro is up: " + current_time, title="Pomodoro")
