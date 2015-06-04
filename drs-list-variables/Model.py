class Model(object):
    """ Base class for handling the various model data sets.
    """
    def __init__(self, model_name):
        self.model_name = model_name

class EC_EARTH3(Model):
    def __init__(self):
        super(EC_EARTH3, self).__init__("EC-EARTH3")

class EC_EARTH3_WAM(Model):
    def __init__(self):
        super(EC_EARTH3_WAM, self).__init__("EC-EARTH3-WAM")

class MPIESM_1_1:
    def __init__(self):
        super(MPIESM_1_1, self).__init__("MPIESM_1_1")

class MPIESM_1_no_embrace:
    def __init__(self):
        super(MPIESM_1_no_embrace, self).__init__("MPIESM_1_no_embrace")

class MPIESM_1_with_embrace:
    def __init__(self):
        super(MPIESM_1_with_embrace, self).__init__("MPIESM_1_with_embrace")

class HadGEM3_A(Model):
    def __init__(self):
        super(HadGEM3_A, self).__init__("HadGEM3-A")

class HadGEM3_A_N216(Model):
    def __init__(self):
        super(HadGEM3_A_N216, self).__init__("HadGEM3-A-N216")

class HadGEM3_GC2_N216(Model):
    def __init__(self):
        super(HadGEM3_GC2_N216, self).__init__("HadGEM3-GC2-N216")

class HadGEM3_GC2_N96(Model):
    def __init__(self):
        super(HadGEM3_GC2_N96, self).__init__("HadGEM3-GC2-N96")

class CNRM_AM_PRE6(Model):
    def __init__(self):
        super(CNRM_AM_PRE6, self).__init__("CNRM-AM-PRE6")

