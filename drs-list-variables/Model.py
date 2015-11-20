import re
import string
import pdb

class Model(object):
    """ Base class for handling the various model data sets.
    """
    def __init__(self, model_name, file):
        self.model_name = model_name
        self.file = file
        var, mip, name, exp, ens, yrs = self.get_snippets()
        self.var = var
        self.mip = mip
        self.exp = exp

    def get_snippets(self):
        regex = re.compile(".nc$")
        return string.split(regex.sub("", self.file), "_")

class EC_EARTH3(Model):
    def __init__(self, file):
        super(EC_EARTH3, self).__init__("EC-EARTH3", file)

class EC_EARTH3_WAM(Model):
    def __init__(self, file):
        super(EC_EARTH3_WAM, self).__init__("EC-EARTH3-WAM", file)

class MPI_workaround(Model):
    def __init__(self, model_name, file):
        super(MPI_workaround, self).__init__(model_name, file)

    def get_snippets(self):
        regex = re.compile("(.*)_(" + self.model_name + ")_(.*).nc")
        var, mip = regex.search(self.file).group(1).split("_")
        experiment, years = regex.search(self.file).group(3).split("_")

        # Fix non-CMIP5 entries
        mip = re.sub("A3hr", "3hr", mip)
        mip = re.sub("L3hr", "3hr", mip)
        mip = re.sub("Aday", "day", mip)
        return var, mip, self.model_name, experiment, None, years

class MPIESM_1_1(MPI_workaround):
    def __init__(self, file):
        super(MPIESM_1_1, self).__init__("MPIESM_1_1", file)

class MPIESM_1_no_embrace(MPI_workaround):
    def __init__(self, file):
        super(MPIESM_1_no_embrace, self).__init__("MPIESM_1_no_embrace", file)

class MPIESM_1_with_embrace(MPI_workaround):
    def __init__(self, file):
        super(MPIESM_1_with_embrace, self).__init__("MPIESM_1_with_embrace", file)

class HadGEM3_A(Model):
    def __init__(self, file):
        super(HadGEM3_A, self).__init__("HadGEM3-A", file)

class HadGEM3_A_N216(Model):
    def __init__(self, file):
        super(HadGEM3_A_N216, self).__init__("HadGEM3-A-N216", file)

class HadGEM3_GC2_N216(Model):
    def __init__(self, file):
        super(HadGEM3_GC2_N216, self).__init__("HadGEM3-GC2-N216", file)

class HadGEM3_GC2_N96(Model):
    def __init__(self, file):
        super(HadGEM3_GC2_N96, self).__init__("HadGEM3-GC2-N96", file)

class CNRM_AM_PRE6(Model):
    def __init__(self, file):
        super(CNRM_AM_PRE6, self).__init__("CNRM-AM-PRE6", file)

    def get_snippets(self):
        var, mip, self.model_name, experiment, ens, years = super(CNRM_AM_PRE6, self).get_snippets()
        # Harmonize CMIP5 entries
        mip = re.sub("cf3hr", "3hr", mip)
        return var, mip, self.model_name, experiment, ens, years

class IPSL_CM5C_MR(Model):
    def __init__(self, file):
        super(IPSL_CM5C_MR, self).__init__("IPSL-CM5C-MR", file)

