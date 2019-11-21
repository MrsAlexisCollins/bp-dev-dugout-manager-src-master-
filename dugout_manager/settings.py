import os 

# Database connections and credentials 
# basecoach has R on cage, RW on dugout


try:
    from .local_settings import *
except ImportError as exc:
    import warnings
    warnings.warn('Could not import local_settings: %s' % exc)