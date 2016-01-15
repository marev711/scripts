# Graphical paste and save GUI for adding members
from Tkinter import *
import os
import pdb
import datetime


lday = 04
lmonth = 10

class myDate:
    def __init__(self, year, month, day):
        self.date = datetime.datetime(year, month, day)
        self.updateString()

    def getMonthDay(self):
        lday = format(self.date.day, '02')
        lmonth = format(self.date.month, '02')
        return lmonth + lday

    def getfilename(self):
        lfdate = self.getMonthDay()
        lfname = lfdate + "-" + nextfname(lfdate) + ".txt"
        return lfname


    def updateString(self):
        self.datestr = self.date.strftime("%m%d")

    def updateDate(self, dt_obj):
        self.date = dt_obj

date = myDate(2015, lmonth, lday)

def save(date):
    f = open(date.getfilename(), "w")
    t = text.get("1.0", END)
    f.write(t.encode('utf8'))
    f.close()
    lfname = date.getfilename()
    llabel.configure(text = lfname)

def add_day(date):
    dt = datetime.datetime(2015, date.date.month, date.date.day)
    dt = dt + datetime.timedelta(days=1)
    date.updateDate(dt)
    date.updateString()

    lfname = date.getfilename()
    llabel.configure(text = lfname)



def sub_day(date):
    dt = datetime.datetime(2015, date.date.month, date.date.day)
    dt = dt - datetime.timedelta(days=1)
    date.updateDate(dt)
    date.updateString()

    lfname = date.getfilename()
    llabel.configure(text = lfname)

def select_all(event):
        text.tag_add(SEL, "1.0", END)
        text.mark_set(INSERT, "1.0")
        text.see(INSERT)
        return 'break'

def nextfname(prefix):
    first = 1
    fstr = format(first, '02')
    while os.path.exists(prefix + "-" + fstr + ".txt"):
        first = first + 1
        fstr = format(first, '02')
    return fstr

root = Tk()
text = Text(root)
text.insert(INSERT, "")
text.bind("<Control-Key-a>", select_all)

text.grid()

bsave = Button(root, text="Save", command=lambda: save(date))
bsave.grid(columnspan=2, column=1, row=0)

dplus = Button(root, text="d+", command=lambda: add_day(date))
dplus.grid(column=1, row=1)

dminus = Button(root, text="d-", command=lambda: sub_day(date))
dminus.grid(column=2, row=1)

lfname = date.getfilename()
llabel = Label(root, text=lfname)
llabel.grid(columnspan=2, column=1, row=2)


root.mainloop()
